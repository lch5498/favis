create extension if not exists "pgcrypto";

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create table if not exists public.users (
  id uuid primary key default gen_random_uuid(),
  nickname text not null,
  last_login_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.authentications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  oauth_provider text not null,
  oauth_provider_id text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint authentications_provider_user_unique unique (oauth_provider, oauth_provider_id)
);

create index if not exists authentications_user_id_idx
  on public.authentications (user_id);

alter table public.users enable row level security;
alter table public.authentications enable row level security;

drop trigger if exists users_set_updated_at on public.users;
create trigger users_set_updated_at
before update on public.users
for each row execute function public.set_updated_at();

drop trigger if exists authentications_set_updated_at on public.authentications;
create trigger authentications_set_updated_at
before update on public.authentications
for each row execute function public.set_updated_at();
