# API Reference

## Verified

VERIFIED 2026-11-23 (`PHASE_004`): first Supabase implementations — `SupabaseAuthRepository` and `SupabaseProfileRepository` in `lib/data/repositories/supabase/`, used only in backend mode (`AppConfig.hasBackend`, Supabase URL + public key from `--dart-define-from-file=env/dev.json`). Auth: `signUp` (metadata `full_name`, `role`; a taken email is detected by an empty `identities` list), `verifyOTP` type `signup` / `recovery` with 6-digit codes, `resend` (signup) / `resetPasswordForEmail` (reset), `signInWithPassword`, `updateUser` (password), `signOut`. `changePassword` confirms the current password by signing in again. `deleteAccount` calls `rpc('delete_my_account')`. New contract `AuthRepository.restoreSession()` (signed-in profile from a kept session, or null; the mock always returns null). `logIn` may throw `ValidationFailure(emailNotConfirmed)`; repositories may throw `NetworkFailure`. Profiles: `select('*, teacher_details(*), student_details(*)')`, update of editable columns + `upsert` of the role's detail row; `watchProfile` re-emits saves made through the repository (no Realtime yet). Dio is not used yet.

VERIFIED 2026-11-23 (`PHASE_003`, provisional mock contracts): `DiscoverRepository` (`watchTeachers`, `watchStudents` — visibility rules applied), `ConnectionRepository` (`watchConnections`, `sendRequest`, `respond`, `remove`), `ChatRepository` (`watchConversations`, `openConversation`, `watchMessages`, `sendMessage`, `markRead`; chat only between accepted connections), `NotificationRepository` (`watchNotifications`, `markRead`, `markAllRead`, `watchSettings`, `updateSettings`). `AuthRepository` gained `changePassword`, `deleteAccount`; `SafetyRepository` gained `watchBlockedUsers` (`BlockedUser` record with date), `unblockUser`. New `ValidationReason`s: `connectNoteTooLong`, `profileIncomplete`, `alreadyConnected`, `notConnected`, `messageEmpty`, `passwordUnchanged`. All registered by interface in `lib/main.dart` with in-memory mocks; the backend phases may refine them.

VERIFIED 2026-11-19 (`PHASE_002`): the 4 interfaces above exist in `lib/data/repositories/` with method contracts in Dart doc comments; status **provisional** until each backend phase confirms it. Only mock implementations exist (`lib/data/repositories/mock/`); no Supabase or Dio code yet.

No backend client, repository, Supabase project files, Edge Functions or API calls exist in the repository (audit 2026-11-18). VERIFIED

## Decided Contracts (Version 1.0)

Each repository below uses `supabase_flutter` for Auth, database, Storage and Realtime, and Dio (configured in `lib/core/network/`, sending the Supabase access token) for Edge Function HTTP calls. Record exact columns, filters, RLS dependencies and error mapping here when the phase that builds it is executed.

| Repository | Supabase surface | Used by |
|---|---|---|
| `AuthRepository` | Auth: `signUp` (email, password, metadata `full_name`, `role`), `verifyOTP` (type `signup` / `recovery`, 6 digits), `resend`, `signInWithPassword`, `resetPasswordForEmail`, `updateUser`, `signOut`, `onAuthStateChange` | auth, settings |
| `ProfileRepository` | `profiles`, `teacher_details`, `student_details` — my profile, setup steps, edit, other user's profile (stores Storage paths returned by `MediaRepository`) | profile_setup, profile |
| `DiscoverRepository` | Visible `profiles` + detail tables — Teachers/Students lists, search, filters, default sort | discover |
| `MediaRepository` | Storage uploads/removals for `avatars`, `certificates`, `post-images`, `chat-images`; returns Storage paths | profile_setup, profile, post, chat |
| `FeedRepository` | `posts`, `post_likes`, `post_comments`; report via `reports` | feed, post |
| `ConnectionRepository` | `connections` (request, accept, decline, remove) | connections, discover |
| `ChatRepository` | `conversations`, `messages`; Realtime on `messages` filtered by conversation | chat |
| `NotificationRepository` | `notifications`, `device_tokens`; Edge Function `send-push` (FCM) | notifications |
| `SafetyRepository` | `reports`, `blocks`; account deletion (Edge Function or `security definer` function) | settings, feed, profile, chat |

Implementations receive `SupabaseClient` and `Dio` through their constructors (never `Supabase.instance`) and are registered by interface type in `lib/main.dart`.

## Method Contracts

Every interface method documents (Dart doc comment + an entry here once implemented): return value and nullability, empty-result behaviour, the `*Failure` types it may throw, sort order and paging, and side effects. Supabase, later Python API and test-fake implementations must all honour the same contract (Liskov rule in `CLASS_AND_COMPONENT_RULES.md`).

## Edge Functions (DECIDED)

| Name | Purpose | Caller | Auth | Status |
|---|---|---|---|---|
| `send-push` | Send FCM push for connection requests/accepts, messages, comments, teacher approval | DB trigger / webhook | Service-side only | Not created |
| account deletion | Delete auth user and owned data | Settings → Delete account; deletion web page | User JWT | UNVERIFIED — developer confirmation required (Edge Function vs SQL function) |

## Error Mapping

Supabase exceptions are mapped to `*Failure` types in the Supabase repositories (see `ERROR_HANDLING.md`).

## Later: Python FastAPI

Introduced from Version 2.0 behind the same repository interfaces (`lib/data/repositories/api/`, calling FastAPI with Dio), connected to the same Postgres, verifying Supabase JWTs. Document each endpoint here when it exists.

## Rules

See `.claude/skills/asatiza-docs-and-phases/references/api-change-policy.md`.
