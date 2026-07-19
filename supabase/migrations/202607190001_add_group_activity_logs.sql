create table public.group_activity_logs (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  actor_user_id uuid references public.users(id) on delete set null,
  activity_type text not null check (activity_type in ('schedule', 'parking', 'scrap', 'travel')),
  title text not null,
  detail text not null,
  target_type text check (target_type in (
    'schedule',
    'recurring_schedule',
    'parking_vehicle',
    'scrap_post',
    'travel_trip',
    'travel_itinerary'
  )),
  target_id uuid,
  target_parent_id uuid,
  target_starts_at timestamptz,
  created_at timestamptz not null default now()
);

create index group_activity_logs_family_created_at_idx
  on public.group_activity_logs (family_id, created_at desc);

alter table public.group_activity_logs enable row level security;
