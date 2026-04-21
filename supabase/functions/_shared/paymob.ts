// This file contains Paymob helpers for intention creation and checkout URL generation.
const PAYMOB_BASE_URL = 'https://accept.paymob.com';

// This type describes the minimum billing data required to start a Paymob intention.
export type PaymobBillingData = {
  first_name: string;
  last_name: string;
  email: string;
  phone_number: string;
  apartment: string;
  floor: string;
  street: string;
  building: string;
  city: string;
  country: string;
  state: string;
};

// This type describes the data required to create a Paymob intention.
export type CreatePaymobIntentionParams = {
  amountCents: number;
  paymentMethod: 'card' | 'wallet';
  billingData: PaymobBillingData;
  specialReference: string;
  notificationUrl: string;
  redirectionUrl: string;
  extras?: Record<string, unknown>;
};

// This helper reads a required environment variable and fails early when missing.
function requiredEnv(name: string): string {
  const value = Deno.env.get(name);
  if (!value || value.trim().length === 0) {
    throw new Error(`${name} is missing`);
  }
  return value;
}

// This helper selects the correct Paymob integration ID for the chosen method.
function getIntegrationId(paymentMethod: 'card' | 'wallet'): number {
  const raw =
    paymentMethod === 'card'
      ? requiredEnv('PAYMOB_CARD_INTEGRATION_ID')
      : requiredEnv('PAYMOB_WALLET_INTEGRATION_ID');

  const parsed = Number(raw);
  if (Number.isNaN(parsed)) {
    throw new Error(`Invalid integration ID for ${paymentMethod}`);
  }
  return parsed;
}

// This helper splits a full name into first and last name values for billing data.
export function splitFullName(fullName?: string | null): {
  firstName: string;
  lastName: string;
} {
  const safeName = (fullName ?? '').trim();

  if (safeName.length === 0) {
    return { firstName: 'Qudra', lastName: 'User' };
  }

  const parts = safeName
    .split(' ')
    .filter((part) => part.trim().length > 0);

  if (parts.length === 1) {
    return { firstName: parts[0], lastName: 'User' };
  }

  return {
    firstName: parts[0],
    lastName: parts.slice(1).join(' '),
  };
}

// This helper builds the billing payload expected by Paymob using the user profile row.
export function buildBillingData(
  profile: Record<string, unknown>,
): PaymobBillingData {
  const fullName =
    typeof profile['full_name'] === 'string'
      ? profile['full_name']
      : null;

  const email =
    typeof profile['email'] === 'string' &&
    profile['email'].trim().length > 0
      ? profile['email'].trim()
      : 'no-reply@qudra.app';

  const phoneNumber =
    typeof profile['phone'] === 'string' &&
    profile['phone'].trim().length > 0
      ? profile['phone'].trim()
      : '+201000000000';

  const { firstName, lastName } = splitFullName(fullName);

  return {
    first_name: firstName,
    last_name: lastName,
    email,
    phone_number: phoneNumber,
    apartment: 'NA',
    floor: 'NA',
    street: 'NA',
    building: 'NA',
    city: 'Cairo',
    country: 'EGY',
    state: 'Cairo',
  };
}

// This helper builds the hosted Paymob unified checkout URL from the returned client secret.
export function buildUnifiedCheckoutUrl(clientSecret: string): string {
  const publicKey = requiredEnv('PAYMOB_PUBLIC_KEY');
  const publicKeyEncoded = encodeURIComponent(publicKey);
  const clientSecretEncoded = encodeURIComponent(clientSecret);

  return `${PAYMOB_BASE_URL}/unifiedcheckout/?publicKey=${publicKeyEncoded}&clientSecret=${clientSecretEncoded}`;
}

// This helper creates a Paymob intention and returns the raw Paymob response.
export async function createPaymobIntention(
  params: CreatePaymobIntentionParams,
): Promise<Record<string, unknown>> {
  const secretKey = requiredEnv('PAYMOB_SECRET_KEY');
  const integrationId = getIntegrationId(params.paymentMethod);

  const payload: Record<string, unknown> = {
    amount: params.amountCents,
    currency: 'EGP',
    payment_methods: [integrationId],
    items: [],
    billing_data: params.billingData,
    special_reference: params.specialReference,
    expiration: 3600,
    redirection_url: params.redirectionUrl,
    extras: params.extras ?? {},
  };

  // This field is kept for card flows because Paymob documents notification_url support there.
  if (params.paymentMethod === 'card') {
    payload['notification_url'] = params.notificationUrl;
  }

  const response = await fetch(`${PAYMOB_BASE_URL}/v1/intention/`, {
    method: 'POST',
    headers: {
      Authorization: `Token ${secretKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(payload),
  });

  const data = await response.json();

  if (!response.ok) {
    const detail =
      typeof data?.detail === 'string'
        ? data.detail
        : typeof data?.message === 'string'
            ? data.message
            : 'Paymob intention creation failed';

    throw new Error(detail);
  }

  return data as Record<string, unknown>;
}