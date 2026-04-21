// This edge function receives the authoritative Paymob processed callback and updates booking states.
import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { createClient } from 'npm:@supabase/supabase-js@2';

import { corsHeaders, errorResponse, jsonResponse } from '../_shared/cors.ts';
import { verifyProcessedCallbackHmac } from '../_shared/hmac.ts';

// This helper creates an admin Supabase client for callback-driven status updates.
function createAdminClient() {
  return createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
  );
}

// This helper safely converts any unknown object-like value into a record.
function asRecord(value: unknown): Record<string, unknown> {
  if (typeof value === 'object' && value !== null) {
    return value as Record<string, unknown>;
  }
  return {};
}

// ✅ Updated: parse Paymob boolean-like fields safely.
function parseBool(value: unknown): boolean | null {
  if (value === true || value === 'true') return true;
  if (value === false || value === 'false') return false;
  return null;
}

// This helper extracts the callback payload parts used for booking lookup and status updates.
function extractCallbackData(payload: Record<string, unknown>) {
  const obj =
    typeof payload['obj'] === 'object' && payload['obj'] !== null
      ? (payload['obj'] as Record<string, unknown>)
      : payload;

  const order = asRecord(obj['order']);

  const merchantOrderId =
    typeof order['merchant_order_id'] === 'string'
      ? order['merchant_order_id']
      : typeof obj['merchant_order_id'] === 'string'
          ? obj['merchant_order_id']
          : typeof obj['special_reference'] === 'string'
              ? obj['special_reference']
              : null;

  const paymobOrderId =
    order['id'] !== undefined && order['id'] !== null
      ? String(order['id'])
      : null;

  const paymobTransactionId =
    obj['id'] !== undefined && obj['id'] !== null
      ? String(obj['id'])
      : null;

  return {
    obj,
    order,
    merchantOrderId,
    paymobOrderId,
    paymobTransactionId,
    success: parseBool(obj['success']),
    pending: parseBool(obj['pending']),
    isVoided: parseBool(obj['is_voided']),
    isRefunded: parseBool(obj['is_refunded']),
  };
}

