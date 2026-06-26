import { cookies } from 'next/headers';

import { KAKAO_ACCESS_TOKEN_COOKIE, getKakaoUser } from '../src/kakao';

type HomePageProps = {
  searchParams?: Promise<{
    error?: string;
  }>;
};

export default async function HomePage({ searchParams }: HomePageProps) {
  const params = await searchParams;
  const cookieStore = await cookies();
  const accessToken = cookieStore.get(KAKAO_ACCESS_TOKEN_COOKIE)?.value;
  const user = accessToken ? await getKakaoUser(accessToken).catch(() => null) : null;
  const profile = user?.kakao_account?.profile;
  const errorMessage =
    params?.error === 'missing_kakao_config'
      ? 'KAKAO_REST_API_KEY를 .env.local에 설정한 뒤 다시 시도하세요.'
      : null;

  return (
    <main className="page-shell">
      <section className="hero">
        <div>
          <p className="eyebrow">Favis API</p>
          <h1>카카오 로그인 테스트</h1>
          <p className="description">
            Next.js API 서버에서 카카오 OAuth 로그인을 처리하고, 서버에서
            <code>/v2/user/me</code> 응답을 조회해 표시합니다.
          </p>
        </div>
        {user ? (
          <a className="secondary-button" href="/api/auth/logout">
            로그아웃
          </a>
        ) : (
          <a className="kakao-button" href="/api/auth/kakao/login">
            카카오로 로그인
          </a>
        )}
      </section>

      <section className="panel">
        {errorMessage ? <p className="error-banner">{errorMessage}</p> : null}
        {user ? (
          <>
            <div className="profile-row">
              {profile?.thumbnail_image_url ? (
                // eslint-disable-next-line @next/next/no-img-element
                <img
                  alt=""
                  className="avatar"
                  src={profile.thumbnail_image_url}
                />
              ) : (
                <div className="avatar-fallback">K</div>
              )}
              <div>
                <p className="label">로그인 사용자</p>
                <h2>{profile?.nickname ?? user.kakao_account?.email ?? user.id}</h2>
              </div>
            </div>
            <dl className="details">
              <div>
                <dt>Kakao ID</dt>
                <dd>{user.id}</dd>
              </div>
              <div>
                <dt>Email</dt>
                <dd>{user.kakao_account?.email ?? '동의 또는 제공 전'}</dd>
              </div>
              <div>
                <dt>Connected At</dt>
                <dd>{user.connected_at ?? '없음'}</dd>
              </div>
            </dl>
            <pre>{JSON.stringify(user, null, 2)}</pre>
          </>
        ) : (
          <div className="empty-state">
            <p className="label">대기 중</p>
            <h2>아직 로그인하지 않았습니다.</h2>
            <p>카카오 로그인 후 user/me 응답이 이 영역에 표시됩니다.</p>
          </div>
        )}
      </section>
    </main>
  );
}
