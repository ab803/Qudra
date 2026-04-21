// This edge function receives the Paymob browser response callback (GET)
// and returns a browser page while persisting callback references.
// It also applies an explicit failure fallback when the user returns
// without completing the payment and the booking is still pending.

import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { createClient } from 'npm:@supabase/supabase-js@2';

import { corsHeaders, errorResponse } from '../_shared/cors.ts';
import { verifyResponseCallbackHmac } from '../_shared/hmac.ts';

// This helper creates an admin Supabase client for callback-driven status updates.
function createAdminClient() {
  return createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
  );
}

// This helper parses a boolean value from callback query params.
function parseBool(value: string | null): boolean | null {
  if (value == null) return null;

  const normalized = value.trim().toLowerCase();

  if (normalized === 'true') return true;
  if (normalized === 'false') return false;

  return null;
}

// This helper builds a small HTML response for the browser.
function htmlResponse(html: string, status = 200): Response {
  return new Response(html, {
    status,
    headers: {
      ...corsHeaders,
      'Content-Type': 'text/html; charset=utf-8',
    },
  });
}

// This helper updates only one target payment row instead of all rows for the booking.
async function findTargetPayment(
  adminClient: ReturnType<typeof createAdminClient>,
  bookingId: string,
  paymobOrderId: string | null,
) {
  if (paymobOrderId) {
    const { data, error } = await adminClient
      .from('booking_payments')
      .select('id')
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
    .select('id')
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

  if (req.method !== 'GET') {
    return errorResponse('Method not allowed', 405);
  }

  try {
    const adminClient = createAdminClient();
    const url = new URL(req.url);
    const query = url.searchParams;

    const receivedHmac = query.get('hmac') ?? '';

    // Validate the browser response callback HMAC.
    const isValidHmac = await verifyResponseCallbackHmac(query, receivedHmac);
    if (!isValidHmac) {
      console.error('Response callback HMAC verification failed');
      return htmlResponse('<h1>Invalid payment callback.</h1>', 401);
    }

    // Use signed Paymob identifiers inside the browser callback.
    const paymobOrderId = query.get('order_id') ?? query.get('order');
    const paymobTransactionId = query.get('id');
    const success = parseBool(query.get('success'));
    const pending = parseBool(query.get('pending'));

    console.log(
      JSON.stringify({
        stage: 'response-callback-received',
        paymobOrderId,
        paymobTransactionId,
        success,
        pending,
      }),
    );

    let explicitFailureApplied = false;

    if (paymobOrderId) {
      const { data: booking, error: bookingLookupError } = await adminClient
        .from('bookings')
        .select('id, booking_status, cancelled_at')
        .eq('paymob_order_id', paymobOrderId)
        .maybeSingle();

      if (bookingLookupError) {
        throw new Error(
          `Failed to lookup booking by Paymob order ID: ${bookingLookupError.message}`,
        );
      }

      if (booking?.id) {
        const paymentRow = await findTargetPayment(
          adminClient,
          booking.id,
          paymobOrderId,
        );

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

        // ✅ Updated: if the user returns from checkout with an explicit failure
        // and the booking is still pending, fail it immediately instead of waiting
        // for the processing screen to end with a pending result.
        const isExplicitFailure =
          success === false &&
          pending === false &&
          booking['booking_status'] === 'pending_payment';

        if (isExplicitFailure) {
          bookingUpdate['booking_status'] = 'failed';
          bookingUpdate['payment_status'] = 'failed';
          bookingUpdate['cancelled_at'] = booking['cancelled_at'] ?? now;

          paymentUpdate['payment_status'] = 'failed';

          explicitFailureApplied = true;
        }

        const { error: bookingUpdateError } = await adminClient
          .from('bookings')
          .update(bookingUpdate)
          .eq('id', booking.id);

        if (bookingUpdateError) {
          throw new Error(`Failed to update booking row: ${bookingUpdateError.message}`);
        }

        if (paymentRow?.id) {
          const { error: paymentUpdateError } = await adminClient
            .from('booking_payments')
            .update(paymentUpdate)
            .eq('id', paymentRow.id);

          if (paymentUpdateError) {
            throw new Error(
              `Failed to update booking payment row: ${paymentUpdateError.message}`,
            );
          }
        }

        console.log(
          JSON.stringify({
            stage: 'response-callback-updated',
            bookingId: booking.id,
            paymobOrderId,
            paymobTransactionId,
            success,
            pending,
            explicitFailureApplied,
          }),
        );
      } else {
        console.warn(
          JSON.stringify({
            stage: 'response-callback-booking-not-found',
            paymobOrderId,
            paymobTransactionId,
          }),
        );
      }
    }

    const isSuccess = success === true && pending === false;
    const isStillPending = pending === true;

    const title = isSuccess
      ? 'Payment completed'
      : isStillPending
          ? 'Payment is still processing'
          : 'Payment not completed';

    const message = isSuccess
      ? 'You can now return to the app.'
      : isStillPending
          ? 'Please return to the app while we finish verifying your booking.'
          : 'Please return to the app to view the updated booking status.';

    return htmlResponse(`
      <!DOCTYPE html>
      <html lang="en">
        <head>
          <meta charset="UTF-8" />
          <meta name="viewport" content="width=device-width, initial-scale=1.0" />
          <title>${title}</title>
          <style>
            body {
              font-family: Arial, sans-serif;
              background: #f7f8fa;
              color: #111;
              display: flex;
              align-items: center;
              justify-content: center;
              min-height: 100vh;
              margin: 0;
              padding: 24px;
              text-align: center;
            }
            .card {
              background: white;
              border-radius: 20px;
              padding: 24px;
              max-width: 420px;
              width: 100%;
              box-shadow: 0 8px 24px rgba(0,0,0,0.06);
            }
            h1 {
              margin-top: 0;
            }
            p {
              color: #555;
              line-height: 1.6;
            }
          </style>
        </head>
        <body>
          <div class="card">
            <h1>${title}</h1>
            <p>${message}</p>
          </div>
        </body>
      </html>
    `);
  } catch (error) {
    console.error(
      JSON.stringify({
        stage: 'response-callback-unhandled-error',
        error: error instanceof Error ? error.message : String(error),
      }),
    );

    return htmlResponse('<h1>Unexpected payment callback error.</h1>', 500);
  }
});