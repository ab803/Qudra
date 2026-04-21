// This file verifies the Paymob HMAC for processed and response callbacks.
function normalizeValue(value: unknown): string {
  if (value === null || value === undefined) return '';
  if (typeof value === 'boolean') return value ? 'true' : 'false';
  return String(value);
}

// This helper converts an ArrayBuffer into a lowercase hexadecimal string.
function bufferToHex(buffer: ArrayBuffer): string {
  return Array.from(new Uint8Array(buffer))
    .map((byte) => byte.toString(16).padStart(2, '0'))
    .join('');
}

// This helper creates a SHA-512 HMAC hash from a plain text string.
async function createSha512Hmac(
  message: string,
  secret: string,
): Promise<string> {
  const encoder = new TextEncoder();

  const key = await crypto.subtle.importKey(
    'raw',
    encoder.encode(secret),
    { name: 'HMAC', hash: 'SHA-512' },
    false,
    ['sign'],
  );

  const signature = await crypto.subtle.sign(
    'HMAC',
    key,
    encoder.encode(message),
  );

  return bufferToHex(signature);
}

// This helper converts any unknown object-like value into a safe record.
function asRecord(value: unknown): Record<string, unknown> {
  if (typeof value === 'object' && value !== null) {
    return value as Record<string, unknown>;
  }
  return {};
}

// This helper builds the canonical HMAC string for processed callbacks.
function buildProcessedCallbackMessage(payload: Record<string, unknown>): string {
  const obj =
    typeof payload['obj'] === 'object' && payload['obj'] !== null
      ? (payload['obj'] as Record<string, unknown>)
      : payload;

  const order = asRecord(obj['order']);
  const sourceData = asRecord(obj['source_data']);

  const orderedValues = [
    obj['amount_cents'],
    obj['created_at'],
    obj['currency'],
    obj['error_occured'],
    obj['has_parent_transaction'],
    obj['id'],
    obj['integration_id'],
    obj['is_3d_secure'],
    obj['is_auth'],
    obj['is_capture'],
    obj['is_refunded'],
    obj['is_standalone_payment'],
    obj['is_voided'],
    order['id'],
    obj['owner'],
    obj['pending'],
    sourceData['pan'],
    sourceData['sub_type'],
    sourceData['type'],
    obj['success'],
  ];

  return orderedValues.map(normalizeValue).join('');
}

// This helper builds the canonical HMAC string for response callbacks.
function buildResponseCallbackMessage(query: URLSearchParams): string {
  const orderedValues = [
    query.get('amount_cents'),
    query.get('created_at'),
    query.get('currency'),
    query.get('error_occured'),
    query.get('has_parent_transaction'),
    query.get('id'),
    query.get('integration_id'),
    query.get('is_3d_secure'),
    query.get('is_auth'),
    query.get('is_capture'),
    query.get('is_refunded'),
    query.get('is_standalone_payment'),
    query.get('is_voided'),
    query.get('order_id'),
    query.get('owner'),
    query.get('pending'),
    query.get('source_data.pan'),
    query.get('source_data.sub_type'),
    query.get('source_data.type'),
    query.get('success'),
  ];

  return orderedValues.map(normalizeValue).join('');
}

// This function validates the HMAC attached to a processed callback request.
export async function verifyProcessedCallbackHmac(
  payload: Record<string, unknown>,
  receivedHmac: string,
): Promise<boolean> {
  const secret = Deno.env.get('PAYMOB_HMAC_SECRET');
  if (!secret || !receivedHmac) return false;

  const message = buildProcessedCallbackMessage(payload);
  const calculated = await createSha512Hmac(message, secret);

  return calculated.toLowerCase() === receivedHmac.toLowerCase();
}

// This function validates the HMAC attached to a browser response callback request.
export async function verifyResponseCallbackHmac(
  query: URLSearchParams,
  receivedHmac: string,
): Promise<boolean> {
  const secret = Deno.env.get('PAYMOB_HMAC_SECRET');
  if (!secret || !receivedHmac) return false;

  const message = buildResponseCallbackMessage(query);
  const calculated = await createSha512Hmac(message, secret);

  return calculated.toLowerCase() === receivedHmac.toLowerCase();
}
