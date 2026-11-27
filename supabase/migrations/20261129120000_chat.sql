-- PHASE_009_CHAT_ADD_SUPABASE_REALTIME_CHAT_WITH_PHOTOS
-- One-to-one chat with photos (plan sections 4, 12).
--
-- - conversations: one per pair (user_a < user_b); created only from an
--   accepted connection. messages: text (<= 2,000 characters) and / or one
--   photo in the private `chat-images` bucket.
-- - Reads: only the two members, and never while a block stands between
--   them (either way). Writes: only through the functions below.
-- - Removed connection: the conversation stays readable but read-only
--   (`can_send` false; send_message refuses).
-- - Realtime: `messages` is added to the `supabase_realtime` publication;
--   RLS decides which events each user receives.
-- - Photo path: `<sender-id>/<conversation-id>_<random>.jpg` (the user folder
--   keeps account-deletion clean-up working).
--
-- Errors (mapped in lib/data/repositories/supabase/supabase_chat_repository.dart):
--   not_authenticated, not_found, not_connected, message_empty,
--   message_too_long, invalid_image.
--
-- Apply: paste into the Supabase SQL editor after the earlier migrations,
-- then run supabase/tests/chat_rls_checks.sql. Apply it BEFORE running a
-- PHASE_009 app build.
--
-- Rollback (chat data is lost; empty the chat-images bucket in the dashboard
-- first):
--   alter publication supabase_realtime drop table public.messages;
--   drop policy if exists "chat-images: members read" on storage.objects;
--   drop policy if exists "chat-images: member uploads own photo" on storage.objects;
--   drop policy if exists "chat-images: owner deletes" on storage.objects;
--   delete from storage.buckets where id = 'chat-images';
--   drop function if exists public.list_conversations();
--   drop function if exists public.mark_conversation_read(uuid);
--   drop function if exists public.send_message(uuid, text, text);
--   drop function if exists public.open_conversation(uuid);
--   drop function if exists private.chat_image_conversation(text);
--   drop function if exists private.can_read_conversation(uuid);
--   drop function if exists private.pair_blocked(uuid, uuid);
--   drop function if exists private.pair_connected(uuid, uuid);
--   drop table if exists public.messages;
--   drop table if exists public.conversations;

-- ---------------------------------------------------------------- tables

create table public.conversations (
  id uuid primary key default gen_random_uuid(),
  user_a uuid not null references public.profiles (id) on delete cascade,
  user_b uuid not null references public.profiles (id) on delete cascade,
  last_message text,
  last_message_at timestamptz,
  created_at timestamptz not null default now(),
  check (user_a < user_b),
  unique (user_a, user_b)
);

create index conversations_user_b_idx on public.conversations (user_b);

create table public.messages (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid not null
    references public.conversations (id) on delete cascade,
  sender_id uuid not null references public.profiles (id) on delete cascade,
  body text check (char_length(body) <= 2000),
  image_path text,
  read_at timestamptz,
  created_at timestamptz not null default now(),
  check (nullif(btrim(body), '') is not null or image_path is not null)
);

create index messages_conversation_created_idx
  on public.messages (conversation_id, created_at desc);

-- -------------------------------------------------------------- helpers

-- security definer: callers cannot read other people's blocks / connections.

create or replace function private.pair_blocked(a uuid, b uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.blocks x
    where (x.blocker_id = a and x.blocked_id = b)
       or (x.blocker_id = b and x.blocked_id = a)
  );
$$;

create or replace function private.pair_connected(a uuid, b uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.connections c
    where c.status = 'accepted'
      and least(c.requester_id, c.receiver_id) = least(a, b)
      and greatest(c.requester_id, c.receiver_id) = greatest(a, b)
  );
$$;

-- The caller is a member of [conv] and no block stands between the members.
create or replace function private.can_read_conversation(conv uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.conversations c
    where c.id = conv
      and (select auth.uid()) in (c.user_a, c.user_b)
      and not private.pair_blocked(c.user_a, c.user_b)
  );
$$;

