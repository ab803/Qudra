// This file provides common CORS headers and JSON helpers for edge functions.
export const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
};

// This helper builds a JSON response with the common headers.
export function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...corsHeaders,
      'Content-Type': 'application/json',
    },
  });
}

// This helper builds a standard error response object.
export function errorResponse(message: string, status = 400): Response {
  return jsonResponse({ success: false, error: message }, status);
}