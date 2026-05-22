# House Keeping

가족만 사용하는 housekeeping 앱입니다. 첫 MVP는 iOS Flutter 앱 홈 화면에서 아래 두 메뉴로 시작합니다.

- 학원 일정 관리
- 주차 관리

백엔드는 Supabase + Next.js API 서버를 Vercel에 배포하는 구조로 구성하고, 앱은 Flutter iOS 기반으로 개발합니다.

## 폴더 구조

```text
apps/
  api/       Next.js App Router 기반 백엔드 API
  mobile/    Flutter iOS 앱
packages/
  contracts/ API 요청/응답 스키마
supabase/
  migrations/ Supabase DB migration
docs/
  product-plan.md
  harness-engineering.md
harness/
  app-developer.md
  backend-developer.md
```

## 사전 준비

로컬에서 실행하려면 아래 도구가 필요합니다.

- Node.js 22 이상
- npm
- Flutter 3.41 이상
- Xcode
- iOS Simulator
- Vercel CLI 또는 `npx vercel`
- Supabase 프로젝트

현재 프로젝트는 macOS에서 iOS 우선으로 실행하는 흐름을 기준으로 작성되어 있습니다.

## 현재 완료된 상태

2026년 5월 22일 기준으로 아래 흐름까지 확인했습니다.

- GitHub `main` 브랜치 push 완료
- Next.js API 서버 Vercel Production 배포 완료
- Vercel Production API health check 확인 완료
- Supabase `users`, `authentications` 로그인 schema 준비
- 카카오 웹 로그인 테스트 완료
- Flutter 카카오 SDK 로그인 테스트 완료
- Flutter 앱에서 카카오 access token을 Next.js API로 전달하는 모바일 로그인 흐름 구현
- Flutter 앱을 iOS Simulator와 실제 iPhone 네이티브 환경에서 실행 확인
- 앱 UI는 Flutter Cupertino 위젯 중심으로 정리

현재 Production API 주소는 아래와 같습니다.

```text
https://api-one-ruby-46.vercel.app
```

health check:

```bash
curl https://api-one-ruby-46.vercel.app/api/health
```

## 빠르게 앱만 실행해보기

앱 로그인을 확인하려면 먼저 로컬 Next.js API 서버를 실행합니다.

```bash
cd /Users/changhwanlee/Documents/project/house-keeping
npm run dev:api
```

기본 주소는 `http://localhost:3000`입니다. 그 다음 카카오 네이티브 앱 키를 iOS 설정에 넣습니다.

카카오 개발자 콘솔의 iOS 플랫폼 Bundle ID에는 아래 값을 등록합니다.

```text
com.family.housekeeping.mobile
```

```bash
cd /Users/changhwanlee/Documents/project/house-keeping/apps/mobile
perl -pi -e 's/^KAKAO_NATIVE_APP_KEY=.*/KAKAO_NATIVE_APP_KEY=여기에_카카오_NATIVE_APP_KEY/' ios/Flutter/Debug.xcconfig
```

Flutter 실행 시에도 같은 네이티브 앱 키를 `--dart-define`으로 전달합니다.

```bash
cd /Users/changhwanlee/Documents/project/house-keeping/apps/mobile
flutter pub get
```

iOS는 먼저 Simulator를 실행해야 합니다.

```bash
flutter emulators
flutter emulators --launch apple_ios_simulator
```

Simulator가 열린 뒤 사용 가능한 기기 목록을 확인합니다.

```bash
flutter devices
```

예를 들어 `iPhone 17 Pro`가 보이면 아래처럼 실행합니다.

```bash
flutter run -d "iPhone 17 Pro" --dart-define=KAKAO_NATIVE_APP_KEY=여기에_카카오_NATIVE_APP_KEY
```

기기 이름으로 실행이 안 되면 `flutter devices`에 표시된 device id를 사용합니다.

```bash
flutter run -d <device-id>
```

참고로 `flutter run -d ios`는 보통 동작하지 않습니다. `ios`는 플랫폼 이름이고, Flutter가 실행 대상으로 인식하는 실제 기기 이름이나 device id가 필요합니다.

정상 실행되면 `카카오로 계속하기` 버튼이 있는 로그인 화면이 표시됩니다.

현재 Flutter 앱의 기본 API 주소는 iOS Simulator 기준 `http://localhost:3000`입니다. 다른 포트나 실제 iPhone에서 테스트하려면 실행 시 `API_BASE_URL`을 지정합니다.

