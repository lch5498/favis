export const KAKAO_ACCESS_TOKEN_COOKIE = 'hk_kakao_access_token';
export const KAKAO_STATE_COOKIE = 'hk_kakao_oauth_state';

export type KakaoTokenResponse = {
  token_type: string;
  access_token: string;
  expires_in: number;
  refresh_token?: string;
  refresh_token_expires_in?: number;
  scope?: string;
};

export type KakaoUser = {
  id: number;
  connected_at?: string;
  properties?: Record<string, string>;
  kakao_account?: {
    profile_needs_agreement?: boolean;
    profile?: {
      nickname?: string;
      thumbnail_image_url?: string;
      profile_image_url?: string;
      is_default_image?: boolean;
    };
    name_needs_agreement?: boolean;
    name?: string;
    email_needs_agreement?: boolean;
    is_email_valid?: boolean;
    is_email_verified?: boolean;
    email?: string;
  };
};

export function getKakaoRestApiKey() {
  const key = process.env.KAKAO_REST_API_KEY;

  if (!key) {
    throw new Error('Missing KAKAO_REST_API_KEY');
  }

  return key;
}

export function getKakaoRedirectUri(origin: string) {
  return process.env.KAKAO_REDIRECT_URI ?? `${origin}/api/auth/kakao/callback`;
}

export function buildKakaoAuthorizeUrl({
  origin,
  state,
}: {
  origin: string;
  state: string;
}) {
  const url = new URL('https://kauth.kakao.com/oauth/authorize');
  url.searchParams.set('client_id', getKakaoRestApiKey());
  url.searchParams.set('redirect_uri', getKakaoRedirectUri(origin));
  url.searchParams.set('response_type', 'code');
  url.searchParams.set('state', state);

  return url;
}

export async function exchangeKakaoCode({
  code,
  origin,
}: {
  code: string;
  origin: string;
}) {
  const body = new URLSearchParams({
    grant_type: 'authorization_code',
    client_id: getKakaoRestApiKey(),
    redirect_uri: getKakaoRedirectUri(origin),
    code,
  });

  if (process.env.KAKAO_CLIENT_SECRET) {
    body.set('client_secret', process.env.KAKAO_CLIENT_SECRET);
  }

  const response = await fetch('https://kauth.kakao.com/oauth/token', {
    method: 'POST',
    headers: {
      'content-type': 'application/x-www-form-urlencoded;charset=utf-8',
    },
    body,
  });

  if (!response.ok) {
    const details = await response.text();
    throw new Error(`Kakao token exchange failed: ${details}`);
  }

  return response.json() as Promise<KakaoTokenResponse>;
}

export async function getKakaoUser(accessToken: string) {
  const response = await fetch('https://kapi.kakao.com/v2/user/me', {
    headers: {
      authorization: `Bearer ${accessToken}`,
      'content-type': 'application/x-www-form-urlencoded;charset=utf-8',
    },
    cache: 'no-store',
  });

  if (!response.ok) {
    const details = await response.text();
    throw new Error(`Kakao user/me failed: ${details}`);
  }

  return response.json() as Promise<KakaoUser>;
}
