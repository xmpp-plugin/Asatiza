-- PHASE_006 read-only checks for profiles.status
-- (20261126120000_profile_status.sql). Changes nothing.
--
-- Run in the Supabase SQL editor after the migration. Every row of the first
-- result should show ok = true. The second result lists every profile with
-- its status and, for incomplete ones, the required fields still missing.

select 'status column exists' as check_name,
       exists (select 1 from information_schema.columns
               where table_schema = 'public' and table_name = 'profiles'
                 and column_name = 'status') as ok
union all
select 'completion_pct removed',
       not exists (select 1 from information_schema.columns
                   where table_schema = 'public' and table_name = 'profiles'
                     and column_name = 'completion_pct')
union all
select 'is_visible removed',
       not exists (select 1 from information_schema.columns
                   where table_schema = 'public' and table_name = 'profiles'
                     and column_name = 'is_visible')
union all
select 'profile_strength removed',
       to_regprocedure('private.profile_strength(public.profiles)') is null
union all
select 'profile_is_complete exists',
       to_regprocedure('private.profile_is_complete(public.profiles)') is not null
union all
select 'app cannot write status',
       not has_column_privilege('authenticated', 'public.profiles', 'status', 'UPDATE')
union all
select 'app can read status',
       has_column_privilege('authenticated', 'public.profiles', 'status', 'SELECT')
union all
select 'stored status matches the rule',
       not exists (select 1 from public.profiles p
                   where p.status <> case when private.profile_is_complete(p)
                                          then 'active' else 'incomplete' end);

select p.role, p.full_name, p.status, p.is_verified,
       array_remove(array[
         case when nullif(btrim(p.full_name), '') is null then 'name' end,
         case when p.gender is null then 'gender' end,
         case when cardinality(p.languages) = 0 then 'languages' end,
         case when nullif(btrim(p.country), '') is null then 'country' end,
         case when nullif(btrim(p.timezone), '') is null then 'time zone' end,
         case when p.role = 'teacher' and nullif(btrim(p.headline), '') is null then 'headline' end,
         case when p.role = 'teacher' and nullif(btrim(p.bio), '') is null then 'bio' end,
         case when p.role = 'teacher' and coalesce(cardinality(t.subjects), 0) = 0 then 'subjects' end,
         case when p.role = 'teacher' and t.experience_years is null then 'experience' end,
         case when p.role = 'teacher' and nullif(btrim(t.qualifications), '') is null then 'qualifications' end,
         case when p.role = 'teacher' and t.fee_amount is null then 'fee' end,
         case when p.role = 'teacher' and coalesce(jsonb_array_length(
                case when jsonb_typeof(t.availability -> 'days') = 'array'
                     then t.availability -> 'days' end), 0) = 0 then 'available days' end,
         case when p.role = 'teacher' and coalesce(cardinality(t.teaches), 0) = 0 then 'teaches' end,
         case when p.role = 'student' and s.age_group is null then 'who is learning' end,
         case when p.role = 'student' and coalesce(cardinality(s.goals), 0) = 0 then 'goals' end,
         case when p.role = 'student' and s.level is null then 'level' end,
         case when p.role = 'student' and s.preferred_teacher_gender is null then 'preferred teacher gender' end
       ], null) as missing
from public.profiles p
left join public.teacher_details t on t.profile_id = p.id
left join public.student_details s on s.profile_id = p.id
order by p.role, p.status, p.created_at desc;
