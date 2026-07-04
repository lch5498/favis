import { createRemoteJWKSet, jwtVerify } from 'jose';

const APPLE_ISSUER = 'https://appleid.apple.com';
const APPLE_JWKS = createRemoteJWKSet(
  new URL('https://appleid.apple.com/auth/keys'),
);

export type AppleUser = {
  sub: string;
  email?: string;
};

export async function verifyAppleIdentityToken(identityToken: string) {
  const audience = process.env.APPLE_CLIENT_ID ?? 'com.family.checky.mobile';

  const { payload } = await jwtVerify(identityToken, APPLE_JWKS, {
    issuer: APPLE_ISSUER,
    audience,
  });

  if (typeof payload.sub !== 'string' || payload.sub.trim() === '') {
    throw new Error('invalid_apple_token');
  }

  return {
    sub: payload.sub,
    email: typeof payload.email === 'string' ? payload.email : undefined,
  } satisfies AppleUser;
}
