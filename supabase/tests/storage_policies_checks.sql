-- PHASE_005 manual Storage policy checks (avatars, certificates).
--
-- Run in the Supabase SQL editor AFTER
-- 20261124120000_storage_avatars_certificates.sql, once at least one
-- teacher and one student have signed up. Changes nothing: the whole script
-- runs in a transaction that is rolled back (the test rows written to
-- storage.objects are metadata only; no file is stored).
--
-- Result: one row, "storage_check_result", listing PASS / FAIL per check.

begin;

select set_config('st.teacher',
  coalesce((select id::text from public.profiles where role = 'teacher'
            order by created_at limit 1), ''), true);
select set_config('st.student',
  coalesce((select id::text from public.profiles where role = 'student'
            order by created_at limit 1), ''), true);

-- 0. Bucket settings.
select set_config('st.result',
  case when exists (select 1 from storage.buckets
                    where id = 'avatars' and public
                      and file_size_limit = 1048576
                      and allowed_mime_types = array['image/jpeg'])
       then 'PASS' else 'FAIL' end || ' 0a avatars bucket; '
  || case when exists (select 1 from storage.buckets
                       where id = 'certificates' and not public
                         and file_size_limit = 3145728
                         and allowed_mime_types = array['application/pdf'])
          then 'PASS' else 'FAIL' end || ' 0b certificates bucket; ',
  true);

-- A certificate of the student's folder, written as the admin (bypasses
-- RLS), so check 5 has something the teacher must not see.
insert into storage.objects (bucket_id, name)
select 'certificates', current_setting('st.student') || '/0-check.pdf'
where current_setting('st.student') <> '';

-- ---------------------------------------------------------- as teacher
select set_config('request.jwt.claims',
  json_build_object('sub', current_setting('st.teacher'),
                    'role', 'authenticated')::text, true);
set local role authenticated;

do $$
declare
  teacher text := current_setting('st.teacher');
  student text := current_setting('st.student');
  n int;
  out text := current_setting('st.result');
begin
  if teacher = '' or student = '' then
    perform set_config('st.result',
      out || 'SKIPPED: need one teacher and one student', true);
    return;
  end if;

  -- 1. Own avatar folder: allowed.
  begin
    insert into storage.objects (bucket_id, name)
      values ('avatars', teacher || '/avatar-check.jpg');
    out := out || 'PASS 1 own avatar upload; ';
  exception when insufficient_privilege then
    out := out || 'FAIL 1 own avatar upload; ';
  end;

  -- 2. Someone else's avatar folder: refused.
  begin
    insert into storage.objects (bucket_id, name)
      values ('avatars', student || '/avatar-check.jpg');
    out := out || 'FAIL 2 other avatar upload; ';
  exception when insufficient_privilege then
    out := out || 'PASS 2 other avatar upload; ';
  end;

  -- 3. Teacher's own certificate: allowed.
  begin
    insert into storage.objects (bucket_id, name)
      values ('certificates', teacher || '/1-check.pdf');
    out := out || 'PASS 3 teacher certificate upload; ';
  exception when insufficient_privilege then
    out := out || 'FAIL 3 teacher certificate upload; ';
  end;

  -- 4. Own folder is listed.
  select count(*) into n from storage.objects
    where bucket_id = 'certificates' and name like teacher || '/%';
  out := out || case when n >= 1 then 'PASS' else 'FAIL' end
    || ' 4 own certificates visible; ';

  -- 5. Someone else's certificates: invisible.
  select count(*) into n from storage.objects
    where bucket_id = 'certificates' and name like student || '/%';
  out := out || case when n = 0 then 'PASS' else 'FAIL' end
    || ' 5 other certificates hidden; ';

  perform set_config('st.result', out, true);
end;
$$;

-- ---------------------------------------------------------- as student
reset role;
select set_config('request.jwt.claims',
  json_build_object('sub', current_setting('st.student'),
                    'role', 'authenticated')::text, true);
set local role authenticated;

do $$
declare
  student text := current_setting('st.student');
begin
  if student = '' then
    return;
  end if;
  -- 6. Students cannot upload certificates.
  begin
    insert into storage.objects (bucket_id, name)
      values ('certificates', student || '/2-check.pdf');
    perform set_config('st.result',
      current_setting('st.result') || 'FAIL 6 student certificate upload; ', true);
  exception when insufficient_privilege then
    perform set_config('st.result',
      current_setting('st.result') || 'PASS 6 student certificate upload; ', true);
  end;
end;
$$;

-- ------------------------------------------------------------- as anon
reset role;
set local role anon;

do $$
begin
  -- 7. Signed out: no upload.
  begin
    insert into storage.objects (bucket_id, name)
      values ('avatars', 'anon/avatar-check.jpg');
    perform set_config('st.result',
      current_setting('st.result') || 'FAIL 7 anon upload; ', true);
  exception when insufficient_privilege then
    perform set_config('st.result',
      current_setting('st.result') || 'PASS 7 anon upload; ', true);
  end;
end;
$$;

reset role;
select current_setting('st.result') as storage_check_result;

rollback;
