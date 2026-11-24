-- PHASE_005_BACKEND_ADD_STORAGE_PHOTOS_CERTIFICATES
-- Storage buckets and policies for profile photos and teacher certificates.
--
-- Apply: paste into the Supabase SQL editor after the PHASE_004 migrations
-- (decision 9), then run supabase/tests/storage_policies_checks.sql.
--
-- Buckets (limits are enforced by Storage on every upload):
--   avatars       public read (decision 4), JPEG only, 1 MB
--                 (the app uploads ~60 KB compressed photos)
--   certificates  private, PDF only, 3 MB (decision 2); readable only by
--                 the owner (in-app viewer, decision 6). No admin policy
--                 yet: the admin reviews in the dashboard until the admin
--                 phase.
--
-- Paths: every file lives in its owner's folder, `<auth user id>/<file>`
-- (built by lib/data/repositories/supabase/supabase_media_repository.dart).
-- Users can write, list and delete only inside their own folder; only
-- teachers can upload certificates. One certificate per teacher is enforced
-- in the app (decision 2), not here.
--
-- SQL cannot delete Storage files; account deletion removes them through
-- the Storage API before calling delete_my_account().
--
-- Rollback (ONLY on a project without real users):
--   drop policy if exists "avatars: owner reads own folder" on storage.objects;
--   drop policy if exists "avatars: owner uploads" on storage.objects;
--   drop policy if exists "avatars: owner updates" on storage.objects;
--   drop policy if exists "avatars: owner deletes" on storage.objects;
--   drop policy if exists "certificates: owner reads" on storage.objects;
--   drop policy if exists "certificates: teacher uploads" on storage.objects;
--   drop policy if exists "certificates: owner updates" on storage.objects;
--   drop policy if exists "certificates: owner deletes" on storage.objects;
--   then empty both buckets in the dashboard (Storage) and delete them
--   there (Storage refuses to delete a bucket that still has files).

-- --------------------------------------------------------------- buckets

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values
  ('avatars', 'avatars', true, 1048576, array['image/jpeg']),
  ('certificates', 'certificates', false, 3145728, array['application/pdf'])
on conflict (id) do update
  set public = excluded.public,
      file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

-- -------------------------------------------------------------- avatars
-- Public URLs need no select policy; the owner's select policy is for
-- listing their folder (account deletion).

create policy "avatars: owner reads own folder"
  on storage.objects for select to authenticated
  using (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

create policy "avatars: owner uploads"
  on storage.objects for insert to authenticated
  with check (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

create policy "avatars: owner updates"
  on storage.objects for update to authenticated
  using (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  )
  with check (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

create policy "avatars: owner deletes"
  on storage.objects for delete to authenticated
  using (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

-- --------------------------------------------------------- certificates

create policy "certificates: owner reads"
  on storage.objects for select to authenticated
  using (
    bucket_id = 'certificates'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

create policy "certificates: teacher uploads"
  on storage.objects for insert to authenticated
  with check (
    bucket_id = 'certificates'
    and (storage.foldername(name))[1] = (select auth.uid())::text
    and exists (
      select 1 from public.profiles p
      where p.id = (select auth.uid()) and p.role = 'teacher'
    )
  );

create policy "certificates: owner updates"
  on storage.objects for update to authenticated
  using (
    bucket_id = 'certificates'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  )
  with check (
    bucket_id = 'certificates'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

create policy "certificates: owner deletes"
  on storage.objects for delete to authenticated
  using (
    bucket_id = 'certificates'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );
