alter table public.anniversaries
  add column if not exists year integer;

alter table public.anniversaries
  drop constraint if exists anniversaries_year_check;

alter table public.anniversaries
  add constraint anniversaries_year_check
    check (year is null or year between 1900 and 2200);
