-- PHASE_007 manual RLS checks for blocks (20261127120000_blocks.sql).
--
-- Run in the Supabase SQL editor AFTER the migration, once at least two users
-- have signed up. Changes nothing: the whole script runs in a transaction
-- that is rolled back (blocks it creates are discarded).
--
-- Result: one row, "blocks_check_result", listing PASS / FAIL per check.
-- Run it while the two oldest users have no blocks between them.

begin;

select set_config('rls.me',
  (select id::text from public.profiles order by created_at limit 1), true);
select set_config('rls.other',
  (select id::text from public.profiles order by created_at offset 1 limit 1), true);

set local role authenticated;

do $$
declare
  me uuid := nullif(current_setting('rls.me'), '')::uuid;
  other uuid := nullif(current_setting('rls.other'), '')::uuid;
  n int;
  out text := '';

begin
  if me is null or other is null then
    perform set_config('rls.result', 'SKIPPED: need at least two users', true);
    return;
  end if;

  -- ----------------------------------------------------- signed in as "me"
  perform set_config('request.jwt.claims',
    json_build_object('sub', me, 'role', 'authenticated')::text, true);

  -- 1. Own block: allowed.
  insert into public.blocks (blocker_id, blocked_id) values (me, other);
  out := out || 'PASS 1 own block; ';

  -- 2. Same block again: refused by the primary key (the app treats it as
  --    "already blocked").
  begin
    insert into public.blocks (blocker_id, blocked_id) values (me, other);
    out := out || 'FAIL 2 duplicate block; ';
  exception when unique_violation then
    out := out || 'PASS 2 duplicate block; ';
  end;

  -- 3. A block in someone else's name: refused by RLS.
  begin
    insert into public.blocks (blocker_id, blocked_id) values (other, me);
    out := out || 'FAIL 3 block for someone else; ';
  exception when insufficient_privilege then
    out := out || 'PASS 3 block for someone else; ';
  end;

  -- 4. Blocking yourself: refused by the check constraint.
  begin
    insert into public.blocks (blocker_id, blocked_id) values (me, me);
    out := out || 'FAIL 4 self block; ';
  exception when check_violation then
    out := out || 'PASS 4 self block; ';
  end;

  -- 5. created_at cannot be set by the app.
  begin
    insert into public.blocks (blocker_id, blocked_id, created_at)
      values (me, gen_random_uuid(), now());
    out := out || 'FAIL 5 created_at write; ';
  exception when insufficient_privilege then
    out := out || 'PASS 5 created_at write; ';
  end;

  -- 6. The blocker still reads the blocked person's profile.
  select count(*) into n from public.profiles where id = other;
  out := out || case when n = 1 then 'PASS' else 'FAIL' end
    || ' 6 blocker reads blocked profile; ';

  -- -------------------------------------------------- signed in as "other"
  perform set_config('request.jwt.claims',
    json_build_object('sub', other, 'role', 'authenticated')::text, true);

  -- 7. Nobody sees who blocked them.
  select count(*) into n from public.blocks where blocked_id = other;
  out := out || case when n = 0 then 'PASS' else 'FAIL' end
    || ' 7 blocked user cannot see the block; ';

  -- 8. The blocked person cannot read the blocker's profile or details.
  select (select count(*) from public.profiles where id = me)
       + (select count(*) from public.teacher_details where profile_id = me)
       + (select count(*) from public.student_details where profile_id = me)
    into n;
  out := out || case when n = 0 then 'PASS' else 'FAIL' end
    || ' 8 blocker profile hidden from blocked user; ';

  -- 9. Someone else's block cannot be removed.
  delete from public.blocks where blocker_id = me and blocked_id = other;
  get diagnostics n = row_count;
  out := out || case when n = 0 then 'PASS' else 'FAIL' end
    || ' 9 cannot remove someone else''s block; ';

  -- 10. Mutual block: each still reads the other (Blocked users list).
  insert into public.blocks (blocker_id, blocked_id) values (other, me);
  select count(*) into n from public.profiles where id = me;
  out := out || case when n = 1 then 'PASS' else 'FAIL' end
    || ' 10 mutual block keeps names readable; ';

  -- ----------------------------------------------------- back to "me"
  perform set_config('request.jwt.claims',
    json_build_object('sub', me, 'role', 'authenticated')::text, true);

  -- 11. Own block removed.
  delete from public.blocks where blocker_id = me and blocked_id = other;
  get diagnostics n = row_count;
  out := out || case when n = 1 then 'PASS' else 'FAIL' end
    || ' 11 own unblock; ';

  -- 12. Only "other" still blocks "me": "me" cannot read "other" now.
  select count(*) into n from public.profiles where id = other;
  out := out || case when n = 0 then 'PASS' else 'FAIL' end
    || ' 12 hidden again after one-sided block; ';

  perform set_config('rls.result', out, true);
end;
$$;

-- 13. Signed out (anon): no access to blocks.
reset role;
set local role anon;
do $$
begin
  perform 1 from public.blocks limit 1;
  perform set_config('rls.result',
    current_setting('rls.result') || 'FAIL 13 anon read; ', true);
exception when insufficient_privilege then
  perform set_config('rls.result',
    current_setting('rls.result') || 'PASS 13 anon read; ', true);
end;
$$;

reset role;
select current_setting('rls.result') as blocks_check_result;

rollback;