```bash
flutter run -d "iPhone 17 Pro" \
  --dart-define=KAKAO_NATIVE_APP_KEY=여기에_카카오_NATIVE_APP_KEY \
  --dart-define=API_BASE_URL=http://localhost:3001

flutter run -d "iPhone 17 Pro" \
  --dart-define=KAKAO_NATIVE_APP_KEY=여기에_카카오_NATIVE_APP_KEY \
  --dart-define=API_BASE_URL=http://192.168.x.x:3000
```

Vercel에 배포된 API를 바라보게 하려면 아래처럼 실행합니다.

```bash
flutter run -d "iPhone 17 Pro" \
  --dart-define=KAKAO_NATIVE_APP_KEY=여기에_카카오_NATIVE_APP_KEY \
  --dart-define=API_BASE_URL=https://api-one-ruby-46.vercel.app
```

앱 첫 화면에서 `카카오로 계속하기`를 누르면 카카오 로그인 후 SDK가 받은 access token을 Next.js `/api/mobile/auth/kakao`로 전달합니다. 서버는 `users`와 `authentications`를 생성 또는 갱신하고 자체 session token을 반환합니다.

### iOS Simulator가 보이지 않을 때

현재 기기에 설치된 iOS Simulator 목록은 아래 명령으로 확인할 수 있습니다.

```bash
xcrun simctl list devices available
```

Simulator가 설치되어 있는데 모두 `Shutdown` 상태라면 하나를 직접 부팅할 수 있습니다.

```bash
xcrun simctl boot "iPhone 17 Pro"
open -a Simulator
flutter devices
flutter run -d "iPhone 17 Pro"
```

그래도 iOS 기기가 나오지 않으면 Xcode에서 `Settings > Platforms`로 이동해 iOS Simulator runtime이 설치되어 있는지 확인합니다.

### 실제 iPhone에서 실행하기

실제 iPhone에서 실행하려면 Simulator와 달리 Apple 코드사이닝 설정이 필요합니다.

먼저 iPhone을 USB 또는 Wi-Fi로 연결하고, 기기에서 신뢰 팝업을 승인합니다. `flutter devices`에서 실제 기기가 보이는지 확인합니다.

```bash
cd /Users/changhwanlee/Documents/project/house-keeping/apps/mobile
flutter devices
```

기기가 `unpaired` 상태로 보이면 Xcode에서 페어링을 완료합니다.

1. Xcode 실행
2. `Window > Devices and Simulators`
3. 연결된 iPhone 선택
4. Pairing 요청 승인
5. iPhone 화면의 신뢰 또는 개발자 모드 안내 승인

그 다음 Flutter iOS 프로젝트를 Xcode로 엽니다.

```bash
cd /Users/changhwanlee/Documents/project/house-keeping/apps/mobile
open ios/Runner.xcworkspace
```

Xcode에서 아래 설정을 확인합니다.

- `Runner` project 선택
- `Runner` target 선택
- `Signing & Capabilities` 탭 이동
- `Automatically manage signing` 체크
- `Team`에 본인 Apple ID 또는 Apple Developer Team 선택
- Bundle ID가 카카오 개발자 콘솔의 iOS 플랫폼 Bundle ID와 같은지 확인

무료 Apple ID로도 실기기 디버그 실행은 가능하지만, Xcode가 Development Certificate와 Provisioning Profile을 자동 생성해야 합니다.

설정이 끝나면 다시 Flutter에서 실행합니다.

```bash
flutter run -d "iPhone 이름 또는 device id" \
  --dart-define=KAKAO_NATIVE_APP_KEY=여기에_카카오_NATIVE_APP_KEY \
  --dart-define=API_BASE_URL=https://api-one-ruby-46.vercel.app
```

처음 설치한 뒤 iPhone에서 개발자 인증서를 신뢰해야 할 수 있습니다.

```text
설정 > 일반 > VPN 및 기기 관리 > Developer App > 신뢰
```

실제 iPhone은 Mac의 `localhost`를 바라볼 수 없습니다. 실기기에서는 Vercel Production API를 사용하거나, 같은 Wi-Fi에서 Mac의 내부 IP 주소를 `API_BASE_URL`로 넘겨야 합니다.

## 전체 프로젝트 설치

루트에서 Node 의존성을 설치합니다.

```bash
cd /Users/changhwanlee/Documents/project/house-keeping
npm install
```

Flutter 의존성은 모바일 앱 폴더에서 받습니다.

```bash
cd /Users/changhwanlee/Documents/project/house-keeping/apps/mobile
flutter pub get
```

## 환경변수

루트의 `.env.example`을 기준으로 환경변수를 준비합니다.

