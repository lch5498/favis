alter table public.schedules
  add column if not exists alert_due_at timestamptz;

update public.schedules
set alert_due_at = case
  when alert_offset_minutes is null then null
  else starts_at - make_interval(mins => alert_offset_minutes)
end
where alert_offset_minutes is not null
   or alert_due_at is not null;

create or replace function public.set_schedule_alert_due_at()
returns trigger
language plpgsql
as $$
begin
  if new.alert_offset_minutes is null then
    new.alert_due_at = null;
  else
    new.alert_due_at = new.starts_at - make_interval(mins => new.alert_offset_minutes);
  end if;

  return new;
end;
$$;

drop trigger if exists schedules_set_alert_due_at on public.schedules;

create trigger schedules_set_alert_due_at
  before insert or update of starts_at, alert_offset_minutes
  on public.schedules
  for each row execute function public.set_schedule_alert_due_at();

create index if not exists schedules_alert_due_at_idx
  on public.schedules (alert_due_at)
  where alert_due_at is not null;

create table if not exists public.schedule_alert_deliveries (
  id uuid primary key default gen_random_uuid(),
  schedule_id uuid not null references public.schedules(id) on delete cascade,
  alert_due_at timestamptz not null,
  status text not null default 'processing',
  token_count integer not null default 0,
  success_count integer not null default 0,
  failure_count integer not null default 0,
  error_summary jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint schedule_alert_deliveries_status_check check (
    status in ('processing', 'sent', 'failed', 'no_targets')
  ),
  constraint schedule_alert_deliveries_schedule_due_unique unique (
    schedule_id,
    alert_due_at
  )
);

create index if not exists schedule_alert_deliveries_schedule_id_idx
  on public.schedule_alert_deliveries (schedule_id);

drop trigger if exists schedule_alert_deliveries_set_updated_at
  on public.schedule_alert_deliveries;

create trigger schedule_alert_deliveries_set_updated_at
  before update on public.schedule_alert_deliveries
  for each row execute function public.set_updated_at();
