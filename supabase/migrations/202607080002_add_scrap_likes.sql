create table if not exists public.scrap_likes (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  post_id uuid references public.scrap_posts(id) on delete cascade,
  comment_id uuid references public.scrap_comments(id) on delete cascade,
  user_id uuid not null references public.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  constraint scrap_likes_single_target_check check (
    (post_id is not null and comment_id is null) or
    (post_id is null and comment_id is not null)
  )
);

create unique index if not exists scrap_likes_post_user_idx
  on public.scrap_likes (post_id, user_id)
  where post_id is not null;

create unique index if not exists scrap_likes_comment_user_idx
  on public.scrap_likes (comment_id, user_id)
  where comment_id is not null;

create index if not exists scrap_likes_family_post_idx
  on public.scrap_likes (family_id, post_id)
  where post_id is not null;

create index if not exists scrap_likes_family_comment_idx
  on public.scrap_likes (family_id, comment_id)
  where comment_id is not null;

alter table public.scrap_likes enable row level security;