-- Conversation id from a chat photo object name
-- (`<sender>/<conversation>_<random>.jpg`), or null when the name has
-- another shape.
create or replace function private.chat_image_conversation(object_name text)
returns uuid
language sql
immutable
set search_path = ''
as $$
  select case
    when object_name ~ '^[0-9a-f-]{36}/[0-9a-f-]{36}_[A-Za-z0-9-]+\.jpg$'
    then split_part(split_part(object_name, '/', 2), '_', 1)::uuid
  end;
$$;

revoke all on function private.pair_blocked(uuid, uuid) from public, anon;
revoke all on function private.pair_connected(uuid, uuid) from public, anon;
revoke all on function private.can_read_conversation(uuid) from public, anon;
revoke all on function private.chat_image_conversation(text) from public, anon;
grant execute on function private.pair_blocked(uuid, uuid) to authenticated;
grant execute on function private.pair_connected(uuid, uuid) to authenticated;
grant execute on function private.can_read_conversation(uuid) to authenticated;
grant execute on function private.chat_image_conversation(text) to authenticated;

-- ------------------------------------------------------------------ RLS

alter table public.conversations enable row level security;
alter table public.messages enable row level security;

revoke all on public.conversations, public.messages from anon, authenticated;
grant select on public.conversations, public.messages to authenticated;

create policy "conversations: members read unless blocked"
  on public.conversations for select to authenticated
  using (private.can_read_conversation(id));

create policy "messages: members read unless blocked"
  on public.messages for select to authenticated
  using (private.can_read_conversation(conversation_id));

-- ------------------------------------------------------------ functions

-- Returns the conversation with [p_other]; creates it only when the two are
-- connected. An existing conversation opens even after the connection was
-- removed (read-only: can_send = false).
create or replace function public.open_conversation(p_other uuid)
returns table (
  id uuid,
  user_a uuid,
  user_b uuid,
  started_at timestamptz,
  can_send boolean
)
language plpgsql
volatile
security definer
set search_path = ''
as $$
#variable_conflict use_column
declare
  me uuid := auth.uid();
  conv public.conversations;
begin
  if me is null then
    raise exception 'not_authenticated' using errcode = '42501';
  end if;
  if p_other is null or p_other = me or private.pair_blocked(me, p_other) then
    raise exception 'not_found';
  end if;

  select * into conv from public.conversations c
  where c.user_a = least(me, p_other) and c.user_b = greatest(me, p_other);

  if not found then
    if not private.pair_connected(me, p_other) then
      raise exception 'not_connected';
    end if;
    begin
      insert into public.conversations (user_a, user_b)
      values (least(me, p_other), greatest(me, p_other))
      returning * into conv;
    exception when unique_violation then
      select * into conv from public.conversations c
      where c.user_a = least(me, p_other) and c.user_b = greatest(me, p_other);
    end;
  end if;

  return query
  select conv.id, conv.user_a, conv.user_b,
         coalesce((
           select cn.responded_at from public.connections cn
           where cn.status = 'accepted'
             and least(cn.requester_id, cn.receiver_id) = conv.user_a
             and greatest(cn.requester_id, cn.receiver_id) = conv.user_b
         ), conv.created_at),
         private.pair_connected(conv.user_a, conv.user_b);
end;
$$;

create or replace function public.send_message(
  p_conversation uuid,
  p_body text default null,
  p_image_path text default null
)
returns public.messages
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  me uuid := auth.uid();
  v_body text := nullif(btrim(p_body), '');
  v_image text := nullif(btrim(p_image_path), '');
  conv public.conversations;
  result public.messages;
