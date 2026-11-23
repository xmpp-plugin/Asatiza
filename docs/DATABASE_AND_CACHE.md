# Database And Cache

## Verified

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

## Migrations

None yet. One file per change: `supabase/migrations/YYYYMMDDHHMMSS_short_description.sql`. Never edit an applied migration.

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
