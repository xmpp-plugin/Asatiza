-- PHASE_004_BACKEND_ADD_SUPABASE_AUTH_PROFILES
-- Profiles, teacher / student details, profile strength, RLS.
--
-- Apply: paste into the Supabase SQL editor (decision 7), then
-- 20261123120100_delete_my_account.sql, then run
-- supabase/tests/profiles_rls_checks.sql once two users have signed up.
--
-- Enum values are snake_case text matching the Dart enums
-- (lib/data/repositories/supabase/profile_row_mapper.dart).
-- Text limits match the app (headline 60, bio 600, qualifications 300,
-- note 200).
--
-- Admin-only columns: role (set once by handle_new_user), is_verified.
-- Server-computed: completion_pct, is_visible (mirror
-- lib/core/logic/profile_strength_calculator.dart and
-- discover_visibility_rules.dart — change both together).
--
-- Rollback (ONLY on a project without real users; deletes all profile data):
--   drop trigger if exists on_auth_user_created on auth.users;
--   drop table if exists public.teacher_details, public.student_details,
--     public.profiles cascade;
--   drop schema if exists private cascade;

create schema if not exists private;

-- ---------------------------------------------------------------- tables

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  role text not null check (role in ('student', 'teacher')),
  full_name text not null default '' check (char_length(full_name) <= 100),
  headline text check (char_length(headline) <= 60),
  photo_path text,
  gender text check (gender in ('male', 'female')),
  country text check (char_length(country) <= 80),
  city text check (char_length(city) <= 80),
  timezone text check (char_length(timezone) <= 20),
  languages text[] not null default '{}' check (
    languages <@ array['urdu', 'english', 'arabic', 'punjabi', 'pashto', 'hindi']
  ),
  bio text check (char_length(bio) <= 600),
  completion_pct int not null default 0 check (completion_pct between 0 and 100),
  is_visible boolean not null default false,
  is_verified boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.teacher_details (
  profile_id uuid primary key references public.profiles (id) on delete cascade,
  subjects text[] not null default '{}' check (
    subjects <@ array['noorani_qaida', 'nazra', 'tajweed', 'hifz', 'tafsir',
                      'arabic', 'islamic_studies']
  ),
  experience_years int check (experience_years between 0 and 80),
  qualifications text check (char_length(qualifications) <= 300),
  fee_amount int check (fee_amount >= 0),
  fee_currency text not null default 'USD' check (fee_currency ~ '^[A-Z]{3}$'),
  fee_unit text check (fee_unit in ('per_class', 'per_month')),
  -- {"days": ["monday", …], "from_minutes": 540, "to_minutes": 1020}
  availability jsonb not null default '{}'::jsonb
    check (jsonb_typeof(availability) = 'object'),
  teaches text[] not null default '{}' check (
    teaches <@ array['children', 'women', 'men', 'all']
  ),
  certificate_paths text[] not null default '{}'
);

create table public.student_details (
  profile_id uuid primary key references public.profiles (id) on delete cascade,
  age_group text check (age_group in ('child', 'teen', 'adult')),
  goals text[] not null default '{}' check (
    goals <@ array['noorani_qaida', 'nazra', 'tajweed', 'hifz', 'tafsir',
                   'arabic', 'islamic_studies']
  ),
  level text check (
    level in ('beginner', 'reads_with_help', 'reads_fluently', 'memorising')
  ),
  preferred_teacher_gender text check (
    preferred_teacher_gender in ('any', 'male', 'female')
  ),
  looking_for_teacher boolean not null default false,
  note text check (char_length(note) <= 200)
);

-- ------------------------------------------------------ profile strength

-- Mirrors ProfileStrengthCalculator (weights) and DiscoverVisibilityRules
-- (teacher listed: verified and >= 80; student listed: looking and >= 60).
create or replace function private.profile_strength(p public.profiles)
returns table (pct int, visible boolean)
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  t public.teacher_details;
  s public.student_details;
  total int := 0;
