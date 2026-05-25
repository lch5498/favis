create table if not exists public.education_programs (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  family_member_id uuid references public.family_members(id) on delete set null,
  name text not null,
  starts_on date not null,
  ends_on date not null,
  weekly_schedules jsonb not null default '[]'::jsonb,
  created_by_user_id uuid references public.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint education_programs_date_order_check check (ends_on >= starts_on),
  constraint education_programs_weekly_schedules_array_check check (
    jsonb_typeof(weekly_schedules) = 'array'
  )
);

create index if not exists education_programs_family_id_idx
  on public.education_programs (family_id);

create index if not exists education_programs_family_member_id_idx
  on public.education_programs (family_member_id);

alter table public.education_programs enable row level security;

drop trigger if exists education_programs_set_updated_at on public.education_programs;
create trigger education_programs_set_updated_at
before update on public.education_programs
for each row execute function public.set_updated_at();

alter table public.schedules
  add column if not exists education_program_id uuid
  references public.education_programs(id) on delete cascade;

create index if not exists schedules_education_program_id_idx
  on public.schedules (education_program_id);
