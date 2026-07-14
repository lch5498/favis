create or replace function public.retain_recent_parking_records()
returns trigger
language plpgsql
as $$
begin
  delete from public.parking_records
  where id in (
    select id
    from public.parking_records
    where vehicle_id = new.vehicle_id
    order by parked_at desc, created_at desc, id desc
    offset 10
  );

  return new;
end;
$$;

delete from public.parking_records
where id in (
  select id
  from (
    select
      id,
      row_number() over (
        partition by vehicle_id
        order by parked_at desc, created_at desc, id desc
      ) as history_rank
    from public.parking_records
  ) as ranked_records
  where history_rank > 10
);

drop trigger if exists parking_records_retain_recent_history
  on public.parking_records;

create trigger parking_records_retain_recent_history
  after insert on public.parking_records
  for each row execute function public.retain_recent_parking_records();
