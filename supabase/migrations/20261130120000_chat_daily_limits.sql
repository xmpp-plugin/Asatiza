-- PHASE_009_CHAT_ADD_SUPABASE_REALTIME_CHAT_WITH_PHOTOS (scope addition)
-- Daily chat limits per sender (developer decision 2026-11-27):
--   at most 300 messages and 30 photos in any 24 hours.
--
-- Replaces public.send_message from 20261129120000_chat.sql with the same
-- rules plus the two limits. New errors (mapped in
-- lib/data/repositories/supabase/supabase_chat_repository.dart):
--   daily_message_limit, daily_photo_limit.
--
-- Apply: paste into the Supabase SQL editor AFTER 20261129120000_chat.sql,
-- then run supabase/tests/chat_rls_checks.sql again.
--
-- Rollback: re-run the `create or replace function public.send_message`
-- block from 20261129120000_chat.sql (the grants stay), then
--   drop index if exists public.messages_sender_created_idx;

-- Counting a sender's messages of the last 24 hours.
create index if not exists messages_sender_created_idx
  on public.messages (sender_id, created_at);

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

  -- Daily limits (any 24 hours, all conversations of the sender).
  if (
    select count(*) from public.messages m
    where m.sender_id = me and m.created_at > now() - interval '24 hours'
  ) >= 300 then
    raise exception 'daily_message_limit';
  end if;
  if v_image is not null and (
    select count(*) from public.messages m
    where m.sender_id = me
      and m.image_path is not null
      and m.created_at > now() - interval '24 hours'
  ) >= 30 then
    raise exception 'daily_photo_limit';
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

revoke all on function public.send_message(uuid, text, text) from public, anon;
grant execute on function public.send_message(uuid, text, text) to authenticated;
