create index if not exists scrap_posts_family_id_created_at_idx
  on public.scrap_posts (family_id, created_at desc);

create index if not exists scrap_comments_family_id_created_at_idx
  on public.scrap_comments (family_id, created_at desc);
