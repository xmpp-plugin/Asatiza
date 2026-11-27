-- PHASE_009 manual checks for chat (20261129120000_chat.sql and
-- 20261130120000_chat_daily_limits.sql).
--
-- Run in the Supabase SQL editor AFTER the migration. Uses the two oldest
-- ACTIVE profiles (a third profile, if any, is used as an outsider).
--
-- Safe with real data: everything runs in ONE transaction that is always
-- rolled back at the end. Inside it, the script first clears the
-- connection, chat and any block between the two profiles so every check
-- starts from a clean state; the final ROLLBACK restores all of it exactly
-- as it was. Nothing is committed, even if a check fails halfway.
--
-- Result: one row, "chat_check_result", listing PASS / FAIL per check.

begin;

select set_config('rls.me', coalesce((
  select id::text from public.profiles where status = 'active'
  order by created_at limit 1), ''), true);
select set_config('rls.other', coalesce((
  select id::text from public.profiles where status = 'active'
  order by created_at offset 1 limit 1), ''), true);
select set_config('rls.outsider', coalesce((
  select id::text from public.profiles
  where id::text not in (current_setting('rls.me'), current_setting('rls.other'))
  order by created_at limit 1), ''), true);

-- Clean state for this transaction only (undone by the final ROLLBACK).
delete from public.conversations
where user_a = least(nullif(current_setting('rls.me'), '')::uuid,
                     nullif(current_setting('rls.other'), '')::uuid)
  and user_b = greatest(nullif(current_setting('rls.me'), '')::uuid,
                        nullif(current_setting('rls.other'), '')::uuid);
delete from public.connections
where least(requester_id, receiver_id)
        = least(nullif(current_setting('rls.me'), '')::uuid,
                nullif(current_setting('rls.other'), '')::uuid)
  and greatest(requester_id, receiver_id)
        = greatest(nullif(current_setting('rls.me'), '')::uuid,
                   nullif(current_setting('rls.other'), '')::uuid);
delete from public.blocks
where (blocker_id = nullif(current_setting('rls.me'), '')::uuid
       and blocked_id = nullif(current_setting('rls.other'), '')::uuid)
   or (blocker_id = nullif(current_setting('rls.other'), '')::uuid
       and blocked_id = nullif(current_setting('rls.me'), '')::uuid);

set local role authenticated;

do $$
declare
  me uuid := nullif(current_setting('rls.me'), '')::uuid;
  other uuid := nullif(current_setting('rls.other'), '')::uuid;
  outsider uuid := nullif(current_setting('rls.outsider'), '')::uuid;
  req public.connections;
  conv_id uuid;
  can boolean;
  n int;
  out text := '';

