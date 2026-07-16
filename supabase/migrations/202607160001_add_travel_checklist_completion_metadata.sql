alter table public.travel_trip_checklist_items
  add column if not exists completed_by_user_id uuid references public.users(id) on delete set null,
  add column if not exists checked_at timestamptz;

create index if not exists travel_trip_checklist_items_completed_by_user_idx
  on public.travel_trip_checklist_items (family_id, completed_by_user_id)
  where completed_by_user_id is not null;
