-- PHASE_008_CONNECTIONS_ADD_SUPABASE_CONNECTIONS
-- Connection requests (plan sections 4, 7 and 12).
--
-- - public.connections: one row per pair of people. The app can only read
--   rows it is part of; every write goes through the functions below.
-- - send_connection_request: both people active, no block either way, no
--   pending / accepted connection, the same requester may ask again only
--   3 days after this receiver declined, at most 10 requests per requester
--   in any 24 hours, not to yourself, note at most 200 characters.
-- - respond_to_connection: only the receiver of a pending request.
-- - remove_connection: either side of an accepted connection, or the
--   requester of a pending one (cancel). Rows are kept with status
--   'removed' so cancel-and-resend cannot bypass the 24-hour limit.
-- - connection_count: accepted connections of a profile (public profile).
-- - Blocking someone removes any connection between the two (trigger).
--
-- Errors are raised with these messages (mapped in
-- lib/data/repositories/supabase/supabase_connection_repository.dart):
--   not_authenticated, note_too_long, self_request, sender_not_active,
--   receiver_not_active, not_found, already_connected, declined_recently,
--   request_limit.
--
-- Apply: paste into the Supabase SQL editor after the earlier migrations,
-- then run supabase/tests/connections_rls_checks.sql. Apply it BEFORE running
-- a PHASE_008 app build.
--
-- Rollback (connection rows are lost):
--   drop trigger if exists blocks_remove_connection on public.blocks;
--   drop function if exists private.remove_connection_on_block();
--   drop function if exists public.connection_count(uuid);
--   drop function if exists public.remove_connection(uuid);
--   drop function if exists public.respond_to_connection(uuid, boolean);
--   drop function if exists public.send_connection_request(uuid, text);
--   drop table if exists public.connections;

-- ---------------------------------------------------------------- table

create table public.connections (
  id uuid primary key default gen_random_uuid(),
  requester_id uuid not null references public.profiles (id) on delete cascade,
  receiver_id uuid not null references public.profiles (id) on delete cascade,
  status text not null default 'pending'
    check (status in ('pending', 'accepted', 'declined', 'removed')),
  note text check (char_length(note) <= 200),
  created_at timestamptz not null default now(),
  responded_at timestamptz,
  check (requester_id <> receiver_id)
);

-- One row per pair, whoever asked first.
create unique index connections_pair_key on public.connections (
  least(requester_id, receiver_id),
  greatest(requester_id, receiver_id)
);
-- 24-hour request limit.
create index connections_requester_created_idx
  on public.connections (requester_id, created_at);
create index connections_receiver_idx on public.connections (receiver_id);

alter table public.connections enable row level security;

revoke all on public.connections from anon, authenticated;
grant select on public.connections to authenticated;

create policy "connections: members read"
  on public.connections for select to authenticated
  using (
    requester_id = (select auth.uid()) or receiver_id = (select auth.uid())
  );

-- ------------------------------------------------------------ send

create or replace function public.send_connection_request(
  p_receiver uuid,
  p_note text default null
)
returns public.connections
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  me uuid := auth.uid();
  v_note text := nullif(btrim(p_note), '');
  v_status text;
  existing public.connections;
  has_row boolean;
  result public.connections;
