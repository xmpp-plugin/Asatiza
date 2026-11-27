-- PHASE_010_FEED_ADD_SUPABASE_FEED_POSTS_LIKES_COMMENTS_REPORTS
-- Feed (plan sections 4, 9, 12): posts, likes, comments, comment likes,
-- reports, auto-hide, public `post-images` bucket.
--
-- - Reads go through RLS: posts that are not hidden (or are your own) and
--   whose author is not blocked either way; likes / comments of visible
--   posts; your own reports. The app never writes tables directly.
-- - Writes only through the functions below. Limits: post body <= 1,500
--   characters, comment <= 1,000, Arabic verse <= 300; 10 posts and 100
--   comments per person in any 24 hours.
-- - Counters (likes, comments) are recounted by triggers. A post reported by
--   3 different people is hidden automatically (is_hidden); the admin
--   un-hides or deletes it in the dashboard.
-- - Feed order: posts from your connections first (newest first), then
--   everyone else's (newest first) — mirrors lib/features/feed/logic/feed_ordering.dart.
-- - Post photo path: `<user-id>/post_<n>.jpg` in the public `post-images`
--   bucket (account deletion removes the user's folder).
--
-- Errors (mapped in lib/data/repositories/supabase/supabase_feed_repository.dart):
--   not_authenticated, not_found, post_empty, post_too_long, post_tag_missing,
--   daily_post_limit, comment_empty, comment_too_long, daily_comment_limit,
--   invalid_image, invalid_report.
--
-- Apply: paste into the Supabase SQL editor after the earlier migrations,
-- then run supabase/tests/feed_rls_checks.sql. Apply it BEFORE running a
-- PHASE_010 app build.
--
-- Rollback (feed data is lost; empty the post-images bucket in the
-- dashboard first):
--   drop policy if exists "post-images: owner uploads" on storage.objects;
--   drop policy if exists "post-images: owner deletes" on storage.objects;
--   delete from storage.buckets where id = 'post-images';
--   drop function if exists public.search_posts(text, integer);
--   drop function if exists public.list_posts_by(uuid, integer);
--   drop function if exists public.list_feed(integer, integer);
--   drop function if exists public.report_content(text, uuid, text);
--   drop function if exists public.toggle_comment_like(uuid);
--   drop function if exists public.delete_comment(uuid);
--   drop function if exists public.add_comment(uuid, text);
--   drop function if exists public.toggle_post_like(uuid);
--   drop function if exists public.delete_post(uuid);
--   drop function if exists public.create_post(text, text, text, text);
--   drop table if exists public.reports, public.comment_likes,
--     public.post_comments, public.post_likes, public.posts cascade;
--   drop function if exists private.recount_post_likes();
--   drop function if exists private.recount_post_comments();
--   drop function if exists private.recount_comment_likes();
--   drop function if exists private.apply_post_reports();
--   drop function if exists private.can_see_post(uuid);

-- ---------------------------------------------------------------- tables

create table public.posts (
  id uuid primary key default gen_random_uuid(),
  author_id uuid not null references public.profiles (id) on delete cascade,
  body text not null
    check (char_length(btrim(body)) between 1 and 1500),
  tag text not null check (tag in ('reminder', 'tajweed_tip', 'hifz',
    'question', 'class_announcement', 'achievement')),
  arabic_verse text check (char_length(arabic_verse) <= 300),
  image_path text,
  like_count int not null default 0,
  comment_count int not null default 0,
  report_count int not null default 0,
  is_hidden boolean not null default false,
  created_at timestamptz not null default now()
);

create index posts_created_idx on public.posts (created_at desc);
create index posts_author_created_idx on public.posts (author_id, created_at desc);

create table public.post_likes (
  post_id uuid not null references public.posts (id) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (post_id, user_id)
);

create index post_likes_user_idx on public.post_likes (user_id);

create table public.post_comments (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.posts (id) on delete cascade,
  author_id uuid not null references public.profiles (id) on delete cascade,
  body text not null check (char_length(btrim(body)) between 1 and 1000),
  like_count int not null default 0,
  created_at timestamptz not null default now()
);

create index post_comments_post_created_idx
  on public.post_comments (post_id, created_at);
create index post_comments_author_created_idx
  on public.post_comments (author_id, created_at);

create table public.comment_likes (
  comment_id uuid not null references public.post_comments (id) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (comment_id, user_id)
);

create table public.reports (
  id uuid primary key default gen_random_uuid(),
  reporter_id uuid not null references public.profiles (id) on delete cascade,
  target_type text not null check (target_type in ('post', 'comment')),
  target_id uuid not null,
  reason text not null check (reason in ('spam', 'inappropriate',
    'hate_or_harassment', 'false_information', 'something_else')),
  status text not null default 'open' check (status in ('open', 'reviewed')),
  created_at timestamptz not null default now(),
  unique (reporter_id, target_type, target_id)
);

create index reports_target_idx on public.reports (target_type, target_id);

-- -------------------------------------------------------------- helpers

-- The caller may see [p_post]: not hidden (or their own) and no block
-- between the caller and the author. security definer so it also works
-- inside the functions below.
create or replace function private.can_see_post(p_post uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.posts p
    where p.id = p_post
      and (not p.is_hidden or p.author_id = (select auth.uid()))
      and not private.pair_blocked((select auth.uid()), p.author_id)
  );
$$;

revoke all on function private.can_see_post(uuid) from public, anon;
grant execute on function private.can_see_post(uuid) to authenticated;

-- ------------------------------------------------------------------ RLS

alter table public.posts enable row level security;
alter table public.post_likes enable row level security;
alter table public.post_comments enable row level security;
alter table public.comment_likes enable row level security;
alter table public.reports enable row level security;

revoke all on public.posts, public.post_likes, public.post_comments,
  public.comment_likes, public.reports from anon, authenticated;
grant select on public.posts, public.post_likes, public.post_comments,
  public.comment_likes, public.reports to authenticated;

create policy "posts: visible posts"
  on public.posts for select to authenticated
  using (
    (not is_hidden or author_id = (select auth.uid()))
    and not private.pair_blocked((select auth.uid()), author_id)
  );

create policy "post_likes: likes of visible posts"
  on public.post_likes for select to authenticated
  using (private.can_see_post(post_id));

create policy "post_comments: comments of visible posts"
  on public.post_comments for select to authenticated
  using (
    private.can_see_post(post_id)
    and not private.pair_blocked((select auth.uid()), author_id)
  );

create policy "comment_likes: own likes"
  on public.comment_likes for select to authenticated
  using (user_id = (select auth.uid()));

create policy "reports: own reports"
  on public.reports for select to authenticated
  using (reporter_id = (select auth.uid()));

-- ------------------------------------------------------------- triggers

create or replace function private.recount_post_likes()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_post uuid := coalesce(new.post_id, old.post_id);
begin
  update public.posts
  set like_count = (select count(*) from public.post_likes l where l.post_id = v_post)
  where id = v_post;
  return null;
end;
$$;

create trigger post_likes_recount
  after insert or delete on public.post_likes
  for each row execute function private.recount_post_likes();

create or replace function private.recount_post_comments()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_post uuid := coalesce(new.post_id, old.post_id);
begin
  update public.posts
  set comment_count = (
    select count(*) from public.post_comments c where c.post_id = v_post)
  where id = v_post;
  return null;
end;
$$;

create trigger post_comments_recount
  after insert or delete on public.post_comments
  for each row execute function private.recount_post_comments();

create or replace function private.recount_comment_likes()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_comment uuid := coalesce(new.comment_id, old.comment_id);
begin
  update public.post_comments
  set like_count = (
    select count(*) from public.comment_likes l where l.comment_id = v_comment)
  where id = v_comment;
  return null;
end;
$$;

create trigger comment_likes_recount
  after insert or delete on public.comment_likes
  for each row execute function private.recount_comment_likes();

-- 3 different reporters hide a post (plan section 9).
create or replace function private.apply_post_reports()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_count int;
begin
  if new.target_type <> 'post' then
    return null;
  end if;
  select count(distinct r.reporter_id) into v_count
  from public.reports r
  where r.target_type = 'post' and r.target_id = new.target_id;
  update public.posts
  set report_count = v_count,
      is_hidden = is_hidden or v_count >= 3
  where id = new.target_id;
  return null;
end;
$$;

create trigger reports_apply_post_reports
  after insert on public.reports
  for each row execute function private.apply_post_reports();

revoke all on function private.recount_post_likes() from public, anon, authenticated;
revoke all on function private.recount_post_comments() from public, anon, authenticated;
revoke all on function private.recount_comment_likes() from public, anon, authenticated;
revoke all on function private.apply_post_reports() from public, anon, authenticated;

-- ------------------------------------------------------------- functions

create or replace function public.create_post(
  p_body text,
  p_tag text,
  p_image_path text default null,
  p_arabic_verse text default null
)
returns public.posts
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  me uuid := auth.uid();
  v_body text := btrim(coalesce(p_body, ''));
  v_image text := nullif(btrim(p_image_path), '');
  v_verse text := nullif(btrim(p_arabic_verse), '');
  result public.posts;
begin
  if me is null then
    raise exception 'not_authenticated' using errcode = '42501';
  end if;
  if v_body = '' then
    raise exception 'post_empty';
  end if;
  if char_length(v_body) > 1500 then
    raise exception 'post_too_long';
  end if;
  if p_tag is null or p_tag not in ('reminder', 'tajweed_tip', 'hifz',
       'question', 'class_announcement', 'achievement') then
    raise exception 'post_tag_missing';
  end if;
  if v_verse is not null and char_length(v_verse) > 300 then
    raise exception 'post_too_long';
  end if;
  if v_image is not null
     and v_image !~ ('^' || me::text || '/post_[0-9]+\.jpg$') then
    raise exception 'invalid_image';
  end if;
  if (
    select count(*) from public.posts p
    where p.author_id = me and p.created_at > now() - interval '24 hours'
  ) >= 10 then
    raise exception 'daily_post_limit';
  end if;

  insert into public.posts (author_id, body, tag, image_path, arabic_verse)
  values (me, v_body, p_tag, v_image, v_verse)
  returning * into result;
  return result;
end;
$$;

-- Deletes your own post (likes, comments go with it) and returns its photo
-- path so the app can remove the file.
create or replace function public.delete_post(p_id uuid)
returns text
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  v_image text;
begin
  if auth.uid() is null then
    raise exception 'not_authenticated' using errcode = '42501';
  end if;
  delete from public.posts
  where id = p_id and author_id = auth.uid()
  returning image_path into v_image;
  if not found then
    raise exception 'not_found';
  end if;
  delete from public.reports where target_type = 'post' and target_id = p_id;
  return v_image;
end;
$$;

-- Likes or unlikes a visible post; returns true when it is liked now.
create or replace function public.toggle_post_like(p_id uuid)
returns boolean
language plpgsql
volatile
security definer
set search_path = ''
as $$
begin
  if auth.uid() is null then
    raise exception 'not_authenticated' using errcode = '42501';
  end if;
  if not private.can_see_post(p_id) then
    raise exception 'not_found';
  end if;
  delete from public.post_likes where post_id = p_id and user_id = auth.uid();
  if found then
    return false;
  end if;
  insert into public.post_likes (post_id, user_id) values (p_id, auth.uid());
  return true;
end;
$$;

create or replace function public.add_comment(p_post uuid, p_body text)
returns public.post_comments
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  me uuid := auth.uid();
  v_body text := btrim(coalesce(p_body, ''));
  result public.post_comments;
begin
  if me is null then
    raise exception 'not_authenticated' using errcode = '42501';
  end if;
  if v_body = '' then
    raise exception 'comment_empty';
  end if;
  if char_length(v_body) > 1000 then
    raise exception 'comment_too_long';
  end if;
  if not private.can_see_post(p_post) then
    raise exception 'not_found';
  end if;
  if (
    select count(*) from public.post_comments c
    where c.author_id = me and c.created_at > now() - interval '24 hours'
  ) >= 100 then
    raise exception 'daily_comment_limit';
  end if;
  insert into public.post_comments (post_id, author_id, body)
  values (p_post, me, v_body)
  returning * into result;
  return result;
end;
$$;

create or replace function public.delete_comment(p_id uuid)
returns void
language plpgsql
volatile
security definer
set search_path = ''
as $$
begin
  if auth.uid() is null then
    raise exception 'not_authenticated' using errcode = '42501';
  end if;
  delete from public.post_comments where id = p_id and author_id = auth.uid();
  if not found then
    raise exception 'not_found';
  end if;
  delete from public.reports where target_type = 'comment' and target_id = p_id;
end;
$$;

-- Likes or unlikes a comment of a visible post; true when liked now.
create or replace function public.toggle_comment_like(p_id uuid)
returns boolean
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  v_post uuid;
begin
  if auth.uid() is null then
    raise exception 'not_authenticated' using errcode = '42501';
  end if;
  select c.post_id into v_post from public.post_comments c where c.id = p_id;
  if v_post is null or not private.can_see_post(v_post) then
    raise exception 'not_found';
  end if;
  delete from public.comment_likes where comment_id = p_id and user_id = auth.uid();
  if found then
    return false;
  end if;
  insert into public.comment_likes (comment_id, user_id) values (p_id, auth.uid());
  return true;
end;
$$;

-- Reports a visible post or comment once per person (a second report of the
-- same item does nothing).
create or replace function public.report_content(
  p_type text,
  p_id uuid,
  p_reason text
)
returns void
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  v_post uuid;
begin
  if auth.uid() is null then
    raise exception 'not_authenticated' using errcode = '42501';
  end if;
  if p_type not in ('post', 'comment') or p_reason not in ('spam',
       'inappropriate', 'hate_or_harassment', 'false_information',
       'something_else') then
    raise exception 'invalid_report';
  end if;
  if p_type = 'post' then
    v_post := p_id;
  else
    select c.post_id into v_post from public.post_comments c where c.id = p_id;
  end if;
  if v_post is null or not private.can_see_post(v_post) then
    raise exception 'not_found';
  end if;
  insert into public.reports (reporter_id, target_type, target_id, reason)
  values (auth.uid(), p_type, p_id, p_reason)
  on conflict (reporter_id, target_type, target_id) do nothing;
end;
$$;

-- Reads below run with the caller's rights (RLS decides what is visible).

-- One feed page: connections' posts first (newest first), then the rest.
create or replace function public.list_feed(p_limit integer, p_offset integer)
returns table (
  id uuid, author_id uuid, body text, tag text, arabic_verse text,
  image_path text, like_count int, comment_count int, is_hidden boolean,
  created_at timestamptz, liked_by_me boolean
)
language sql
stable
security invoker
set search_path = ''
as $$
  select p.id, p.author_id, p.body, p.tag, p.arabic_verse, p.image_path,
         p.like_count, p.comment_count, p.is_hidden, p.created_at,
         exists (select 1 from public.post_likes l
                 where l.post_id = p.id and l.user_id = (select auth.uid()))
  from public.posts p
  order by (p.author_id <> (select auth.uid())
            and private.pair_connected((select auth.uid()), p.author_id)) desc,
           p.created_at desc,
           p.id
  limit least(greatest(coalesce(p_limit, 20), 1), 500)
  offset greatest(coalesce(p_offset, 0), 0);
$$;

-- A person's posts, newest first (profiles).
create or replace function public.list_posts_by(p_author uuid, p_limit integer)
returns table (
  id uuid, author_id uuid, body text, tag text, arabic_verse text,
  image_path text, like_count int, comment_count int, is_hidden boolean,
  created_at timestamptz, liked_by_me boolean
)
language sql
stable
security invoker
set search_path = ''
as $$
  select p.id, p.author_id, p.body, p.tag, p.arabic_verse, p.image_path,
         p.like_count, p.comment_count, p.is_hidden, p.created_at,
         exists (select 1 from public.post_likes l
                 where l.post_id = p.id and l.user_id = (select auth.uid()))
  from public.posts p
  where p.author_id = p_author
  order by p.created_at desc
  limit least(greatest(coalesce(p_limit, 50), 1), 100);
$$;

-- Posts whose body or tag contains [p_query] (case-insensitive), newest
-- first.
create or replace function public.search_posts(p_query text, p_limit integer)
returns table (
  id uuid, author_id uuid, body text, tag text, arabic_verse text,
  image_path text, like_count int, comment_count int, is_hidden boolean,
  created_at timestamptz, liked_by_me boolean
)
language sql
stable
security invoker
set search_path = ''
as $$
  with q as (
    select '%' || replace(replace(replace(btrim(coalesce(p_query, '')),
             '\', '\\'), '%', '\%'), '_', '\_') || '%' as pattern
  )
  select p.id, p.author_id, p.body, p.tag, p.arabic_verse, p.image_path,
         p.like_count, p.comment_count, p.is_hidden, p.created_at,
         exists (select 1 from public.post_likes l
                 where l.post_id = p.id and l.user_id = (select auth.uid()))
  from public.posts p, q
  where btrim(coalesce(p_query, '')) <> ''
    and (p.body ilike q.pattern or replace(p.tag, '_', ' ') ilike q.pattern)
  order by p.created_at desc
  limit least(greatest(coalesce(p_limit, 30), 1), 100);
$$;

revoke all on function public.create_post(text, text, text, text) from public, anon;
revoke all on function public.delete_post(uuid) from public, anon;
revoke all on function public.toggle_post_like(uuid) from public, anon;
revoke all on function public.add_comment(uuid, text) from public, anon;
revoke all on function public.delete_comment(uuid) from public, anon;
revoke all on function public.toggle_comment_like(uuid) from public, anon;
revoke all on function public.report_content(text, uuid, text) from public, anon;
revoke all on function public.list_feed(integer, integer) from public, anon;
revoke all on function public.list_posts_by(uuid, integer) from public, anon;
revoke all on function public.search_posts(text, integer) from public, anon;
grant execute on function public.create_post(text, text, text, text) to authenticated;
grant execute on function public.delete_post(uuid) to authenticated;
grant execute on function public.toggle_post_like(uuid) to authenticated;
grant execute on function public.add_comment(uuid, text) to authenticated;
grant execute on function public.delete_comment(uuid) to authenticated;
grant execute on function public.toggle_comment_like(uuid) to authenticated;
grant execute on function public.report_content(text, uuid, text) to authenticated;
grant execute on function public.list_feed(integer, integer) to authenticated;
grant execute on function public.list_posts_by(uuid, integer) to authenticated;
grant execute on function public.search_posts(text, integer) to authenticated;

-- ------------------------------------------------------------- Storage

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('post-images', 'post-images', true, 1048576, array['image/jpeg'])
on conflict (id) do update
  set public = excluded.public,
      file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

-- Public read is by public URL (bucket is public). Writes: own folder only.
create policy "post-images: owner uploads"
  on storage.objects for insert to authenticated
  with check (
    bucket_id = 'post-images'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

create policy "post-images: owner deletes"
  on storage.objects for delete to authenticated
  using (
    bucket_id = 'post-images'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );
