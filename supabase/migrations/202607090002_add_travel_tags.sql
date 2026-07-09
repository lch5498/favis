create table if not exists public.travel_tags (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  name text not null,
  created_by_user_id uuid references public.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint travel_tags_name_check check (char_length(btrim(name)) between 1 and 24),
  constraint travel_tags_family_name_unique unique (family_id, name)
);

create table if not exists public.travel_itinerary_tags (
  family_id uuid not null references public.families(id) on delete cascade,
  itinerary_id uuid not null references public.travel_itineraries(id) on delete cascade,
  tag_id uuid not null references public.travel_tags(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (itinerary_id, tag_id)
);

create index if not exists travel_tags_family_name_idx
  on public.travel_tags (family_id, name);

create index if not exists travel_itinerary_tags_family_itinerary_idx
  on public.travel_itinerary_tags (family_id, itinerary_id);

alter table public.travel_tags enable row level security;
alter table public.travel_itinerary_tags enable row level security;

drop trigger if exists travel_tags_set_updated_at on public.travel_tags;
create trigger travel_tags_set_updated_at
  before update on public.travel_tags
  for each row
  execute function public.set_updated_at();
