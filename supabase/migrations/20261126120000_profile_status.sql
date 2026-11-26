-- PHASE_006_BACKEND_ADD_SUPABASE_DISCOVER_TEACHERS_STUDENTS (scope change)
-- Profile status replaces the percentage (owner decision 2026-11-26).
--
-- A profile is 'active' when every required field is filled, otherwise
-- 'incomplete'. The database sets it on every save; the app only reads it.
-- Teachers and students are listed when active (no admin approval needed;
-- "Looking for a teacher" is information only). `is_verified` stays: it is
-- only the Verified badge (admin certificate review).
--
-- Required fields — keep in step with
-- lib/core/logic/profile_completeness_rules.dart:
--   teacher: full_name, gender, headline, >= 1 subject, >= 1 language,
--            country and timezone, bio, experience_years and qualifications,
--            fee_amount (0 = free) and >= 1 available day, >= 1 "teaches";
--   student: full_name, gender, age_group, >= 1 goal, level,
--            >= 1 language, country and timezone, preferred_teacher_gender.
--   Optional: photo, certificate, note, looking_for_teacher.
--
-- Removes: profiles.completion_pct, profiles.is_visible,
--          private.profile_strength().
--
-- Apply: paste into the Supabase SQL editor after the earlier migrations,
-- then run supabase/tests/profile_status_checks.sql. Apply it BEFORE running
-- an app build from PHASE_006: that build reads profiles.status.
--
-- Rollback (restores the previous rule; no profile data is lost):
--   1. alter table public.profiles
--        add column completion_pct int not null default 0
--          check (completion_pct between 0 and 100),
--        add column is_visible boolean not null default false;
--   2. Re-run, from 20261123120000_profiles.sql, the
--      `create or replace function private.profile_strength` and
--      `create or replace function private.profiles_before_write` blocks,
--      then `revoke all on all functions in schema private
--      from public, anon, authenticated;`.
--   3. update public.profiles set updated_at = now();   -- recompute
--   4. alter table public.profiles drop column status;
--      drop function if exists private.profile_is_complete(public.profiles);

-- ------------------------------------------------------------- column

alter table public.profiles
  add column status text not null default 'incomplete'
    check (status in ('incomplete', 'active'));

-- ------------------------------------------------- required-field check

create or replace function private.profile_is_complete(p public.profiles)
returns boolean
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  t public.teacher_details;
  s public.student_details;
  base boolean;
begin
  base := nullif(btrim(p.full_name), '') is not null
    and p.gender is not null
    and cardinality(p.languages) > 0
    and nullif(btrim(p.country), '') is not null
    and nullif(btrim(p.timezone), '') is not null;
  if not base then
    return false;
  end if;

  if p.role = 'teacher' then
    select * into t from public.teacher_details where profile_id = p.id;
    if not found then
      return false;
    end if;
    return nullif(btrim(p.headline), '') is not null
      and nullif(btrim(p.bio), '') is not null
      and cardinality(t.subjects) > 0
      and t.experience_years is not null
      and nullif(btrim(t.qualifications), '') is not null
      and t.fee_amount is not null
      and jsonb_typeof(t.availability -> 'days') = 'array'
      and jsonb_array_length(t.availability -> 'days') > 0
      and cardinality(t.teaches) > 0;
  end if;

  select * into s from public.student_details where profile_id = p.id;
  if not found then
    return false;
  end if;
  return s.age_group is not null
    and cardinality(s.goals) > 0
    and s.level is not null
    and s.preferred_teacher_gender is not null;
end;
$$;

-- Replaces the PHASE_004 body (which computed completion_pct / is_visible).
create or replace function private.profiles_before_write()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  new.status := case when private.profile_is_complete(new)
                     then 'active' else 'incomplete' end;
  new.updated_at := now();
  return new;
end;
$$;

-- --------------------------------------------- remove the percentage

drop function if exists private.profile_strength(public.profiles);

alter table public.profiles
  drop column completion_pct,
  drop column is_visible;

revoke all on all functions in schema private from public, anon, authenticated;

-- Privileges: `status` gets no update grant (the column-level update grant
-- from PHASE_004 lists only the editable columns), so the app can read it
-- but never write it. RLS policies are unchanged.

-- ------------------------------------------------ recompute every row

update public.profiles set updated_at = now();
