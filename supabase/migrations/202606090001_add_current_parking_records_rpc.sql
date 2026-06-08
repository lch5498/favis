create or replace function public.list_current_parking_records(target_family_id uuid)
returns table (
  id uuid,
  family_id uuid,
  vehicle_id uuid,
  floor_preset_id uuid,
  spot_preset_id uuid,
  floor_text text,
  spot_text text,
  location_text text,
  created_by_user_id uuid,
  parked_at timestamptz,
  created_at timestamptz,
  updated_at timestamptz,
  created_by_user jsonb
)
language sql
stable
security invoker
set search_path = public
as $$
  select distinct on (record.vehicle_id)
    record.id,
    record.family_id,
    record.vehicle_id,
    record.floor_preset_id,
    record.spot_preset_id,
    record.floor_text,
    record.spot_text,
    record.location_text,
    record.created_by_user_id,
    record.parked_at,
    record.created_at,
    record.updated_at,
    case
      when creator.id is null then null
      else jsonb_build_object(
        'id', creator.id,
        'nickname', creator.nickname
      )
    end as created_by_user
  from public.parking_records as record
  left join public.users as creator
    on creator.id = record.created_by_user_id
  where record.family_id = target_family_id
  order by record.vehicle_id, record.parked_at desc, record.created_at desc;
$$;