// ✅ Updated: update only one target payment row instead of all rows for the booking.
async function findTargetPayment(
  adminClient: ReturnType<typeof createAdminClient>,
  bookingId: string,
  paymobOrderId: string | null,
) {
  if (paymobOrderId) {
    const { data, error } = await adminClient
      .from('booking_payments')
      .select('id, payment_status, paymob_order_id')
      .eq('booking_id', bookingId)
      .eq('paymob_order_id', paymobOrderId)
      .order('created_at', { ascending: false })
      .limit(1)
      .maybeSingle();

    if (error) {
      throw new Error(`Failed to lookup payment by Paymob order ID: ${error.message}`);
    }

    if (data) return data;
  }

  const { data, error } = await adminClient
    .from('booking_payments')
    .select('id, payment_status, paymob_order_id')
    .eq('booking_id', bookingId)
    .order('created_at', { ascending: false })
    .limit(1)
    .maybeSingle();

  if (error) {
    throw new Error(`Failed to lookup latest payment row: ${error.message}`);
  }

  return data;
}

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  if (req.method !== 'POST') {
    return errorResponse('Method not allowed', 405);
  }

  try {
    const adminClient = createAdminClient();
    const callbackUrl = new URL(req.url);
    const receivedHmac = callbackUrl.searchParams.get('hmac') ?? '';
    const payload = await req.json();

    const isValidHmac = await verifyProcessedCallbackHmac(payload, receivedHmac);
    if (!isValidHmac) {
      console.error('Processed callback HMAC verification failed');
      return errorResponse('Invalid Paymob callback HMAC', 401);
    }

    const {
      merchantOrderId,
      paymobOrderId,
      paymobTransactionId,
      success,
      pending,
      isVoided,
      isRefunded,
    } = extractCallbackData(payload);

    console.log(
      JSON.stringify({
        stage: 'processed-callback-received',
        merchantOrderId,
        paymobOrderId,
        paymobTransactionId,
        success,
        pending,
        isVoided,
        isRefunded,
      }),
    );

    let bookingLookupId: string | null = null;

    // ✅ Updated: prefer the signed Paymob order ID lookup first.
    if (paymobOrderId) {
      const { data: bookingByOrder, error: bookingByOrderError } =
        await adminClient
          .from('bookings')
          .select('id')
          .eq('paymob_order_id', paymobOrderId)
          .maybeSingle();

      if (bookingByOrderError) {
        throw new Error(
          `Failed to lookup booking by Paymob order ID: ${bookingByOrderError.message}`,
        );
      }

      bookingLookupId = bookingByOrder?.id ?? null;
    }

    // Fallback to merchant reference if needed.
    if (!bookingLookupId && merchantOrderId) {
      const { data: bookingByMerchantRef, error: bookingByMerchantRefError } =
        await adminClient
          .from('bookings')
          .select('id')
          .eq('id', merchantOrderId)
          .maybeSingle();

      if (bookingByMerchantRefError) {
        throw new Error(
          `Failed to lookup booking by merchant reference: ${bookingByMerchantRefError.message}`,
        );
      }

      bookingLookupId = bookingByMerchantRef?.id ?? null;
    }

    if (!bookingLookupId) {
      console.warn(
        JSON.stringify({
          stage: 'processed-callback-booking-not-found',
          merchantOrderId,
          paymobOrderId,
          paymobTransactionId,
        }),
      );

      return jsonResponse({
        success: true,
        ignored: true,
        message: 'Booking was not found for processed callback.',
      });
    }

    const { data: currentBooking, error: currentBookingError } = await adminClient
      .from('bookings')
      .select('id, booking_status, confirmed_at, cancelled_at')
      .eq('id', bookingLookupId)
      .maybeSingle();

    if (currentBookingError || !currentBooking) {
      throw new Error('Failed to load current booking row before callback update');
    }

    const paymentRow = await findTargetPayment(
      adminClient,
      bookingLookupId,
      paymobOrderId,
    );

    if (!paymentRow) {
      throw new Error('No booking payment row was found for callback update');
    }

    const now = new Date().toISOString();

    const bookingUpdate: Record<string, unknown> = {
      updated_at: now,
    };

    const paymentUpdate: Record<string, unknown> = {
      updated_at: now,
    };

    if (paymobOrderId) {
      bookingUpdate['paymob_order_id'] = paymobOrderId;
      paymentUpdate['paymob_order_id'] = paymobOrderId;
    }

    if (paymobTransactionId) {
      paymentUpdate['paymob_transaction_id'] = paymobTransactionId;
      paymentUpdate['transaction_ref'] = paymobTransactionId;
    }

    // ✅ Updated: pending callbacks should only persist refs, not finalize the booking.
    if (pending === true) {
      const { error: bookingPendingUpdateError } = await adminClient
        .from('bookings')
        .update(bookingUpdate)
        .eq('id', bookingLookupId);

      if (bookingPendingUpdateError) {
        throw new Error(
          `Failed to update booking refs for pending callback: ${bookingPendingUpdateError.message}`,
        );
      }

      const { error: paymentPendingUpdateError } = await adminClient
        .from('booking_payments')
        .update(paymentUpdate)
        .eq('id', paymentRow.id);

      if (paymentPendingUpdateError) {
        throw new Error(
          `Failed to update payment refs for pending callback: ${paymentPendingUpdateError.message}`,
        );
      }

      return jsonResponse({
        success: true,
        booking_id: bookingLookupId,
        pending: true,
        paymob_order_id: paymobOrderId,
        paymob_transaction_id: paymobTransactionId,
      });
    }

    const currentBookingStatus = String(currentBooking['booking_status'] ?? '');

    // ✅ Updated: protect already-confirmed bookings from stale failure callbacks.
    if (
      currentBookingStatus === 'confirmed' &&
      success !== true &&
      isVoided !== true &&
      isRefunded !== true
    ) {
      await adminClient.from('bookings').update(bookingUpdate).eq('id', bookingLookupId);
      await adminClient.from('booking_payments').update(paymentUpdate).eq('id', paymentRow.id);

      return jsonResponse({
        success: true,
        ignored: true,
        booking_id: bookingLookupId,
        message: 'Ignoring stale non-success callback for an already confirmed booking.',
      });
    }

    let nextBookingStatus: 'confirmed' | 'failed' | 'cancelled';
    let nextPaymentStatus: 'success' | 'failed';

    if (success === true && isVoided !== true && isRefunded !== true) {
      nextBookingStatus = 'confirmed';
      nextPaymentStatus = 'success';

      bookingUpdate['booking_status'] = nextBookingStatus;
      bookingUpdate['payment_status'] = nextPaymentStatus;
      bookingUpdate['confirmed_at'] = currentBooking['confirmed_at'] ?? now;
      bookingUpdate['cancelled_at'] = null;
    } else if (isVoided === true || isRefunded === true) {
      nextBookingStatus = 'cancelled';
      nextPaymentStatus = 'failed';

      bookingUpdate['booking_status'] = nextBookingStatus;
      bookingUpdate['payment_status'] = nextPaymentStatus;
      bookingUpdate['cancelled_at'] = currentBooking['cancelled_at'] ?? now;
    } else {
      nextBookingStatus = 'failed';
      nextPaymentStatus = 'failed';

      bookingUpdate['booking_status'] = nextBookingStatus;
      bookingUpdate['payment_status'] = nextPaymentStatus;
      bookingUpdate['cancelled_at'] = currentBooking['cancelled_at'] ?? now;
    }

    paymentUpdate['payment_status'] = nextPaymentStatus;

    const { error: bookingUpdateError } = await adminClient
      .from('bookings')
      .update(bookingUpdate)
      .eq('id', bookingLookupId);

    if (bookingUpdateError) {
      throw new Error(`Failed to update booking row: ${bookingUpdateError.message}`);
    }

    const { error: paymentUpdateError } = await adminClient
      .from('booking_payments')
      .update(paymentUpdate)
      .eq('id', paymentRow.id);

    if (paymentUpdateError) {
      throw new Error(
        `Failed to update booking payment row: ${paymentUpdateError.message}`,
      );
    }

    console.log(
      JSON.stringify({
        stage: 'processed-callback-updated',
        bookingId: bookingLookupId,
        paymobOrderId,
        paymobTransactionId,
        bookingStatus: nextBookingStatus,
        paymentStatus: nextPaymentStatus,
      }),
    );

    return jsonResponse({
      success: true,
      booking_id: bookingLookupId,
      booking_status: nextBookingStatus,
      payment_status: nextPaymentStatus,
      paymob_order_id: paymobOrderId,
      paymob_transaction_id: paymobTransactionId,
    });
  } catch (error) {
    console.error(
      JSON.stringify({
        stage: 'processed-callback-unhandled-error',
        error: error instanceof Error ? error.message : String(error),
      }),
    );

    return errorResponse(
      error instanceof Error
        ? error.message
        : 'Unexpected processed callback error',
      500,
    );
  }
});