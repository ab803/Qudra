// This edge function creates a booking and starts a Paymob session when needed.
import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { createClient } from 'npm:@supabase/supabase-js@2';

import { corsHeaders, errorResponse, jsonResponse } from '../_shared/cors.ts';
import {
  buildBillingData,
  buildUnifiedCheckoutUrl,
  createPaymobIntention,
} from '../_shared/paymob.ts';

// This helper safely converts any unknown object-like value into a record.
function asRecord(value: unknown): Record<string, unknown> {
  if (typeof value === 'object' && value !== null) {
    return value as Record<string, unknown>;
  }
  return {};
}

// This helper extracts useful Paymob references from the intention response.
function extractPaymobReferences(paymobIntention: Record<string, unknown>) {
  const order = asRecord(paymobIntention['order']);

  const paymobOrderId =
    paymobIntention['order_id'] !== undefined &&
    paymobIntention['order_id'] !== null
      ? String(paymobIntention['order_id'])
      : order['id'] !== undefined && order['id'] !== null
          ? String(order['id'])
          : null;

  const paymobIntentionId =
    paymobIntention['id'] !== undefined && paymobIntention['id'] !== null
      ? String(paymobIntention['id'])
      : paymobIntention['intention_id'] !== undefined &&
          paymobIntention['intention_id'] !== null
            ? String(paymobIntention['intention_id'])
            : null;

  return {
    paymobOrderId,
    paymobIntentionId,
  };
}

// This helper creates a user-scoped Supabase client using the caller JWT.
function createUserClient(req: Request) {
  return createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_ANON_KEY')!,
    {
      global: {
        headers: {
          Authorization: req.headers.get('Authorization') ?? '',
        },
      },
    },
  );
}

// This helper creates an admin Supabase client for privileged backend operations.
function createAdminClient() {
  return createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
  );
}

// This helper validates the requested payment method before any DB writes happen.
function validatePaymentMethod(
  paymentMethod: string,
): 'card' | 'wallet' | 'cash_at_institution' {
  const supportedMethods = ['card', 'wallet', 'cash_at_institution'];
  if (!supportedMethods.includes(paymentMethod)) {
    throw new Error('Unsupported payment method');
  }

  return paymentMethod as 'card' | 'wallet' | 'cash_at_institution';
}

// This helper extracts the price that should be used for the booking.
function resolveServiceAmount(service: Record<string, unknown>): number {
  const isFree = Boolean(service['is_free']);
  if (isFree) return 0;

  const rawPrice = service['price'] as number | string | null;
  const amount = Number(rawPrice ?? 0);

  if (!Number.isFinite(amount) || amount < 0) {
    throw new Error('Invalid service price');
  }

  return amount;
}

