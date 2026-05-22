import { NextRequest, NextResponse } from 'next/server';

import {
  KAKAO_ACCESS_TOKEN_COOKIE,
  KAKAO_STATE_COOKIE,
  exchangeKakaoCode,
} from '../../../../../src/kakao';

export const runtime = 'nodejs';

export async function GET(request: NextRequest) {
  const code = request.nextUrl.searchParams.get('code');
  const state = request.nextUrl.searchParams.get('state');
  const expectedState = request.cookies.get(KAKAO_STATE_COOKIE)?.value;

  if (!code) {
    return NextResponse.json({ error: 'missing_code' }, { status: 400 });
  }

  if (!state || state !== expectedState) {
    return NextResponse.json({ error: 'invalid_state' }, { status: 400 });
  }

  const token = await exchangeKakaoCode({
    code,
    origin: request.nextUrl.origin,
  });
  const response = NextResponse.redirect(new URL('/', request.url));

  response.cookies.set(KAKAO_ACCESS_TOKEN_COOKIE, token.access_token, {
    httpOnly: true,
    sameSite: 'lax',
    secure: request.nextUrl.protocol === 'https:',
    maxAge: token.expires_in,
    path: '/',
  });
  response.cookies.delete(KAKAO_STATE_COOKIE);

  return response;
}
