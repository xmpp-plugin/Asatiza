-- PHASE_007_SAFETY_ADD_SUPABASE_BLOCKS
-- Blocks (plan sections 9 and 12): "Blocked users can't see your profile or
-- posts, can't message you, and disappear from your lists."
--
-- - public.blocks: one row per (blocker, blocked). Users create, read and
--   delete only their own blocks; nobody can read who blocked them.
-- - profiles / teacher_details / student_details: a row is hidden from a
--   user the owner blocked, unless that user also blocked the owner (so a
--   mutual block still shows the name in the Blocked users list and can be
--   undone). Lists also drop the people the viewer blocked (app query).
-- - Later phases (connections, chat, feed) must refuse requests, messages and
--   posts across a block in their own functions / policies.
--
-- Apply: paste into the Supabase SQL editor after the earlier migrations,
-- then run supabase/tests/blocks_rls_checks.sql. Apply it BEFORE running a
-- PHASE_007 app build (the app reads public.blocks).
--
-- Rollback (restores the PHASE_004 read rule; block rows are lost):
--   drop policy if exists "profiles: signed-in users read unless blocked"
--     on public.profiles;
--   drop policy if exists "teacher_details: signed-in users read unless blocked"
--     on public.teacher_details;
--   drop policy if exists "student_details: signed-in users read unless blocked"
--     on public.student_details;
--   create policy "profiles: signed-in users read" on public.profiles
--     for select to authenticated using (true);
--   create policy "teacher_details: signed-in users read"
--     on public.teacher_details for select to authenticated using (true);
--   create policy "student_details: signed-in users read"
--     on public.student_details for select to authenticated using (true);
--   drop function if exists private.hidden_by_block(uuid);
--   revoke usage on schema private from authenticated;
--   drop table if exists public.blocks;

-- ---------------------------------------------------------------- table

create table public.blocks (
  blocker_id uuid not null references public.profiles (id) on delete cascade,
  blocked_id uuid not null references public.profiles (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (blocker_id, blocked_id),
  check (blocker_id <> blocked_id)
);

-- "Who blocked this profile?" lookups (read policy below).
create index blocks_blocked_id_idx on public.blocks (blocked_id);

alter table public.blocks enable row level security;

revoke all on public.blocks from anon, authenticated;
grant select, delete on public.blocks to authenticated;
-- The app sets only the two ids; created_at is always the server time.
grant insert (blocker_id, blocked_id) on public.blocks to authenticated;

create policy "blocks: owner reads own blocks"
  on public.blocks for select to authenticated
  using (blocker_id = (select auth.uid()));

create policy "blocks: owner creates own blocks"
  on public.blocks for insert to authenticated
  with check (blocker_id = (select auth.uid()));

create policy "blocks: owner removes own blocks"
  on public.blocks for delete to authenticated
  using (blocker_id = (select auth.uid()));

-- ------------------------------------------------- read-rule helper

-- True when [owner] blocked the signed-in user and the signed-in user did not
-- block [owner]. security definer: the caller cannot read other people's
-- blocks directly. Lives in `private` (not exposed by the API); only the
-- read policies call it.
create or replace function private.hidden_by_block(owner uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
           select 1 from public.blocks b
           where b.blocker_id = owner and b.blocked_id = (select auth.uid())
         )
     and not exists (
           select 1 from public.blocks b
           where b.blocker_id = (select auth.uid()) and b.blocked_id = owner
         );
$$;

revoke all on function private.hidden_by_block(uuid) from public, anon;
grant usage on schema private to authenticated;
grant execute on function private.hidden_by_block(uuid) to authenticated;

-- ----------------------------------------------- profile read policies

drop policy "profiles: signed-in users read" on public.profiles;
create policy "profiles: signed-in users read unless blocked"
  on public.profiles for select to authenticated
  using (not private.hidden_by_block(id));

drop policy "teacher_details: signed-in users read" on public.teacher_details;
create policy "teacher_details: signed-in users read unless blocked"
  on public.teacher_details for select to authenticated
  using (not private.hidden_by_block(profile_id));

drop policy "student_details: signed-in users read" on public.student_details;
create policy "student_details: signed-in users read unless blocked"
  on public.student_details for select to authenticated
  using (not private.hidden_by_block(profile_id));
