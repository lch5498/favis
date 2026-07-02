create table if not exists public.anniversaries (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  category text not null,
  title text not null,
  calendar_type text not null default 'solar',
  month integer not null,
  day integer not null,
  is_lunar_leap boolean not null default false,
  created_by_user_id uuid references public.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint anniversaries_category_check check (
    category in ('birthday', 'wedding', 'custom')
  ),
  constraint anniversaries_calendar_type_check check (
    calendar_type in ('solar', 'lunar')
  ),
  constraint anniversaries_month_check check (month between 1 and 12),
  constraint anniversaries_day_check check (day between 1 and 31)
);

alter table public.schedules
  add column if not exists anniversary_id uuid
    references public.anniversaries(id) on delete cascade;

create index if not exists anniversaries_family_id_idx
  on public.anniversaries (family_id);

create index if not exists schedules_anniversary_id_idx
  on public.schedules (anniversary_id);

alter table public.anniversaries enable row level security;

drop trigger if exists anniversaries_set_updated_at on public.anniversaries;
create trigger anniversaries_set_updated_at
before update on public.anniversaries
for each row execute function public.set_updated_at();