begin
  if me is null then
    raise exception 'not_authenticated' using errcode = '42501';
  end if;
  if v_note is not null and char_length(v_note) > 200 then
    raise exception 'note_too_long';
  end if;
  if p_receiver = me then
    raise exception 'self_request';
  end if;

  select status into v_status from public.profiles where id = me;
  if v_status is distinct from 'active' then
    raise exception 'sender_not_active';
  end if;

  select status into v_status from public.profiles where id = p_receiver;
  if not found then
    raise exception 'not_found';
  end if;
  -- A block either way looks like "not available" (never reveal a block).
  if exists (
    select 1 from public.blocks b
    where (b.blocker_id = me and b.blocked_id = p_receiver)
       or (b.blocker_id = p_receiver and b.blocked_id = me)
  ) then
    raise exception 'not_found';
  end if;
  if v_status <> 'active' then
    raise exception 'receiver_not_active';
  end if;

  select * into existing from public.connections c
  where least(c.requester_id, c.receiver_id) = least(me, p_receiver)
    and greatest(c.requester_id, c.receiver_id) = greatest(me, p_receiver)
  for update;
  has_row := found;

  if has_row then
    if existing.status in ('pending', 'accepted') then
      raise exception 'already_connected';
    end if;
    if existing.status = 'declined'
       and existing.requester_id = me
       and existing.responded_at > now() - interval '3 days' then
      raise exception 'declined_recently';
    end if;
  end if;

  if (
    select count(*) from public.connections c
    where c.requester_id = me and c.created_at > now() - interval '24 hours'
  ) >= 10 then
    raise exception 'request_limit';
  end if;

  if has_row then
    update public.connections
    set requester_id = me,
        receiver_id = p_receiver,
        status = 'pending',
        note = v_note,
        created_at = now(),
        responded_at = null
    where id = existing.id
    returning * into result;
  else
    begin
      insert into public.connections (requester_id, receiver_id, note)
      values (me, p_receiver, v_note)
      returning * into result;
    exception when unique_violation then
      -- The other person asked at the same moment.
      raise exception 'already_connected';
    end;
  end if;
  return result;
end;
$$;

-- --------------------------------------------------------- respond

create or replace function public.respond_to_connection(
  p_id uuid,
  p_accept boolean
)
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
  update public.connections
  set status = case when p_accept then 'accepted' else 'declined' end,
      responded_at = now()
  where id = p_id and receiver_id = auth.uid() and status = 'pending';
  if not found then
    raise exception 'not_found';
  end if;
end;
$$;

-- ---------------------------------------------------------- remove

create or replace function public.remove_connection(p_id uuid)
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
  update public.connections
  set status = 'removed', responded_at = now()
  where id = p_id
    and (
      (status = 'accepted'
        and (requester_id = auth.uid() or receiver_id = auth.uid()))
      or (status = 'pending' and requester_id = auth.uid())
    );
  if not found then
    raise exception 'not_found';
  end if;
end;
$$;

-- ----------------------------------------------------------- count

-- Accepted connections of [p_user]; 0 when that profile is hidden from the
-- caller by a block (same rule as the profile read policy).
create or replace function public.connection_count(p_user uuid)
returns integer
language sql
stable
security definer
set search_path = ''
as $$
  select case
    when auth.uid() is null or private.hidden_by_block(p_user) then 0
    else (
      select count(*)::int from public.connections c
      where c.status = 'accepted'
        and (c.requester_id = p_user or c.receiver_id = p_user)
    )
  end;
$$;

revoke all on function public.send_connection_request(uuid, text) from public, anon;
revoke all on function public.respond_to_connection(uuid, boolean) from public, anon;
revoke all on function public.remove_connection(uuid) from public, anon;
revoke all on function public.connection_count(uuid) from public, anon;
grant execute on function public.send_connection_request(uuid, text) to authenticated;
grant execute on function public.respond_to_connection(uuid, boolean) to authenticated;
grant execute on function public.remove_connection(uuid) to authenticated;
grant execute on function public.connection_count(uuid) to authenticated;

-- ------------------------------------------------ block removes connection

create or replace function private.remove_connection_on_block()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  update public.connections
  set status = 'removed', responded_at = now()
  where least(requester_id, receiver_id) = least(new.blocker_id, new.blocked_id)
    and greatest(requester_id, receiver_id) = greatest(new.blocker_id, new.blocked_id)
    and status in ('pending', 'accepted');
  return null;
end;
$$;

revoke all on function private.remove_connection_on_block() from public, anon, authenticated;

create trigger blocks_remove_connection
  after insert on public.blocks
  for each row execute function private.remove_connection_on_block();
