import type { KakaoUser } from './kakao';
import { getSupabaseAdmin } from './supabase';

type AppUser = {
  id: string;
  nickname: string;
  last_login_at: string | null;
  created_at: string;
  updated_at: string;
};

const KAKAO_PROVIDER = 'kakao';

export async function findOrCreateUserFromKakao(kakaoUser: KakaoUser) {
  const supabase = getSupabaseAdmin();
  const providerId = String(kakaoUser.id);
  const nickname = getNickname(kakaoUser);
  const now = new Date().toISOString();

  const { data: authentication, error: authenticationError } = await supabase
    .from('authentications')
    .select('user_id')
    .eq('oauth_provider', KAKAO_PROVIDER)
    .eq('oauth_provider_id', providerId)
    .maybeSingle();

  if (authenticationError) {
    throw authenticationError;
  }

  if (authentication?.user_id) {
    const { data: user, error: userError } = await supabase
      .from('users')
      .update({
        nickname,
        last_login_at: now,
      })
      .eq('id', authentication.user_id)
      .select('*')
      .single();

    if (userError) {
      throw userError;
    }

    return user as AppUser;
  }

  const { data: user, error: createUserError } = await supabase
    .from('users')
    .insert({
      nickname,
      last_login_at: now,
    })
    .select('*')
    .single();

  if (createUserError) {
    throw createUserError;
  }

  const { error: createAuthenticationError } = await supabase
    .from('authentications')
    .insert({
      user_id: user.id,
      oauth_provider: KAKAO_PROVIDER,
      oauth_provider_id: providerId,
    });

  if (createAuthenticationError) {
    throw createAuthenticationError;
  }

  return user as AppUser;
}

export async function getUserById(userId: string) {
  const supabase = getSupabaseAdmin();
  const { data, error } = await supabase
    .from('users')
    .select('*')
    .eq('id', userId)
    .maybeSingle();

  if (error) {
    throw error;
  }

  return data as AppUser | null;
}

function getNickname(kakaoUser: KakaoUser) {
  return (
    kakaoUser.kakao_account?.profile?.nickname ??
    kakaoUser.properties?.nickname ??
    `kakao-${kakaoUser.id}`
  );
}
