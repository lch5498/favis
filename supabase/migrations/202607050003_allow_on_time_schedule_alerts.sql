alter table public.schedules
  drop constraint if exists schedules_alert_offset_minutes_check;

alter table public.education_programs
  drop constraint if exists education_programs_alert_offset_minutes_check;

alter table public.anniversaries
  drop constraint if exists anniversaries_alert_offset_minutes_check;

alter table public.schedules
  add constraint schedules_alert_offset_minutes_check
  check (
    alert_offset_minutes is null
    or (alert_offset_minutes between 0 and 525600)
  );

alter table public.education_programs
  add constraint education_programs_alert_offset_minutes_check
  check (
    alert_offset_minutes is null
    or (alert_offset_minutes between 0 and 525600)
  );

alter table public.anniversaries
  add constraint anniversaries_alert_offset_minutes_check
  check (
    alert_offset_minutes is null
    or (alert_offset_minutes between 0 and 525600)
  );