begin
  if p.role = 'teacher' then
    select * into t from public.teacher_details where profile_id = p.id;
    if nullif(btrim(p.photo_path), '') is not null then total := total + 15; end if;
    if nullif(btrim(p.headline), '') is not null then total := total + 10; end if;
    if coalesce(cardinality(t.subjects), 0) > 0 then total := total + 15; end if;
    if cardinality(p.languages) > 0 then total := total + 10; end if;
    if nullif(btrim(p.bio), '') is not null then total := total + 15; end if;
    if t.experience_years is not null
       and nullif(btrim(t.qualifications), '') is not null then
      total := total + 10;
    end if;
    if t.fee_amount is not null
       and jsonb_typeof(t.availability -> 'days') = 'array'
       and jsonb_array_length(t.availability -> 'days') > 0 then
      total := total + 15;
    end if;
    if coalesce(cardinality(t.certificate_paths), 0) > 0 then total := total + 10; end if;
    pct := total;
    visible := p.is_verified and total >= 80;
  else
    select * into s from public.student_details where profile_id = p.id;
    if coalesce(cardinality(s.goals), 0) > 0 then total := total + 25; end if;
    if s.age_group is not null then total := total + 15; end if;
    if s.level is not null then total := total + 15; end if;
    if cardinality(p.languages) > 0 then total := total + 15; end if;
    if nullif(btrim(p.country), '') is not null
       or nullif(btrim(p.timezone), '') is not null then
      total := total + 10;
    end if;
    if s.preferred_teacher_gender is not null then total := total + 10; end if;
    if nullif(btrim(p.photo_path), '') is not null
       or nullif(btrim(s.note), '') is not null then
      total := total + 10;
    end if;
    pct := total;
    visible := coalesce(s.looking_for_teacher, false) and total >= 60;
  end if;
  return next;
end;
$$;

create or replace function private.profiles_before_write()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  r record;
begin
  select * into r from private.profile_strength(new);
  new.completion_pct := r.pct;
  new.is_visible := r.visible;
  new.updated_at := now();
  return new;
end;
$$;

create trigger profiles_before_write
  before insert or update on public.profiles
  for each row execute function private.profiles_before_write();

-- A detail change re-runs the profiles trigger (recomputes the strength).
create or replace function private.details_after_write()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  update public.profiles set updated_at = now() where id = new.profile_id;
  return null;
end;
$$;

create trigger teacher_details_after_write
  after insert or update on public.teacher_details
  for each row execute function private.details_after_write();

create trigger student_details_after_write
  after insert or update on public.student_details
  for each row execute function private.details_after_write();

-- ------------------------------------------------------------ new users

-- Creates the profile (+ empty detail row) from the sign-up metadata. The
-- role is set here once; the app can never change it.
create or replace function private.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_role text := new.raw_user_meta_data ->> 'role';
begin
  if v_role is null or v_role not in ('student', 'teacher') then
    v_role := 'student';
  end if;
  insert into public.profiles (id, role, full_name)
  values (
    new.id,
    v_role,
    left(coalesce(btrim(new.raw_user_meta_data ->> 'full_name'), ''), 100)
  );
  if v_role = 'teacher' then
    insert into public.teacher_details (profile_id) values (new.id);
  else
    insert into public.student_details (profile_id) values (new.id);
  end if;
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function private.handle_new_user();

revoke all on all functions in schema private from public, anon, authenticated;

-- ------------------------------------------------- privileges and RLS

alter table public.profiles enable row level security;
alter table public.teacher_details enable row level security;
alter table public.student_details enable row level security;

revoke all on public.profiles, public.teacher_details, public.student_details
  from anon, authenticated;

-- Profiles: read when signed in; update only the editable columns of your
-- own row. No insert / delete (trigger and account deletion do that).
grant select on public.profiles to authenticated;
grant update (full_name, headline, photo_path, gender, country, city,
              timezone, languages, bio)
  on public.profiles to authenticated;

create policy "profiles: signed-in users read"
  on public.profiles for select to authenticated
  using (true);

create policy "profiles: owner updates own row"
  on public.profiles for update to authenticated
  using (id = (select auth.uid()))
  with check (id = (select auth.uid()));

-- Details: read when signed in; insert / update only your own row, and only
-- the table that matches your role.
grant select, insert, update on public.teacher_details, public.student_details
  to authenticated;

create policy "teacher_details: signed-in users read"
  on public.teacher_details for select to authenticated
  using (true);

create policy "teacher_details: teacher inserts own row"
  on public.teacher_details for insert to authenticated
  with check (
    profile_id = (select auth.uid())
    and exists (select 1 from public.profiles p
                where p.id = (select auth.uid()) and p.role = 'teacher')
  );

create policy "teacher_details: teacher updates own row"
  on public.teacher_details for update to authenticated
  using (profile_id = (select auth.uid()))
  with check (profile_id = (select auth.uid()));

create policy "student_details: signed-in users read"
  on public.student_details for select to authenticated
  using (true);

create policy "student_details: student inserts own row"
  on public.student_details for insert to authenticated
  with check (
    profile_id = (select auth.uid())
    and exists (select 1 from public.profiles p
                where p.id = (select auth.uid()) and p.role = 'student')
  );

create policy "student_details: student updates own row"
  on public.student_details for update to authenticated
  using (profile_id = (select auth.uid()))
  with check (profile_id = (select auth.uid()));
