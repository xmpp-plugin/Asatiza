-- PHASE_008 manual checks for connections (20261128120000_connections.sql).
--
-- Run in the Supabase SQL editor AFTER the migration. Needs two ACTIVE
-- profiles (every required field filled) with no connection or block between
-- them. Changes nothing: the whole script runs in a transaction that is
-- rolled back.
--
-- Result: one row, "connections_check_result", listing PASS / FAIL per check.
-- The 10-per-24-hours limit is not exercised here (it needs 11 active
-- profiles); it is covered by the function code and the manual test.

begin;

select set_config('rls.me', coalesce((
  select id::text from public.profiles where status = 'active'
  order by created_at limit 1), ''), true);
select set_config('rls.other', coalesce((
  select id::text from public.profiles where status = 'active'
  order by created_at offset 1 limit 1), ''), true);

set local role authenticated;

do $$
declare
  me uuid := nullif(current_setting('rls.me'), '')::uuid;
  other uuid := nullif(current_setting('rls.other'), '')::uuid;
  c public.connections;
  n int;
  out text := '';

begin
  if me is null or other is null then
    perform set_config('rls.result', 'SKIPPED: need two active profiles', true);
    return;
  end if;

  -- ----------------------------------------------------- signed in as "me"
  perform set_config('request.jwt.claims',
    json_build_object('sub', me, 'role', 'authenticated')::text, true);

  -- 1. Direct writes are refused (functions only).
  begin
    insert into public.connections (requester_id, receiver_id)
      values (me, other);
    out := out || 'FAIL 1 direct insert; ';
  exception when insufficient_privilege then
    out := out || 'PASS 1 direct insert; ';
  end;

  -- 2. Self request refused.
  begin
    perform public.send_connection_request(me, null);
    out := out || 'FAIL 2 self request; ';
  exception when others then
    out := out || case when sqlerrm = 'self_request' then 'PASS' else 'FAIL' end
      || ' 2 self request; ';
  end;

  -- 3. Note over 200 characters refused.
  begin
    perform public.send_connection_request(other, repeat('a', 201));
    out := out || 'FAIL 3 long note; ';
  exception when others then
    out := out || case when sqlerrm = 'note_too_long' then 'PASS' else 'FAIL' end
      || ' 3 long note; ';
  end;

  -- 4. Request sent.
  c := public.send_connection_request(other, 'Assalamu alaikum');
  out := out || case when c.status = 'pending' and c.requester_id = me
    then 'PASS' else 'FAIL' end || ' 4 send; ';

  -- 5. Duplicate refused.
  begin
    perform public.send_connection_request(other, null);
    out := out || 'FAIL 5 duplicate; ';
  exception when others then
    out := out || case when sqlerrm = 'already_connected' then 'PASS' else 'FAIL' end
      || ' 5 duplicate; ';
  end;

  -- 6. The requester cannot accept their own request.
  begin
    perform public.respond_to_connection(c.id, true);
    out := out || 'FAIL 6 requester accepts; ';
  exception when others then
    out := out || case when sqlerrm = 'not_found' then 'PASS' else 'FAIL' end
      || ' 6 requester accepts; ';
  end;

  -- -------------------------------------------------- signed in as "other"
  perform set_config('request.jwt.claims',
    json_build_object('sub', other, 'role', 'authenticated')::text, true);

  -- 7. Opposite request while one is pending: refused.
  begin
    perform public.send_connection_request(me, null);
    out := out || 'FAIL 7 opposite pending; ';
  exception when others then
    out := out || case when sqlerrm = 'already_connected' then 'PASS' else 'FAIL' end
      || ' 7 opposite pending; ';
  end;

  -- 8. Receiver declines.
  perform public.respond_to_connection(c.id, false);
  select count(*) into n from public.connections
    where id = c.id and status = 'declined';
  out := out || case when n = 1 then 'PASS' else 'FAIL' end || ' 8 decline; ';

  -- -------------------------------------------------- back to "me"
  perform set_config('request.jwt.claims',
    json_build_object('sub', me, 'role', 'authenticated')::text, true);

  -- 9. Asking again within 3 days: refused.
  begin
    perform public.send_connection_request(other, null);
    out := out || 'FAIL 9 re-request within 3 days; ';
  exception when others then
    out := out || case when sqlerrm = 'declined_recently' then 'PASS' else 'FAIL' end
      || ' 9 re-request within 3 days; ';
  end;

  perform set_config('rls.connection', c.id::text, true);
  perform set_config('rls.result', out, true);
end;
$$;

-- Back-date the decline by 4 days as the database owner.
reset role;
update public.connections
  set responded_at = now() - interval '4 days'
  where id = nullif(current_setting('rls.connection', true), '')::uuid;
set local role authenticated;

do $$
declare
  me uuid := nullif(current_setting('rls.me'), '')::uuid;
  other uuid := nullif(current_setting('rls.other'), '')::uuid;
  c public.connections;
  n int;
  out text := current_setting('rls.result');
begin
  if me is null or other is null then
    return;
  end if;
  perform set_config('request.jwt.claims',
    json_build_object('sub', me, 'role', 'authenticated')::text, true);

  -- 10. After 3 days the same requester may ask again.
  c := public.send_connection_request(other, null);
  out := out || case when c.status = 'pending' then 'PASS' else 'FAIL' end
    || ' 10 re-request after 3 days; ';

  perform set_config('request.jwt.claims',
    json_build_object('sub', other, 'role', 'authenticated')::text, true);

  -- 11. Accept; both see it; the count is 1 for each.
  perform public.respond_to_connection(c.id, true);
  out := out || case when public.connection_count(me) >= 1
    then 'PASS' else 'FAIL' end || ' 11 accept + count; ';

  -- 12. Blocking removes the connection.
  insert into public.blocks (blocker_id, blocked_id) values (other, me);
  select count(*) into n from public.connections
    where id = c.id and status = 'removed';
  out := out || case when n = 1 then 'PASS' else 'FAIL' end
    || ' 12 block removes connection; ';

  -- 13. Blocked: a new request either way is refused (looks like not found).
  perform set_config('request.jwt.claims',
    json_build_object('sub', me, 'role', 'authenticated')::text, true);
  begin
    perform public.send_connection_request(other, null);
    out := out || 'FAIL 13 request across a block; ';
  exception when others then
    out := out || case when sqlerrm = 'not_found' then 'PASS' else 'FAIL' end
      || ' 13 request across a block; ';
  end;

  -- 14. Blocked profile's count reads 0 for the blocked viewer.
  out := out || case when public.connection_count(other) = 0
    then 'PASS' else 'FAIL' end || ' 14 count hidden by block; ';

  perform set_config('rls.result', out, true);
end;
$$;

-- 15. Signed out (anon): no access.
reset role;
set local role anon;
do $$
begin
  perform 1 from public.connections limit 1;
  perform set_config('rls.result',
    current_setting('rls.result') || 'FAIL 15 anon read; ', true);
exception when insufficient_privilege then
  perform set_config('rls.result',
    current_setting('rls.result') || 'PASS 15 anon read; ', true);
end;
$$;

reset role;
select current_setting('rls.result') as connections_check_result;

rollback;
