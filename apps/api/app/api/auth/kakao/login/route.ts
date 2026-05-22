import { NextRequest, NextResponse } from 'next/server';

import {
  KAKAO_STATE_COOKIE,
  buildKakaoAuthorizeUrl,
} from '../../../../../src/kakao';

export const runtime = 'nodejs';

export async function GET(request: NextRequest) {
  if (!process.env.KAKAO_REST_API_KEY) {
    return NextResponse.redirect(
      new URL('/?error=missing_kakao_config', request.url),
    );
  }

  const state = crypto.randomUUID();
  const authorizeUrl = buildKakaoAuthorizeUrl({
    origin: request.nextUrl.origin,
    state,
  });
  const response = NextResponse.redirect(authorizeUrl);

  response.cookies.set(KAKAO_STATE_COOKIE, state, {
    httpOnly: true,
    sameSite: 'lax',
    secure: request.nextUrl.protocol === 'https:',
    maxAge: 60 * 10,
    path: '/',
  });

  return response;
}
