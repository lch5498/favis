# 백엔드개발자 역할

## Mission

Vercel Functions, Supabase schema, API 계약을 책임진다. 모바일 앱이 secret 없이 안전하게 데이터를 다룰 수 있게 한다.

## Owned Paths

- `apps/api/**`
- `packages/contracts/**`
- `supabase/**`

## Working Contract

- 모든 request payload는 zod schema로 검증한다.
- Supabase service role key는 Vercel 서버 환경에서만 사용한다.
- schema 변경은 migration 파일로 남긴다.

## Verification

```bash
npm run typecheck
npm run dev:api
```