// ✅ Updated: normalize optional notes so empty strings are stored as null.
function normalizeOptionalNotes(value: unknown): string | null {
  if (typeof value !== 'string') return null;

  const trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  if (req.method !== 'POST') {
    return errorResponse('Method not allowed', 405);
  }

  try {
    const userClient = createUserClient(req);
    const adminClient = createAdminClient();

    const {
      data: { user },
      error: authError,
    } = await userClient.auth.getUser();

    if (authError || !user) {
      return errorResponse('Unauthorized user', 401);
    }

    const {
      service_id,
      institution_id,
      requested_date,
      requested_time,
      notes,
      payment_method,
    } = await req.json();

    if (!service_id || !institution_id || !requested_date || !requested_time) {
      return errorResponse('Missing required booking fields', 400);
    }

    const selectedMethod = validatePaymentMethod(String(payment_method));
    const normalizedNotes = normalizeOptionalNotes(notes);

    // Load user profile
    const { data: profile, error: profileError } = await adminClient
      .from('people_with_disability')
      .select('full_name, email, phone')
      .eq('id', user.id)
      .maybeSingle();

    if (profileError || !profile) {
      return errorResponse('User profile was not found', 404);
    }

    // Load service
    const { data: service, error: serviceError } = await adminClient
      .from('services')
      .select('id, institution_id, is_active, is_free, price')
      .eq('id', service_id)
      .maybeSingle();

    if (serviceError || !service) {
      return errorResponse('Service was not found', 404);
    }

    if (String(service['institution_id']) !== String(institution_id)) {
      return errorResponse('Service does not belong to this institution', 400);
    }

    if (!Boolean(service['is_active'])) {
      return errorResponse('This service is currently inactive', 400);
    }

    const serviceAmount = resolveServiceAmount(service);
    const isCash = selectedMethod === 'cash_at_institution';
    const isZeroAmount = serviceAmount <= 0;

    // ✅ Updated: online bookings must start as pending to match the DB lifecycle.
    const initialBookingStatus =
      isCash || isZeroAmount ? 'confirmed' : 'pending_payment';

    // ✅ Updated: online payments must start as pending until Paymob callback finalizes them.
    const initialPaymentStatus = isCash
      ? 'cash_due'
      : isZeroAmount
          ? 'success'
          : 'pending';

    const initialProvider = isCash || isZeroAmount ? 'manual' : 'paymob';

    const { data: booking, error: bookingError } = await adminClient
      .from('bookings')
      .insert({
        user_id: user.id,
        institution_id,
        service_id,
        requested_date,
        requested_time,
        notes: normalizedNotes,
        amount: serviceAmount,
        booking_status: initialBookingStatus,
        payment_method: selectedMethod,
        payment_status: initialPaymentStatus,
        confirmed_at:
          initialBookingStatus === 'confirmed'
            ? new Date().toISOString()
            : null,
        updated_at: new Date().toISOString(),
      })
      .select()
      .single();

    if (bookingError || !booking) {
      return errorResponse('Failed to create booking', 500);
    }

    const { data: payment, error: paymentError } = await adminClient
      .from('booking_payments')
      .insert({
        booking_id: booking.id,
        provider: initialProvider,
        payment_method: selectedMethod,
        payment_status: initialPaymentStatus,
        amount: serviceAmount,
        updated_at: new Date().toISOString(),
      })
      .select()
      .single();

    if (paymentError || !payment) {
      return errorResponse('Failed to create booking payment row', 500);
    }

    if (isCash || isZeroAmount) {
      return jsonResponse({
        success: true,
        booking,
        payment,
        requires_redirect: false,
        checkout_url: null,
        message: isCash
          ? 'Booking confirmed and payment will be collected at the institution.'
          : 'Free booking confirmed successfully.',
      });
    }

    const processedCallbackUrl = Deno.env.get('PAYMOB_PROCESSED_CALLBACK_URL');
    const redirectionUrl = Deno.env.get('APP_PAYMENT_REDIRECTION_URL');

    if (!processedCallbackUrl || !redirectionUrl) {
      return errorResponse('Missing callback or redirection configuration', 500);
    }

    try {
      const billingData = buildBillingData(profile);

      const paymobIntention = await createPaymobIntention({
        amountCents: Math.round(serviceAmount * 100),
        paymentMethod: selectedMethod === 'card' ? 'card' : 'wallet',
        billingData,
        specialReference: String(booking.id),
        notificationUrl: processedCallbackUrl,
        redirectionUrl,
        extras: {
          booking_id: booking.id,
          booking_payment_id: payment.id,
          service_id,
          institution_id,
        },
      });

      const { paymobOrderId, paymobIntentionId } =
        extractPaymobReferences(paymobIntention);

      const bookingPatch: Record<string, unknown> = {
        updated_at: new Date().toISOString(),
      };

      const paymentPatch: Record<string, unknown> = {
        updated_at: new Date().toISOString(),
      };

      if (paymobOrderId) {
        bookingPatch['paymob_order_id'] = paymobOrderId;
        paymentPatch['paymob_order_id'] = paymobOrderId;
      }

      if (paymobIntentionId) {
        bookingPatch['paymob_intention_id'] = paymobIntentionId;
        paymentPatch['paymob_intention_id'] = paymobIntentionId;
      }

      const { error: bookingPatchError } = await adminClient
        .from('bookings')
        .update(bookingPatch)
        .eq('id', booking.id);

      if (bookingPatchError) {
        throw new Error('Failed to save booking Paymob references');
      }

      const { error: paymentPatchError } = await adminClient
        .from('booking_payments')
        .update(paymentPatch)
        .eq('id', payment.id);

      if (paymentPatchError) {
        throw new Error('Failed to save booking payment Paymob references');
      }

      const clientSecret = String(paymobIntention['client_secret'] ?? '');
      if (!clientSecret) {
        throw new Error('Paymob client secret was not returned');
      }

      const checkoutUrl = buildUnifiedCheckoutUrl(clientSecret);

      return jsonResponse({
        success: true,
        booking_id: booking.id,
        booking_payment_id: payment.id,
        paymob_order_id: paymobOrderId,
        paymob_intention_id: paymobIntentionId,
        requires_redirect: true,
        checkout_url: checkoutUrl,
        message: 'Booking session created successfully.',
      });
    } catch (onlineFlowError) {
      // ✅ Updated: if the online Paymob flow fails after creating DB rows,
      // persist an explicit failure instead of leaving rows pending/inconsistent.
      const failureTimestamp = new Date().toISOString();

      await adminClient
        .from('bookings')
        .update({
          booking_status: 'failed',
          payment_status: 'failed',
          cancelled_at: failureTimestamp,
          updated_at: failureTimestamp,
        })
        .eq('id', booking.id);

      await adminClient
        .from('booking_payments')
        .update({
          payment_status: 'failed',
          updated_at: failureTimestamp,
        })
        .eq('id', payment.id);

      throw onlineFlowError;
    }
  } catch (error) {
    return errorResponse(
      error instanceof Error ? error.message : 'Unexpected booking session error',
      500,
    );
  }
});