```bash
SUPABASE_URL=
SUPABASE_SECRET_KEY=
SUPABASE_PUBLISHABLE_KEY=
KAKAO_REST_API_KEY=
KAKAO_CLIENT_SECRET=
KAKAO_REDIRECT_URI=http://localhost:3000/api/auth/kakao/callback
SESSION_SECRET=
```

중요한 규칙:

- `SUPABASE_SECRET_KEY`는 서버 전용입니다.
- Flutter 앱에는 secret key를 절대 넣지 않습니다.
- `SUPABASE_PUBLISHABLE_KEY`는 공개 가능한 키이지만, 현재 Flutter 앱은 Next.js API만 호출하므로 아직 사용하지 않습니다.
- 실제 secret 값은 `.env.local`이나 Vercel Environment Variables에만 저장합니다.
- `.env.local`은 커밋하지 않습니다.
- `KAKAO_CLIENT_SECRET`은 카카오 개발자 콘솔에서 client secret이 활성화된 경우 넣습니다.
- `SESSION_SECRET`은 모바일 앱용 자체 세션 토큰 서명에 사용합니다. 충분히 긴 랜덤 문자열을 사용합니다.

로컬에서 직접 `.env.local`을 만들려면:

```bash
cd /Users/changhwanlee/Documents/project/house-keeping
cp .env.example .env.local
```

그 다음 `.env.local`에 Supabase 값을 채웁니다.

Vercel 프로젝트를 연결한 뒤 환경변수를 내려받으려면:

```bash
cd /Users/changhwanlee/Documents/project/house-keeping
npx vercel link
npx vercel env pull .env.local --yes
```

## Supabase DB 준비

Supabase 프로젝트를 만든 뒤 우선 로그인용 migration 파일을 적용합니다.

```text
supabase/migrations/202605180001_add_users_and_authentications.sql
```

가장 간단한 방법은 Supabase Dashboard에서 SQL Editor를 열고 migration SQL을 실행하는 것입니다.

Supabase CLI를 사용하는 경우에는 프로젝트 연결 후 migration을 적용합니다.

```bash
cd /Users/changhwanlee/Documents/project/house-keeping
supabase link --project-ref <project-ref>
supabase db push
```

초기 로그인 schema에는 아래 테이블이 포함됩니다.

- `users`
- `authentications`

Row Level Security는 켜져 있습니다. 현재 Vercel API는 서버에서 Supabase secret key를 사용하므로 모바일 앱이 DB에 직접 접근하지 않습니다.

## 백엔드 API 실행

백엔드는 Next.js API 서버로 실행합니다. 루트에서 API dev server를 실행합니다.

```bash
cd /Users/changhwanlee/Documents/project/house-keeping
npm run dev:api
```

또는 API 앱 폴더에서 직접 실행할 수 있습니다.

```bash
cd /Users/changhwanlee/Documents/project/house-keeping/apps/api
npm run dev
```

기본 Next.js dev server 주소는 `http://localhost:3000`입니다. 이미 3000번 포트가 사용 중이면 Next.js가 `http://localhost:3001`처럼 다른 포트를 안내합니다. health check는 아래처럼 확인합니다.

```bash
curl http://localhost:3000/api/health
```

예상 응답:

```json
{
  "ok": true,
  "service": "family-housekeeping-api",
  "framework": "nextjs"
}
```

## 카카오 로그인 실행

카카오 개발자 콘솔에서 앱을 만든 뒤 아래 값을 확인합니다.

- REST API 키
- Client Secret 사용 여부
- Redirect URI

로컬 테스트용 Redirect URI는 카카오 개발자 콘솔에 아래 값으로 등록합니다.

```text
http://localhost:3000/api/auth/kakao/callback
```

그 다음 `.env.local`에 값을 넣습니다.

```bash
KAKAO_REST_API_KEY=<카카오 REST API 키>
KAKAO_CLIENT_SECRET=<client secret 사용 시 입력>
KAKAO_REDIRECT_URI=http://localhost:3000/api/auth/kakao/callback
```

API 서버를 실행합니다.

```bash
cd /Users/changhwanlee/Documents/project/house-keeping
npm run dev:api
```

브라우저에서 아래 주소를 엽니다.

```text
http://localhost:3000
```

`카카오로 로그인` 버튼을 누르면 카카오 로그인 화면으로 이동합니다. 로그인 후 돌아오면 Next.js 서버가 카카오 `user/me` API를 호출하고, 홈 화면에 사용자 정보를 표시합니다.

## Flutter 앱 인증 API