begin
  if me is null then
    raise exception 'not_authenticated' using errcode = '42501';
  end if;
  if v_body is null and v_image is null then
    raise exception 'message_empty';
  end if;
  if v_body is not null and char_length(v_body) > 2000 then
    raise exception 'message_too_long';
  end if;

  select * into conv from public.conversations c
  where c.id = p_conversation and me in (c.user_a, c.user_b);
  if not found or private.pair_blocked(conv.user_a, conv.user_b) then
    raise exception 'not_found';
  end if;
  if not private.pair_connected(conv.user_a, conv.user_b) then
    raise exception 'not_connected';
  end if;
  if v_image is not null and (
       split_part(v_image, '/', 1) <> me::text
       or private.chat_image_conversation(v_image) is distinct from conv.id
     ) then
    raise exception 'invalid_image';
  end if;

  insert into public.messages (conversation_id, sender_id, body, image_path)
  values (conv.id, me, v_body, v_image)
  returning * into result;

  update public.conversations
  set last_message = left(v_body, 200), last_message_at = result.created_at
  where id = conv.id;

  return result;
end;
$$;

-- Marks the other member's messages in [p_conversation] as read.
create or replace function public.mark_conversation_read(p_conversation uuid)
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
  if not private.can_read_conversation(p_conversation) then
    raise exception 'not_found';
  end if;
  update public.messages
  set read_at = now()
  where conversation_id = p_conversation
    and sender_id <> auth.uid()
    and read_at is null;
end;
$$;

-- The caller's conversations (hidden while blocked), newest activity first,
-- with the last message, the caller's unread count and whether they can
-- still send.
create or replace function public.list_conversations()
returns table (
  id uuid,
  user_a uuid,
  user_b uuid,
  started_at timestamptz,
  can_send boolean,
  unread_count integer,
  last_id uuid,
  last_sender_id uuid,
  last_body text,
  last_image_path text,
  last_read_at timestamptz,
  last_created_at timestamptz
)
language sql
stable
security definer
set search_path = ''
as $$
  select c.id, c.user_a, c.user_b,
         coalesce((
           select cn.responded_at from public.connections cn
           where cn.status = 'accepted'
             and least(cn.requester_id, cn.receiver_id) = c.user_a
             and greatest(cn.requester_id, cn.receiver_id) = c.user_b
         ), c.created_at),
         private.pair_connected(c.user_a, c.user_b),
         (select count(*)::int from public.messages m
          where m.conversation_id = c.id
            and m.sender_id <> (select auth.uid())
            and m.read_at is null),
         lm.id, lm.sender_id, lm.body, lm.image_path, lm.read_at, lm.created_at
  from public.conversations c
  left join lateral (
    select * from public.messages m
    where m.conversation_id = c.id
    order by m.created_at desc
    limit 1
  ) lm on true
  where (select auth.uid()) in (c.user_a, c.user_b)
    and not private.pair_blocked(c.user_a, c.user_b)
  order by coalesce(c.last_message_at, c.created_at) desc;
$$;

revoke all on function public.open_conversation(uuid) from public, anon;
revoke all on function public.send_message(uuid, text, text) from public, anon;
revoke all on function public.mark_conversation_read(uuid) from public, anon;
revoke all on function public.list_conversations() from public, anon;
grant execute on function public.open_conversation(uuid) to authenticated;
grant execute on function public.send_message(uuid, text, text) to authenticated;
grant execute on function public.mark_conversation_read(uuid) to authenticated;
grant execute on function public.list_conversations() to authenticated;

-- ------------------------------------------------------------- Realtime

alter publication supabase_realtime add table public.messages;

-- ------------------------------------------------------------- Storage

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('chat-images', 'chat-images', false, 1048576, array['image/jpeg'])
on conflict (id) do update
  set public = excluded.public,
      file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

create policy "chat-images: members read"
  on storage.objects for select to authenticated
  using (
    bucket_id = 'chat-images'
    and private.can_read_conversation(private.chat_image_conversation(name))
  );

create policy "chat-images: member uploads own photo"
  on storage.objects for insert to authenticated
  with check (
    bucket_id = 'chat-images'
    and (storage.foldername(name))[1] = (select auth.uid())::text
    and private.can_read_conversation(private.chat_image_conversation(name))
  );

-- Account deletion removes the user's own photos (MediaRepository).
create policy "chat-images: owner deletes"
  on storage.objects for delete to authenticated
  using (
    bucket_id = 'chat-images'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );
