alter table public.education_programs
  add column if not exists recurrence_type text not null default 'weekly',
  add column if not exists monthly_schedules jsonb not null default '[]'::jsonb;

alter table public.education_programs
  drop constraint if exists education_programs_recurrence_type_check;

alter table public.education_programs
  add constraint education_programs_recurrence_type_check check (
    recurrence_type in ('weekly', 'monthly')
  );

alter table public.education_programs
  drop constraint if exists education_programs_monthly_schedules_array_check;

alter table public.education_programs
  add constraint education_programs_monthly_schedules_array_check check (
    jsonb_typeof(monthly_schedules) = 'array'
  );