Flutter 앱은 카카오 Flutter SDK로 카카오 access token을 받은 뒤, Next.js 서버에 전달합니다. 서버는 다시 카카오 `user/me`를 호출해 토큰을 검증하고, `users`와 `authentications` 테이블을 생성 또는 갱신한 뒤 자체 session token을 반환합니다.

로그인:

```http
POST /api/mobile/auth/kakao
content-type: application/json

{
  "accessToken": "<kakao access token>"
}
```

응답:

```json
{
  "tokenType": "Bearer",
  "accessToken": "<house keeping session token>",
  "expiresIn": 2592000,
  "user": {
    "id": "uuid",
    "nickname": "nickname",
    "last_login_at": "2026-05-18T00:00:00.000Z",
    "created_at": "2026-05-18T00:00:00.000Z",
    "updated_at": "2026-05-18T00:00:00.000Z"
  }
}
```

현재 로그인 사용자 확인:

```http
GET /api/mobile/auth/me
authorization: Bearer <house keeping session token>
```

로그아웃:

```http
POST /api/mobile/auth/logout
authorization: Bearer <house keeping session token>
```

로그아웃 API는 서버 세션 저장소를 아직 쓰지 않으므로 `{ "ok": true }`만 반환합니다. Flutter 앱에서는 secure storage에 저장한 session token을 삭제하면 됩니다.

## 검증 명령어

TypeScript 타입체크:

```bash
cd /Users/changhwanlee/Documents/project/house-keeping
npm run typecheck
```

Flutter analyze:

```bash
cd /Users/changhwanlee/Documents/project/house-keeping
npm run mobile:analyze
```

Flutter test:

```bash
cd /Users/changhwanlee/Documents/project/house-keeping
npm run mobile:test
```

모바일 폴더에서 직접 실행해도 됩니다.

```bash
cd /Users/changhwanlee/Documents/project/house-keeping/apps/mobile
flutter analyze
flutter test
```

## Vercel 배포 준비

Vercel 프로젝트를 연결합니다.

```bash
cd /Users/changhwanlee/Documents/project/house-keeping
npx vercel link
```

Vercel Dashboard 또는 CLI로 아래 환경변수를 등록합니다.

- `SUPABASE_URL`
- `SUPABASE_SECRET_KEY`
- `KAKAO_REST_API_KEY`
- `KAKAO_CLIENT_SECRET`
- `KAKAO_REDIRECT_URI`
- `SESSION_SECRET`

현재 서버 코드는 Supabase 서버용 secret key만 사용하므로 `SUPABASE_PUBLISHABLE_KEY`는 필수값이 아닙니다.

Production 배포용 카카오 Redirect URI는 카카오 개발자 콘솔에도 동일하게 등록해야 합니다.

```text
https://api-one-ruby-46.vercel.app/api/auth/kakao/callback
```

등록 후 로컬 env를 다시 내려받습니다.

```bash
npx vercel env pull .env.local --yes
```

Preview 배포:

```bash
npx vercel
```

Production 배포:

```bash
npx vercel --prod
```

현재 API 앱은 `/Users/changhwanlee/Documents/project/house-keeping/apps/api`가 Vercel 프로젝트로 연결되어 있습니다. API 앱 폴더에서 바로 Production 배포할 수도 있습니다.

```bash
cd /Users/changhwanlee/Documents/project/house-keeping/apps/api
npx vercel --prod --yes
```

배포 후 health check로 확인합니다.

```bash
curl https://api-one-ruby-46.vercel.app/api/health
```

## 개발 역할

하네스 엔지니어링 문서는 역할별 소유 영역과 완료 기준을 정리합니다.

- 기획자: `docs/product-plan.md`, 기능 요구사항, 수용 기준
- 디자이너: `apps/mobile/lib/**`, 화면 구조, 접근성, 상태별 UX
- 앱개발자: `apps/mobile`
- 백엔드개발자: `apps/api`, `packages/contracts`, `supabase`

자세한 내용은 아래 문서를 확인합니다.

- `docs/harness-engineering.md`
- `harness/planner.md`
- `harness/designer.md`
- `harness/app-developer.md`
- `harness/backend-developer.md`

## 다음 개발 순서

1. 실제 iPhone에서 카카오 로그인 후 Supabase `users`, `authentications` 생성 확인
2. 앱에 session token 저장소 추가
3. 가족 구성원 관리 schema와 화면 설계
4. 학원 일정 schema/API/화면 구현
5. 주차 관리 schema/API/화면 구현
6. Vercel Production 환경에서 모바일 로그인 회귀 테스트
