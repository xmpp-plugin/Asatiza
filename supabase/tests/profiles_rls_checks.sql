-- PHASE_004 manual RLS / privilege checks for profiles.
--
-- Run in the Supabase SQL editor AFTER the profile migrations (including
-- 20261126120000_profile_status.sql, PHASE_006), once at least two
-- users have signed up (one of each role is best). Changes nothing: the
-- whole script runs in a transaction that is rolled back.
--
-- Result: one row, "rls_check_result", listing PASS / FAIL per check.

begin;

-- The two oldest profiles act as "me" and "someone else".
select set_config('rls.me',
  (select id::text from public.profiles order by created_at limit 1), true);
select set_config('rls.other',
  (select id::text from public.profiles order by created_at offset 1 limit 1), true);
select set_config('rls.anon_can_delete',
  has_function_privilege('anon', 'public.delete_my_account()', 'execute')::text, true);

select set_config('request.jwt.claims',
  json_build_object('sub', current_setting('rls.me'), 'role', 'authenticated')::text,
  true);
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

  -- 1. Own editable column: allowed.
  update public.profiles set headline = headline where id = me;
  get diagnostics n = row_count;
  out := out || case when n = 1 then 'PASS' else 'FAIL' end || ' 1 own update; ';

  -- 2. Someone else's row: no row changes.
  update public.profiles set headline = 'x' where id = other;
  get diagnostics n = row_count;
  out := out || case when n = 0 then 'PASS' else 'FAIL' end || ' 2 other row update; ';

  -- 3-6. Admin / server columns: refused.
  begin
    update public.profiles set role = 'teacher' where id = me;
    out := out || 'FAIL 3 role write; ';
  exception when insufficient_privilege then
    out := out || 'PASS 3 role write; ';
  end;
  begin
    update public.profiles set is_verified = true where id = me;
    out := out || 'FAIL 4 is_verified write; ';
  exception when insufficient_privilege then
    out := out || 'PASS 4 is_verified write; ';
  end;
  begin
    update public.profiles set status = 'active' where id = me;
    out := out || 'FAIL 5 status write; ';
  exception when insufficient_privilege then
    out := out || 'PASS 5 status write; ';
  end;
  begin
    insert into public.profiles (id, role) values (gen_random_uuid(), 'teacher');
    out := out || 'FAIL 6 profile insert; ';
  exception when insufficient_privilege then
    out := out || 'PASS 6 profile insert; ';
  end;

  -- 7. Detail row for someone else: refused by RLS.
  begin
    insert into public.student_details (profile_id) values (other)
      on conflict (profile_id) do update set note = 'x';
    out := out || 'FAIL 7 other details write; ';
  exception when insufficient_privilege then
    out := out || 'PASS 7 other details write; ';
  end;

  -- 8. Read while signed in: allowed.
  select count(*) into n from public.profiles;
  out := out || case when n >= 2 then 'PASS' else 'FAIL' end || ' 8 signed-in read; ';

  perform set_config('rls.result', out, true);
end;
$$;

-- 9. Signed out (anon): no read.
reset role;
set local role anon;
do $$
begin
  perform 1 from public.profiles limit 1;
  perform set_config('rls.result', current_setting('rls.result') || 'FAIL 9 anon read; ', true);
exception when insufficient_privilege then
  perform set_config('rls.result', current_setting('rls.result') || 'PASS 9 anon read; ', true);
end;
$$;

reset role;
select current_setting('rls.result')
  || case when current_setting('rls.anon_can_delete') = 'false'
          then 'PASS 10 anon cannot call delete_my_account'
          else 'FAIL 10 anon can call delete_my_account' end
  as rls_check_result;

rollback;