begin
  if me is null or other is null then
    perform set_config('rls.result', 'SKIPPED: need two active profiles', true);
    return;
  end if;

  perform set_config('request.jwt.claims',
    json_build_object('sub', me, 'role', 'authenticated')::text, true);

  -- 1. No connection yet: a conversation cannot be created.
  begin
    perform public.open_conversation(other);
    out := out || 'FAIL 1 open without connection; ';
  exception when others then
    out := out || case when sqlerrm = 'not_connected' then 'PASS' else 'FAIL' end
      || ' 1 open without connection; ';
  end;

  -- Connect (me asks, other accepts).
  req := public.send_connection_request(other, null);
  perform set_config('request.jwt.claims',
    json_build_object('sub', other, 'role', 'authenticated')::text, true);
  perform public.respond_to_connection(req.id, true);
  perform set_config('request.jwt.claims',
    json_build_object('sub', me, 'role', 'authenticated')::text, true);

  -- 2. Connected: open works and can send.
  select o.id, o.can_send into conv_id, can from public.open_conversation(other) o;
  out := out || case when conv_id is not null and can then 'PASS' else 'FAIL' end
    || ' 2 open when connected; ';

  -- 3. Send text.
  perform public.send_message(conv_id, 'Assalamu alaikum', null);
  out := out || 'PASS 3 send text; ';

  -- 4. Empty refused.
  begin
    perform public.send_message(conv_id, '   ', null);
    out := out || 'FAIL 4 empty message; ';
  exception when others then
    out := out || case when sqlerrm = 'message_empty' then 'PASS' else 'FAIL' end
      || ' 4 empty message; ';
  end;

  -- 5. Over 2,000 characters refused.
  begin
    perform public.send_message(conv_id, repeat('a', 2001), null);
    out := out || 'FAIL 5 long message; ';
  exception when others then
    out := out || case when sqlerrm = 'message_too_long' then 'PASS' else 'FAIL' end
      || ' 5 long message; ';
  end;

  -- 6. Direct insert refused.
  begin
    insert into public.messages (conversation_id, sender_id, body)
      values (conv_id, me, 'x');
    out := out || 'FAIL 6 direct insert; ';
  exception when insufficient_privilege then
    out := out || 'PASS 6 direct insert; ';
  end;

  -- 7. A photo path that is not mine / not this conversation is refused.
  begin
    perform public.send_message(conv_id, null,
      other::text || '/' || conv_id::text || '_abc.jpg');
    out := out || 'FAIL 7 foreign photo path; ';
  exception when others then
    out := out || case when sqlerrm = 'invalid_image' then 'PASS' else 'FAIL' end
      || ' 7 foreign photo path; ';
  end;

  -- ---------------------------------------------------- as "other"
  perform set_config('request.jwt.claims',
    json_build_object('sub', other, 'role', 'authenticated')::text, true);

  -- 8. The other member reads it, unread 1, then marks read.
  select count(*) into n from public.messages where conversation_id = conv_id;
  select l.unread_count into can from (select (unread_count = 1) as unread_count
    from public.list_conversations() where id = conv_id) l;
  out := out || case when n = 1 and can then 'PASS' else 'FAIL' end
    || ' 8 other member reads + unread; ';
  perform public.mark_conversation_read(conv_id);
  select count(*) into n from public.messages
    where conversation_id = conv_id and read_at is not null;
  out := out || case when n = 1 then 'PASS' else 'FAIL' end || ' 9 mark read; ';

  -- 10. An outsider cannot read the conversation or its messages.
  if outsider is not null then
    perform set_config('request.jwt.claims',
      json_build_object('sub', outsider, 'role', 'authenticated')::text, true);
    select (select count(*) from public.conversations where id = conv_id)
         + (select count(*) from public.messages where conversation_id = conv_id)
      into n;
    out := out || case when n = 0 then 'PASS' else 'FAIL' end || ' 10 outsider; ';
  else
    out := out || 'SKIPPED 10 outsider (no third profile); ';
  end if;

  -- ---------------------------------------------------- back to "me"
  perform set_config('request.jwt.claims',
    json_build_object('sub', me, 'role', 'authenticated')::text, true);

  -- 11. Connection removed: still readable, read-only.
  perform public.remove_connection(req.id);
  begin
    perform public.send_message(conv_id, 'Are you there?', null);
    out := out || 'FAIL 11 send after removal; ';
  exception when others then
    out := out || case when sqlerrm = 'not_connected' then 'PASS' else 'FAIL' end
      || ' 11 send after removal; ';
  end;
  select o.can_send into can from public.open_conversation(other) o;
  select count(*) into n from public.messages where conversation_id = conv_id;
  out := out || case when not can and n = 1 then 'PASS' else 'FAIL' end
    || ' 12 read-only history; ';

  -- 13. Block: hidden for both, open refused.
  insert into public.blocks (blocker_id, blocked_id) values (me, other);
  select count(*) into n from public.conversations where id = conv_id;
  out := out || case when n = 0 then 'PASS' else 'FAIL' end
    || ' 13 hidden for blocker; ';
  perform set_config('request.jwt.claims',
    json_build_object('sub', other, 'role', 'authenticated')::text, true);
  select count(*) into n from public.messages where conversation_id = conv_id;
  out := out || case when n = 0 then 'PASS' else 'FAIL' end
    || ' 14 hidden for blocked; ';
  begin
    perform public.open_conversation(me);
    out := out || 'FAIL 15 open across a block; ';
  exception when others then
    out := out || case when sqlerrm = 'not_found' then 'PASS' else 'FAIL' end
      || ' 15 open across a block; ';
  end;

  perform set_config('rls.result', out, true);
