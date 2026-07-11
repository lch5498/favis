create or replace function public.seed_default_travel_tags_for_family()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.travel_tags (family_id, name)
  select new.id, defaults.name
  from (
    values ('식당'), ('카페'), ('교통'), ('호텔'), ('관광'), ('숙소')
  ) as defaults(name)
  on conflict (family_id, name) do nothing;

  return new;
end;
$$;

drop trigger if exists families_seed_default_travel_tags on public.families;
create trigger families_seed_default_travel_tags
after insert on public.families
for each row execute function public.seed_default_travel_tags_for_family();

insert into public.travel_tags (family_id, name)
select families.id, defaults.name
from public.families
cross join (
  values ('식당'), ('카페'), ('교통'), ('호텔'), ('관광'), ('숙소')
) as defaults(name)
on conflict (family_id, name) do nothing;
