import { createHmac, timingSafeEqual } from 'node:crypto';

const SESSION_TTL_SECONDS = 60 * 60 * 24 * 30;

type SessionPayload = {
  sub: string;
  exp: number;
};

export function createSessionToken(userId: string) {
  const payload: SessionPayload = {
    sub: userId,
    exp: Math.floor(Date.now() / 1000) + SESSION_TTL_SECONDS,
  };
  const encodedPayload = base64UrlEncode(JSON.stringify(payload));
  const signature = sign(encodedPayload);

  return `${encodedPayload}.${signature}`;
}

export function verifySessionToken(token: string) {
  const [encodedPayload, signature] = token.split('.');

  if (!encodedPayload || !signature) {
    return null;
  }

  const expectedSignature = sign(encodedPayload);

  if (!safeEqual(signature, expectedSignature)) {
    return null;
  }

  const payload = parsePayload(encodedPayload);

  if (!payload?.sub || payload.exp < Math.floor(Date.now() / 1000)) {
    return null;
  }

  return payload;
}

export function getBearerToken(request: Request) {
  const authorization = request.headers.get('authorization');

  if (!authorization?.startsWith('Bearer ')) {
    return null;
  }

  return authorization.slice('Bearer '.length).trim();
}

export function getSessionTtlSeconds() {
  return SESSION_TTL_SECONDS;
}

function sign(value: string) {
  return createHmac('sha256', getSessionSecret()).update(value).digest('base64url');
}

function getSessionSecret() {
  const secret = process.env.SESSION_SECRET;

  if (!secret) {
    throw new Error('Missing SESSION_SECRET');
  }

  return secret;
}

function base64UrlEncode(value: string) {
  return Buffer.from(value, 'utf8').toString('base64url');
}

function base64UrlDecode(value: string) {
  return Buffer.from(value, 'base64url').toString('utf8');
}

function parsePayload(encodedPayload: string) {
  try {
    return JSON.parse(base64UrlDecode(encodedPayload)) as SessionPayload;
  } catch {
    return null;
  }
}

function safeEqual(left: string, right: string) {
  const leftBuffer = Buffer.from(left);
  const rightBuffer = Buffer.from(right);

  if (leftBuffer.length !== rightBuffer.length) {
    return false;
  }

  return timingSafeEqual(leftBuffer, rightBuffer);
}
