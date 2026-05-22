import { NextResponse } from 'next/server';

import {
  KAKAO_ACCESS_TOKEN_COOKIE,
  KAKAO_STATE_COOKIE,
} from '../../../../src/kakao';

export async function GET(request: Request) {
  const response = NextResponse.redirect(new URL('/', request.url));

  response.cookies.delete(KAKAO_ACCESS_TOKEN_COOKIE);
  response.cookies.delete(KAKAO_STATE_COOKIE);

  return response;
}
