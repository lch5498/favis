alter table public.schedules
  add column if not exists alert_offset_minutes integer;

alter table public.education_programs
  add column if not exists alert_offset_minutes integer;

alter table public.anniversaries
  add column if not exists alert_offset_minutes integer;

alter table public.schedules
  add constraint schedules_alert_offset_minutes_check
  check (
    alert_offset_minutes is null
    or (alert_offset_minutes between 1 and 525600)
  );

alter table public.education_programs
  add constraint education_programs_alert_offset_minutes_check
  check (
    alert_offset_minutes is null
    or (alert_offset_minutes between 1 and 525600)
  );

alter table public.anniversaries
  add constraint anniversaries_alert_offset_minutes_check
  check (
    alert_offset_minutes is null
    or (alert_offset_minutes between 1 and 525600)
  );

create index if not exists schedules_alerts_idx
  on public.schedules (starts_at)
  where alert_offset_minutes is not null;