end;
$$;

-- 17-19. Daily limits (20261130120000_chat_daily_limits.sql): a fresh,
-- connected pair inside the same rolled-back transaction.
reset role;
delete from public.blocks
where (blocker_id = nullif(current_setting('rls.me'), '')::uuid
       and blocked_id = nullif(current_setting('rls.other'), '')::uuid)
   or (blocker_id = nullif(current_setting('rls.other'), '')::uuid
       and blocked_id = nullif(current_setting('rls.me'), '')::uuid);
delete from public.connections
where least(requester_id, receiver_id)
        = least(nullif(current_setting('rls.me'), '')::uuid,
                nullif(current_setting('rls.other'), '')::uuid)
  and greatest(requester_id, receiver_id)
        = greatest(nullif(current_setting('rls.me'), '')::uuid,
                   nullif(current_setting('rls.other'), '')::uuid);
-- Count only what this pass sends.
delete from public.messages
where sender_id = nullif(current_setting('rls.me'), '')::uuid
  and created_at > now() - interval '24 hours';
set local role authenticated;

do $$
declare
  me uuid := nullif(current_setting('rls.me'), '')::uuid;
  other uuid := nullif(current_setting('rls.other'), '')::uuid;
  req public.connections;
  conv_id uuid;
  out text := current_setting('rls.result');
begin
  if me is null or other is null then
    return;
  end if;
  perform set_config('request.jwt.claims',
    json_build_object('sub', me, 'role', 'authenticated')::text, true);
  req := public.send_connection_request(other, null);
  perform set_config('request.jwt.claims',
    json_build_object('sub', other, 'role', 'authenticated')::text, true);
  perform public.respond_to_connection(req.id, true);
  perform set_config('request.jwt.claims',
    json_build_object('sub', me, 'role', 'authenticated')::text, true);
  select o.id into conv_id from public.open_conversation(other) o;

  -- 17. 30 photos are fine; the 31st is refused.
  for i in 1..30 loop
    perform public.send_message(conv_id, null,
      me::text || '/' || conv_id::text || '_' || i || '.jpg');
  end loop;
  begin
    perform public.send_message(conv_id, null,
      me::text || '/' || conv_id::text || '_31.jpg');
    out := out || 'FAIL 17 photo limit; ';
  exception when others then
    out := out || case when sqlerrm = 'daily_photo_limit' then 'PASS' else 'FAIL' end
      || ' 17 photo limit; ';
  end;

  -- 18. Text still works after the photo limit (31 messages so far).
  perform public.send_message(conv_id, 'Text after the photo limit', null);
  out := out || 'PASS 18 text after photo limit; ';

  -- 19. Up to 300 messages in total; the 301st is refused.
  for i in 32..300 loop
    perform public.send_message(conv_id, 'm' || i, null);
  end loop;
  begin
    perform public.send_message(conv_id, 'one too many', null);
    out := out || 'FAIL 19 message limit; ';
  exception when others then
    out := out || case when sqlerrm = 'daily_message_limit' then 'PASS' else 'FAIL' end
      || ' 19 message limit; ';
  end;

  perform set_config('rls.result', out, true);
end;
$$;

-- 16. Signed out (anon): no access.
reset role;
set local role anon;
do $$
begin
  perform 1 from public.messages limit 1;
  perform set_config('rls.result',
    current_setting('rls.result') || 'FAIL 16 anon read; ', true);
exception when insufficient_privilege then
  perform set_config('rls.result',
    current_setting('rls.result') || 'PASS 16 anon read; ', true);
end;
$$;

reset role;
select current_setting('rls.result') as chat_check_result;

rollback;
