-- PHASE_004_BACKEND_ADD_SUPABASE_AUTH_PROFILES
-- Account deletion (decision 4): the signed-in user deletes their own auth
-- user; profiles and detail rows go with it (on delete cascade). Later
-- phases add their tables with `on delete cascade` to auth.users / profiles
-- and their Storage clean-up here.
--
-- Called by the app with rpc('delete_my_account').
--
-- Rollback: drop function if exists public.delete_my_account();

create or replace function public.delete_my_account()
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'not signed in' using errcode = '42501';
  end if;
  delete from auth.users where id = v_uid;
end;
$$;

revoke all on function public.delete_my_account() from public, anon;
grant execute on function public.delete_my_account() to authenticated;
