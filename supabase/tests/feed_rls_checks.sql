-- PHASE_010 manual checks for the feed (20261202120000_feed.sql).
--
-- Run in the Supabase SQL editor AFTER the migration. Uses the two oldest
-- ACTIVE profiles ("me" and "other"); a third profile, if any, is used for
-- the 3-reporter auto-hide check (SKIPPED otherwise).
--
-- Safe with real data: everything runs in ONE transaction that is always
-- rolled back. Inside it the script first clears the two profiles' posts,
-- comments, reports and any block between them so every check starts
-- clean; the final ROLLBACK restores all of it. Nothing is committed.
--
-- Result: one row, "feed_check_result", listing PASS / FAIL per check.

begin;

select set_config('rls.me', coalesce((
  select id::text from public.profiles where status = 'active'
  order by created_at limit 1), ''), true);
select set_config('rls.other', coalesce((
  select id::text from public.profiles where status = 'active'
  order by created_at offset 1 limit 1), ''), true);
select set_config('rls.third', coalesce((
  select id::text from public.profiles
  where id::text not in (current_setting('rls.me'), current_setting('rls.other'))
  order by created_at limit 1), ''), true);

-- Clean state for this transaction only (undone by the final ROLLBACK).
delete from public.reports
where reporter_id::text in (current_setting('rls.me'), current_setting('rls.other'));
delete from public.post_comments
where author_id::text in (current_setting('rls.me'), current_setting('rls.other'));
delete from public.posts
where author_id::text in (current_setting('rls.me'), current_setting('rls.other'));
delete from public.blocks
where blocker_id::text in (current_setting('rls.me'), current_setting('rls.other'))
  and blocked_id::text in (current_setting('rls.me'), current_setting('rls.other'));

set local role authenticated;

do $$
declare
  me uuid := nullif(current_setting('rls.me'), '')::uuid;
  other uuid := nullif(current_setting('rls.other'), '')::uuid;
  third uuid := nullif(current_setting('rls.third'), '')::uuid;
  post public.posts;
  cmt public.post_comments;
  liked boolean;
  n int;
  out text := '';
begin
  if me is null or other is null then
    perform set_config('rls.result', 'SKIPPED: need two active profiles', true);
    return;
  end if;

  perform set_config('request.jwt.claims',
    json_build_object('sub', me, 'role', 'authenticated')::text, true);

  -- 1. Direct writes refused.
  begin
    insert into public.posts (author_id, body, tag) values (me, 'x', 'hifz');
    out := out || 'FAIL 1 direct insert; ';
  exception when insufficient_privilege then
    out := out || 'PASS 1 direct insert; ';
  end;

  -- 2. Create a post.
  post := public.create_post('Assalamu alaikum, Tajweed tip of the day', 'tajweed_tip', null, null);
  out := out || case when post.author_id = me then 'PASS' else 'FAIL' end
    || ' 2 create post; ';

  -- 3-6. Refusals.
  begin
    perform public.create_post('   ', 'hifz', null, null);
    out := out || 'FAIL 3 empty post; ';
  exception when others then
    out := out || case when sqlerrm = 'post_empty' then 'PASS' else 'FAIL' end || ' 3 empty post; ';
  end;
  begin
    perform public.create_post(repeat('a', 1501), 'hifz', null, null);
    out := out || 'FAIL 4 long post; ';
  exception when others then
    out := out || case when sqlerrm = 'post_too_long' then 'PASS' else 'FAIL' end || ' 4 long post; ';
  end;
  begin
    perform public.create_post('No tag', null, null, null);
    out := out || 'FAIL 5 missing tag; ';
  exception when others then
    out := out || case when sqlerrm = 'post_tag_missing' then 'PASS' else 'FAIL' end || ' 5 missing tag; ';
  end;
  begin
    perform public.create_post('Photo', 'hifz', other::text || '/post_1.jpg', null);
    out := out || 'FAIL 6 foreign photo path; ';
  exception when others then
    out := out || case when sqlerrm = 'invalid_image' then 'PASS' else 'FAIL' end || ' 6 foreign photo path; ';
  end;

  -- ------------------------------------------------------ as "other"
  perform set_config('request.jwt.claims',
    json_build_object('sub', other, 'role', 'authenticated')::text, true);

  -- 7. The other person sees it in the feed.
  select count(*) into n from public.list_feed(100, 0) f where f.id = post.id;
  out := out || case when n = 1 then 'PASS' else 'FAIL' end || ' 7 feed shows post; ';

  -- 8. Like, count, unlike.
  liked := public.toggle_post_like(post.id);
  select like_count into n from public.posts where id = post.id;
  out := out || case when liked and n = 1 then 'PASS' else 'FAIL' end || ' 8 like; ';
  liked := public.toggle_post_like(post.id);
  select like_count into n from public.posts where id = post.id;
  out := out || case when not liked and n = 0 then 'PASS' else 'FAIL' end || ' 9 unlike; ';

  -- 10. Comment and count.
  cmt := public.add_comment(post.id, 'JazakAllahu khairan');
  select comment_count into n from public.posts where id = post.id;
  out := out || case when n = 1 then 'PASS' else 'FAIL' end || ' 10 comment; ';

  -- 11. Report twice = one report.
  perform public.report_content('post', post.id, 'spam');
  perform public.report_content('post', post.id, 'spam');
  select count(*) into n from public.reports
    where target_type = 'post' and target_id = post.id;
  out := out || case when n = 1 then 'PASS' else 'FAIL' end || ' 11 report once; ';

  -- ------------------------------------------------------ back to "me"
  perform set_config('request.jwt.claims',
    json_build_object('sub', me, 'role', 'authenticated')::text, true);

  -- 12. Someone else's comment cannot be deleted.
  begin
    perform public.delete_comment(cmt.id);
    out := out || 'FAIL 12 delete other comment; ';
  exception when others then
    out := out || case when sqlerrm = 'not_found' then 'PASS' else 'FAIL' end || ' 12 delete other comment; ';
  end;

  -- 13. A second reporter: still visible (needs 3).
  perform public.report_content('post', post.id, 'inappropriate');
  perform set_config('request.jwt.claims',
    json_build_object('sub', other, 'role', 'authenticated')::text, true);
  select count(*) into n from public.posts where id = post.id;
  out := out || case when n = 1 then 'PASS' else 'FAIL' end || ' 13 two reports keep it visible; ';

  -- 14. A third reporter hides it; the author still sees it.
  if third is not null then
    perform set_config('request.jwt.claims',
      json_build_object('sub', third, 'role', 'authenticated')::text, true);
    perform public.report_content('post', post.id, 'false_information');
    perform set_config('request.jwt.claims',
      json_build_object('sub', other, 'role', 'authenticated')::text, true);
    select count(*) into n from public.posts where id = post.id;
    out := out || case when n = 0 then 'PASS' else 'FAIL' end || ' 14 hidden after 3 reports; ';
    perform set_config('request.jwt.claims',
      json_build_object('sub', me, 'role', 'authenticated')::text, true);
    select count(*) into n from public.posts where id = post.id and is_hidden;
    out := out || case when n = 1 then 'PASS' else 'FAIL' end || ' 15 author sees own hidden post; ';
  else
    out := out || 'SKIPPED 14-15 auto-hide (needs a third profile); ';
  end if;

  -- 16. Search finds the post.
  perform set_config('request.jwt.claims',
    json_build_object('sub', me, 'role', 'authenticated')::text, true);
  select count(*) into n from public.search_posts('tajweed tip', 30) s where s.id = post.id;
  out := out || case when n = 1 then 'PASS' else 'FAIL' end || ' 16 search; ';

  -- 17. Daily post limit: 10 in 24 hours, the 11th refused.
  select count(*) into n from public.posts
    where author_id = me and created_at > now() - interval '24 hours';
  for i in (n + 1)..10 loop
    perform public.create_post('Post ' || i, 'reminder', null, null);
  end loop;
  begin
    perform public.create_post('One too many', 'reminder', null, null);
    out := out || 'FAIL 17 daily post limit; ';
  exception when others then
    out := out || case when sqlerrm = 'daily_post_limit' then 'PASS' else 'FAIL' end || ' 17 daily post limit; ';
  end;

  perform set_config('rls.post', post.id::text, true);
  perform set_config('rls.result', out, true);
end;
$$;

do $$
declare
  me uuid := nullif(current_setting('rls.me'), '')::uuid;
  other uuid := nullif(current_setting('rls.other'), '')::uuid;
  target uuid;
  n int;
  out text := current_setting('rls.result');
begin
  if me is null or other is null then
    return;
  end if;
  perform set_config('request.jwt.claims',
    json_build_object('sub', me, 'role', 'authenticated')::text, true);
  select id into target from public.posts
    where author_id = me and not is_hidden order by created_at desc limit 1;

  -- 18. Daily comment limit: 100 in 24 hours, the 101st refused.
  select count(*) into n from public.post_comments
    where author_id = me and created_at > now() - interval '24 hours';
  for i in (n + 1)..100 loop
    perform public.add_comment(target, 'Comment ' || i);
  end loop;
  begin
    perform public.add_comment(target, 'One too many');
    out := out || 'FAIL 18 daily comment limit; ';
  exception when others then
    out := out || case when sqlerrm = 'daily_comment_limit' then 'PASS' else 'FAIL' end || ' 18 daily comment limit; ';
  end;

  -- 19. Block hides posts both ways.
  insert into public.blocks (blocker_id, blocked_id) values (me, other);
  perform set_config('request.jwt.claims',
    json_build_object('sub', other, 'role', 'authenticated')::text, true);
  select count(*) into n from public.posts where author_id = me;
  out := out || case when n = 0 then 'PASS' else 'FAIL' end || ' 19 blocked: posts hidden; ';

  -- 20. Someone else's post cannot be deleted; your own can.
  begin
    perform public.delete_post(target);
    out := out || 'FAIL 20 delete other post; ';
  exception when others then
    out := out || case when sqlerrm = 'not_found' then 'PASS' else 'FAIL' end || ' 20 delete other post; ';
  end;
  perform set_config('request.jwt.claims',
    json_build_object('sub', me, 'role', 'authenticated')::text, true);
  perform public.delete_post(target);
  select count(*) into n from public.posts where id = target;
  out := out || case when n = 0 then 'PASS' else 'FAIL' end || ' 21 delete own post; ';

  perform set_config('rls.result', out, true);
end;
$$;

-- 22. Signed out (anon): no access.
reset role;
set local role anon;
do $$
begin
  perform 1 from public.posts limit 1;
  perform set_config('rls.result',
    current_setting('rls.result') || 'FAIL 22 anon read; ', true);
exception when insufficient_privilege then
  perform set_config('rls.result',
    current_setting('rls.result') || 'PASS 22 anon read; ', true);
end;
$$;

reset role;
select current_setting('rls.result') as feed_check_result;

rollback;
