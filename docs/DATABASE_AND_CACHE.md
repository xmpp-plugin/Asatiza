# Database And Cache

## Verified

VERIFIED 2026-11-26 (`PHASE_008`): `supabase/migrations/20261128120000_connections.sql` — `public.connections` (one row per pair, statuses pending / accepted / declined / removed, note ≤ 200, `responded_at`), select-only RLS for the two members; writes only through `send_connection_request(p_receiver, p_note)` (both active, no block either way, no pending / accepted, 3 days after a decline for the same requester, 10 per requester per rolling 24 h), `respond_to_connection(p_id, p_accept)` (receiver of a pending request), `remove_connection(p_id)` (status `removed`, row kept); `connection_count(p_user)` (accepted count, 0 when hidden by a block); trigger `blocks_remove_connection` removes a connection when either side blocks. Checks: `supabase/tests/connections_rls_checks.sql` (rolled back; the 24-hour limit is not exercised there). Applied to the remote project: UNVERIFIED — the developer applies it before running a PHASE_008 build.

VERIFIED 2026-11-26 (`PHASE_007`): `supabase/migrations/20261127120000_blocks.sql` — `public.blocks (blocker_id, blocked_id, created_at)` (PK on both ids, FKs to `profiles` on delete cascade, no self-block, index on `blocked_id`); RLS: own blocks only (select / insert of the two ids / delete), nobody reads who blocked them. Profile / detail read policies now hide a profile from people its owner blocked, unless they also blocked the owner (`private.hidden_by_block`, security definer; `authenticated` gets usage on schema `private` and execute on this one function only). Checks: `supabase/tests/blocks_rls_checks.sql` (rolled back). Applied to the remote project: UNVERIFIED — the developer applies it before running a PHASE_007 build.

VERIFIED 2026-11-26 (`PHASE_006` scope change): `supabase/migrations/20261126120000_profile_status.sql` adds `profiles.status` (`incomplete` / `active`, set by `private.profiles_before_write` from `private.profile_is_complete`: every required field filled; no update grant), drops `completion_pct`, `is_visible` and `private.profile_strength`, and recomputes every row. Lists read `status = 'active'`. Read-only checks: `supabase/tests/profile_status_checks.sql`; `profiles_rls_checks.sql` check 5 now covers `status`. Applied to the remote project: UNVERIFIED — the developer applies it in the SQL editor **before** running a PHASE_006 build. The older `is_visible` note below is superseded.

VERIFIED 2026-11-25 (`PHASE_006`): Teachers / Students lists read `profiles` where `is_visible = true` (set by `private.profile_strength`); no migration, no RLS change, no local cache (loaded on tab open and refresh).

VERIFIED 2026-11-24 (`PHASE_005`): `supabase/migrations/20261124120000_storage_avatars_certificates.sql` — buckets `avatars` (public, `image/jpeg`, 1 MB) and `certificates` (private, `application/pdf`, 3 MB) and owner-folder policies on `storage.objects` (`(storage.foldername(name))[1] = auth.uid()`; certificate insert only for `role = 'teacher'`; no admin policy yet). No table change. One certificate per teacher is an app rule (`CertificateFileRules.maxCertificates = 1`), not a database check. Manual checks: `supabase/tests/storage_policies_checks.sql`. Applied to the remote project: UNVERIFIED — the developer applies it in the SQL editor.

VERIFIED 2026-11-23 (`PHASE_004`): `supabase/migrations/20261123120000_profiles.sql` (tables `profiles` (+ `city`), `teacher_details`, `student_details`; snake_case enum text with `check` constraints; text limits as in the app; `private.profile_strength` + triggers keep `completion_pct` / `is_visible` in step with `ProfileStrengthCalculator` / `DiscoverVisibilityRules`; `private.handle_new_user` creates the profile + detail row from sign-up metadata; RLS + column privileges) and `20261123120100_delete_my_account.sql` (`security definer`, `authenticated` only). Manual checks: `supabase/tests/profiles_rls_checks.sql`. Mapping in `ProfileRowMapper`. Applied to the remote project: UNVERIFIED — the developer applies them in the SQL editor.

VERIFIED 2026-11-19 (`PHASE_002`): Dart models mirror the planned tables — `Profile` (`profiles`), `TeacherDetails` (`teacher_details`), `StudentDetails` (`student_details`), `Post` (`posts`, as seen by a viewer: `likedByMe`), `Comment` (`post_comments`). UUID string ids, storage paths not URLs, `copyWith`, `Equatable`; no JSON mapping yet (added with the Supabase phase). Mock data is in memory and resets on restart.

VERIFIED 2026-11-23 (`PHASE_003`): new models `Connection` (`connections`), `Conversation` / `Message` (`conversations` / `messages`; per-viewer `lastMessage`, `unreadCount`), `AppNotification` (`notifications`), `NotificationSettings`; enums `ConnectionStatus`, `NotificationType`, `ExperienceFilter`, `DiscoverSort`. `TeacherDetails.qualifications` now counts toward profile strength; default fee currency `USD`.

No `supabase/` folder, migrations, local database or cache code exists (audit 2026-11-18). VERIFIED

## Decided Tables (PostgreSQL on Supabase)

| Table | Main columns |
|---|---|
| `profiles` | id (auth user id), role, full_name, headline, photo_path, gender, country, timezone, languages[], bio, completion_pct, is_visible, is_verified, created_at |
| `teacher_details` | profile_id, subjects[], experience_years, qualifications, fee_amount, fee_currency, fee_unit, availability (json), teaches[], certificate_paths[] |
| `student_details` | profile_id, age_group, goals[], level, preferred_teacher_gender, looking_for_teacher, note |
| `connections` | id, requester_id, receiver_id, status, note, created_at, responded_at |
| `posts` | id, author_id, body, image_path, tag, like_count, comment_count, report_count, is_hidden, created_at |
| `post_likes` | post_id, user_id, created_at |
| `post_comments` | id, post_id, author_id, body, created_at |
| `conversations` | id, user_a, user_b, last_message, last_message_at |
| `messages` | id, conversation_id, sender_id, body, image_path, read_at, created_at |
| `notifications` | id, user_id, type, actor_id, target_id, is_read, created_at |
| `reports` | id, reporter_id, target_type, target_id, reason, status, created_at |
| `blocks` | blocker_id, blocked_id, created_at |
| `device_tokens` | user_id, fcm_token, platform, updated_at |

## Row Level Security (required)

- Users write only their own rows.
- Messages readable only by the two conversation members.
- Conversations created only from accepted connections.
- Hidden/unverified profiles and hidden posts excluded from lists.
- `role`, `is_verified` and `is_hidden` changeable only by admin.
- Blocked users filtered from every query.

## Storage Buckets

`avatars` (public read) · `post-images` (public read) · `certificates` (private; owner + admin) · `chat-images` (private; conversation members).

VERIFIED 2026-11-24 (`PHASE_005`): `avatars` and `certificates` exist in the migration (admin access to `certificates` comes with the admin phase; until then the dashboard). `post-images` and `chat-images` come with the feed and chat phases.

## Migrations

`PHASE_004`: `20261123120000_profiles.sql`, `20261123120100_delete_my_account.sql` (applied by the developer in the SQL editor, in order; rollback notes in each file header). `PHASE_005`: `20261124120000_storage_avatars_certificates.sql`. One file per change: `supabase/migrations/YYYYMMDDHHMMSS_short_description.sql`. Never edit an applied migration.

## Local Cache (DECIDED)

- Images via `cached_network_image`; thumbnails in lists.
- Session persisted by `supabase_flutter`.
- Small preferences (notification toggles) — storage choice UNVERIFIED — developer confirmation required.

## Free-Plan Limits And Upgrade Triggers

| Service | Free limit | Handling |
|---|---|---|
| Database | 500 MB | Text-only rows; monitor monthly |
| Storage | 1 GB | Compress photos (posts ~200 KB, avatars ~60 KB) |
| Bandwidth | 5 GB/month | Cache images; thumbnails |
| Monthly active users | 50,000 | Enough for v1.0 |
| Project pause | After 7 days idle | Daily keep-alive ping (GitHub Actions) |
| Built-in email | 2/hour | Replace with Brevo SMTP before real users |
| Brevo SMTP | 300 emails/day | ~250 sign-ups/day |

Upgrade to Supabase Pro when: database > 400 MB · files > 800 MB · bandwidth > 4 GB/month · sign-ups > 250/day · any pause outage after launch.
