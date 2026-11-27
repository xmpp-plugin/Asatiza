# PHASE_009_CHAT_ADD_SUPABASE_REALTIME_CHAT_WITH_PHOTOS — Chat: real-time 1-to-1 chat with photos

## Identity

- Phase ID: PHASE_009_CHAT_ADD_SUPABASE_REALTIME_CHAT_WITH_PHOTOS
- Phase title: Chat — real-time 1-to-1 messages with photos, read ticks and unread badges on Supabase
- File name: PHASE_009_CHAT_ADD_SUPABASE_REALTIME_CHAT_WITH_PHOTOS.md
- Module: CHAT
- Priority: High
- Risk level: High (2 tables, RLS, database functions, first use of Supabase Realtime (publication change), a private Storage bucket and policies, 2 shared model changes, a repository-interface addition, mock moves)
- Current status: CLOSED
- Current step: CLOSURE
- Approval: APPROVED
- Outcome: COMPLETED
- Version: 1.0
- Created date: 2026-11-27
- Last updated date: 2026-11-27
- Started date: 2026-11-27
- Completed date: 2026-11-27
- Developer owner: Developer (owner) — VERIFIED (PHASE_001 decision)
- Dependency phases: PHASE_005_BACKEND_ADD_STORAGE_PHOTOS_CERTIFICATES, PHASE_007_SAFETY_ADD_SUPABASE_BLOCKS, PHASE_008_CONNECTIONS_ADD_SUPABASE_CONNECTIONS (all closed)

## Requirement

- Original developer request: "Accept recommendation but for 1 question B is best selection" — Chat with **text and photos in one phase** (B); read-only after a connection is removed, hidden after a block; messages up to **2,000 characters**; **Realtime** for open chats and the Chats list.
- Business objective: connected teachers and students can talk inside the app (plan sections 3.11, 4 "Connect and chat", 5 tab 4, 12 `conversations` / `messages` / `chat-images`).
- Expected outcome: "Message" opens a real conversation; messages (text and / or one photo) arrive live on the other phone; read ticks and unread badges are real; the database enforces who can chat.
- Acceptance criteria:
  1. "Message" on an accepted connection opens the conversation (created on first use); "Chat is coming soon" is gone.
  2. A text message (1–2,000 characters) and / or one photo appears **at once** on the other phone while the chat or the Chats list is open (Realtime).
  3. The Chats list shows each conversation with the other person, last message (text or "Photo") and time, newest first, and an unread count; the Chats tab badge shows the total.
  4. Read ticks: ✓ sent, ✓✓ when the other person opened the chat; opening a chat marks the other person's messages as read.
  5. Photos: Take a photo / Choose from gallery, compressed before upload, stored in a **private** bucket that only the two members can read.
  6. Only the two members can read a conversation or its photos; nobody can send in someone else's name.
  7. After the connection is **removed**, the conversation stays visible but **read-only** ("You're no longer connected"); after a **block** (either way) the conversation disappears for both and nobody can send.
  8. Account deletion removes the user's conversations, messages and chat photos.
  9. Mocks follow the PHASE_007 rule (no mock chat / connections / profiles registered or kept in `lib/` once unused).

## Analysis

- Current behavior (VERIFIED): `lib/main.dart` wires `MockChatRepository(sampleConnections)` (sample people only); the 3 "Message" buttons show "Chat is coming soon" (PHASE_008); `ChatCubit` attaches a sample SVG (`ChatCubit.samplePhoto`) instead of a real photo; `ShellBadgesCubit` sums `Conversation.unreadCount` from the mock.
- Root cause / gap: no `conversations` / `messages` tables, no Realtime, no `chat-images` bucket, no Supabase chat implementation.
- End-to-end flow (traced, VERIFIED):
  - Open: Message (Lists / Public profile / My connections; Notifications for sample items) → `AppRoutes.chat(otherId)` → `ChatScreen` → `ChatCubit._open()` → `ProfileRepository.getProfile(other)` + `ChatRepository.openConversation` → `watchMessages` stream.
  - Send: `MessageComposer` → `ChatCubit.send(text / imagePath)` → `ChatRepository.sendMessage`.
  - Read: `ChatCubit` → `markRead`.
  - List: `ChatsScreen` → `ChatsCubit` → `watchConversations` (+ `ProfileRepository.getProfiles` for names).
  - Badge: `MainShell` → `ShellBadgesCubit` → `watchConversations` (sum of `unreadCount`) + notifications.
  - Photo display: `ChatImageBubble` renders `message.imagePath` (asset in the mock).
  - Server (proposed): tables + RLS → functions → Realtime publication → Storage `chat-images`.
- Relevant files: `lib/data/repositories/chat_repository.dart`, `mock/mock_chat_repository.dart`, `mock/mock_connection_repository.dart`, `mock/mock_profile_repository.dart`, `lib/data/models/{conversation,message}.dart`, `lib/data/repositories/media_repository.dart`, `supabase/supabase_media_repository.dart`, `lib/data/models/enums/media_bucket.dart`, `lib/core/services/{image_picker_service,image_compressor}.dart`, `lib/core/widgets/photo_source_sheet.dart`, `lib/core/session/shell_badges_cubit.dart`, `lib/features/chat/{bloc,presentation}/*`, the 3 Message buttons, `lib/main.dart`, earlier migrations (profiles, storage, blocks, connections).
- Existing reusable components (VERIFIED): `Conversation` / `Message` models, chat screens and widgets (`ChatBubble`, `ChatImageBubble`, `MessageComposer`, `ConversationTile`, `DayDivider`, `ChatHeader`, `ChatRowSkeleton`), `PhotoSourceSheet`, `ImagePickerService` / `ImageCompressor` (PHASE_005), `SupabaseMediaRepository` (bucket helpers, `_checkOwner`, `deleteAllUserFiles` by `<user-id>/` folder), `SupabaseFailureMapper`, the connections functions pattern, `private.hidden_by_block`.
- Existing API details: PostgREST + Realtime + Storage via `supabase_flutter` (already a dependency; no new package). No Dio, no Edge Function.
- Platform behavior: camera / gallery permissions already set up in PHASE_005 (iOS plist keys; Android needs none) — no native change.
- Lifecycle: every Realtime channel is created inside a repository stream and removed in its `onCancel` (no leaked subscriptions); cubits keep cancelling their subscriptions in `close()`.
- Database and cache: no local cache. Messages per conversation: the latest 200 are loaded (decision 12).
- Supabase (proposed, plan section 12):
  - `conversations (id, user_a, user_b, last_message, last_message_at, created_at)` — one per pair (unique, `user_a < user_b`), FKs to `profiles` on delete cascade.
  - `messages (id, conversation_id, sender_id, body, image_path, read_at, created_at)` — body ≤ 2,000; at least body or image; FK to `conversations` on delete cascade.
  - RLS: select only for the two members, and not when a block stands between them (either way); **no** direct insert / update / delete — writes through functions.
  - Functions (security definer): `open_conversation(p_other)` (creates only with an accepted connection and no block; returns the existing one otherwise), `send_message(p_conversation, p_body, p_image_path)` (member, accepted connection, no block, length, image path rules; updates `last_message*`), `mark_conversation_read(p_conversation)`, `list_conversations()` (the caller's conversations with last message, unread count and `can_send`).
  - Realtime: add `messages` to the `supabase_realtime` publication (RLS applies to Realtime events).
  - Storage: private bucket `chat-images` (JPEG, 1 MB). Path `<sender-id>/<conversation-id>_<random>.jpg` — the user folder keeps `deleteAllUserFiles` working unchanged; read only for the two members; upload only into your own folder for a conversation you belong to.
- Both roles: same for teachers and students; signed-out users have no access.
- Security: no secrets; functions use `auth.uid()`; photos never public; signed URLs expire (decision 4).

## Missing Information / Decisions Needed

Decided by the developer (2026-11-27): **B** (text and photos in this phase); read-only after removal, hidden after a block; 2,000 characters; Realtime.

**Answered 2026-11-27** — developer: "Accept recommendations". Decisions 1–12 below are DECIDED as the **(Recommended)** option.

1. **All writes through database functions** (like PHASE_008). **(Recommended)** `open_conversation`, `send_message`, `mark_conversation_read`, plus a read function `list_conversations` for the Chats list (last message, unread count, `can_send` in one call). Tables are read-only for the app.
2. **Realtime scope.** **(Recommended)** add only `messages` to the publication; an open chat listens to its conversation's inserts and read-tick updates; the Chats list and the tab badge listen to message inserts / updates the user may see (RLS filters events) and re-read `list_conversations()`. Each channel is removed when its stream is cancelled.
3. **Photos.** **(Recommended)** one photo per message, compressed with the existing `ImageCompressor` (same settings family as avatars, ~200 KB target, max 1 MB), optional text with it, picked through the existing `PhotoSourceSheet`.
4. **Showing photos.** **(Recommended)** short-lived signed URLs (1 hour) created by the repository when messages load; `Message` gets `imageUrl` (display only, never written) — **shared model change**.
5. **Read-only state.** **(Recommended)** `Conversation` gets `canSend` (server-computed: accepted connection and no block) — **shared model change**; the composer is replaced by "You're no longer connected." when false. `openConversation` returns an existing conversation even when not connected (read-only) and throws `notConnected` only when it would have to create one — **contract wording change**.
6. **Block.** **(Recommended)** conversations and messages are hidden from both people while a block exists (RLS + `list_conversations`); `send_message` refuses; nothing is deleted, so unblocking brings the history back (still read-only unless they reconnect).
7. **Length rule.** **(Recommended)** new `ValidationReason.messageTooLong` ("Messages can be up to 2,000 characters."); the composer stops at 2,000 characters.
8. **Media contract.** **(Recommended)** `MediaRepository.uploadChatImage(String userId, String conversationId, Uint8List jpegBytes)` → path; `MediaBucket.chatImages` — **repository-interface addition**.
9. **ChatCubit dependencies.** **(Recommended)** `ChatCubit` also receives `MediaRepository`, `ImagePickerService`, `ImageCompressor` (constructor injection) for the photo button; the sample photo constant is removed.
10. **Mock rule (PHASE_007).** **(Recommended)** move `MockChatRepository`, `MockConnectionRepository` and `MockProfileRepository` from `lib/data/repositories/mock/` to `test/fakes/` (after this phase `main.dart` no longer needs them; `MockFeedRepository`, `MockNotificationRepository` and `MockSafetyRepository` stay until their phases). Seed data in `lib/data/mock/` stays (still used by the feed and notification mocks).
11. **Notifications tab.** **(Recommended)** unchanged (sample items); "Message" on a sample notification opens a chat that says the person is not connected (sample ids are not real users) until the Notifications phase.
12. **History size.** **(Recommended)** each chat loads the latest 200 messages; older ones are not shown in v1.0 (recorded limitation).

## Scope

- In scope (decided 2026-11-27): the migration (tables, constraints, indexes, RLS, 4 functions, publication, bucket + policies, rollback notes); a rolled-back RLS / function / Storage check script; `SupabaseChatRepository` with Realtime; `uploadChatImage` + `MediaBucket.chatImages` in `SupabaseMediaRepository`; `Message.imageUrl`, `Conversation.canSend`; `ValidationReason.messageTooLong`; `ChatCubit` photo flow + read-only state; `ChatImageBubble` shows network images; the 3 "Message" buttons open the chat again; `main.dart` wiring; mock moves; tests; docs.
- Explicitly out of scope: push notifications for new messages and the Notifications tab (Notifications phase), typing indicators, message delete / edit, group chats, video, voice, more than one photo per message, loading older than 200 messages, Realtime for anything other than chat, dependencies, native changes.
- Files expected to change:
  - Data: `lib/data/repositories/chat_repository.dart` (wording), `lib/data/models/message.dart`, `lib/data/models/conversation.dart`, `lib/data/repositories/media_repository.dart`, `lib/data/models/enums/media_bucket.dart`, `lib/data/repositories/supabase/supabase_media_repository.dart`, `lib/core/errors/failures.dart`, `lib/main.dart`
  - Chat feature: `lib/features/chat/bloc/chat_cubit.dart`, `chat_state.dart`, `lib/features/chat/presentation/chat_screen.dart`, `widgets/chat_image_bubble.dart`, `widgets/message_composer.dart`, `widgets/conversation_tile.dart` (photo label) as needed
  - Message buttons: `lib/features/discover/presentation/discover_screen.dart`, `public_profile_screen.dart`, `lib/features/connections/presentation/connections_screen.dart`
  - `lib/l10n/app_en.arb` + generated (read-only note, photo label, too-long message, upload error reuse)
  - Moves (renames): `lib/data/repositories/mock/{mock_chat_repository,mock_connection_repository,mock_profile_repository}.dart` → `test/fakes/`
  - Tests: `test/helpers/test_app.dart` and every test importing the moved mocks; chat cubit / screen tests; media tests
  - Docs: `DATABASE_AND_CACHE`, `API_REFERENCE`, `ARCHITECTURE`, `FILE_CATALOG`, `KNOWN_ISSUES`, `COMMON_COMPONENTS` if a widget changes; phase / state / index
- Files that must not change: product plans, earlier migrations, auth, profile, discover, blocks and connections repositories (beyond the Message buttons), native files, `pubspec.yaml`.
- Proposed new files (approval required):
  - `supabase/migrations/20261129120000_chat.sql`
  - `supabase/tests/chat_rls_checks.sql`
  - `lib/data/repositories/supabase/supabase_chat_repository.dart` — `SupabaseChatRepository` (constructor: `SupabaseClient`, `SupabaseFailureMapper`); no Supabase chat implementation exists.
  - `test/data/supabase/supabase_chat_repository_test.dart` — row / error mapping only (no network, no new packages).
- Proposed new classes: `SupabaseChatRepository`.
- Dependency changes: None (`supabase_flutter` already includes Realtime).
- API contract changes: `MediaRepository.uploadChatImage`; `ChatRepository.openConversation` wording (read-only existing conversation); `Message.imageUrl`, `Conversation.canSend`; `ValidationReason.messageTooLong`.
- Native changes: None.
- Supabase changes: new tables, RLS, functions, Realtime publication, Storage bucket + policies (approval required; the developer applies them).

## Readiness Checklist

- [x] Requirement is clear
- [x] Expected behavior is clear
- [x] Existing flow is traced
- [x] API is verified
- [x] Request contract is verified
- [x] Response contract is verified
- [x] Supabase tables, RLS and Storage policies are defined (decisions 1, 2, 4, 6 decided)
- [x] Security, 18+ gate and moderation rules are unaffected or approved
- [x] Required UI/design is available (existing chat artboards and widgets; read-only note is a small text deviation)
- [x] Existing reusable components are identified
- [x] Proposed files are identified
- [x] New files/classes are approved
- [x] Platform behavior is understood
- [x] Permissions are understood
- [x] Dependencies are available
- [x] Risks are documented
- [x] Automated tests are defined
- [x] Manual tests are defined
- [x] Rollback plan is defined
- [x] Phase dependencies are completed
- [x] Developer approval is recorded

## Risks

- First Realtime use: channels must be removed on cancel (leaks would waste the free-plan connection limit); RLS must apply to events (it does for `postgres_changes` on tables with RLS) — covered by tests and the manual two-phone test.
- Storage policy parsing the path (`<user>/<conversation>_<random>.jpg`) must be exact; covered by the check script.
- Two shared model changes and a media-interface addition touch several classes; existing tests must keep passing.
- Free-plan limits: Realtime concurrent connections and messages per month are far above v1.0 targets; photo storage counts against the 1 GB Storage limit (compression keeps photos small).
- Remote migration must be applied before the new build.

## Test Plan

- Automated: repository row / error mapping; `ChatCubit` sends text, refuses > 2,000, shows read-only when `canSend` is false, photo flow with fake picker / compressor / media; Chats list order and unread; badge sum; Message buttons open the chat; existing chat tests moved to the test fakes.
- SQL (developer, `chat_rls_checks.sql`, rolled back): open needs an accepted connection; outsider cannot read conversation / messages / photos; direct writes refused; send by a member OK; send > 2,000 refused; empty refused; send after removal refused (still readable); block hides for both and refuses send; mark read only affects the other person's messages; Storage upload only into own folder for a member conversation; anon has no access.
- Manual (two phones, Android and iOS): open from each Message button; text arrives live both ways; photo (camera and gallery) arrives live and opens; ticks change to ✓✓ when the other opens the chat; unread badge and counts; remove the connection → read-only note; block → chat gone for both; airplane mode → send shows an error and nothing is lost from the composer; delete an account → its chats disappear for the other person.

## Rollback Plan

- App: revert the phase commit (mocks back to `lib/`, Message buttons back to "Chat is coming soon").
- Database: the migration's rollback section removes `messages` from the publication, drops the functions, tables and the `chat-images` bucket policies (empty the bucket first in the dashboard). Chat data is lost (it did not exist before).

## Implementation

- Approved implementation plan: Approved 2026-11-27 (developer: "Approve phase"). Covers the developer choices (B, read-only after removal, hidden after block, 2,000 characters, Realtime) and decisions 1–12: migration `20261129120000_chat.sql` (conversations, messages, RLS, `open_conversation` / `send_message` / `mark_conversation_read` / `list_conversations`, Realtime publication for `messages`, private `chat-images` bucket + policies, rollback notes); `supabase/tests/chat_rls_checks.sql`; `SupabaseChatRepository` + `test/data/supabase/supabase_chat_repository_test.dart`; `MediaRepository.uploadChatImage` + `MediaBucket.chatImages`; `Message.imageUrl`, `Conversation.canSend`; `ValidationReason.messageTooLong`; `ChatRepository.openConversation` wording; `ChatCubit` photo flow and read-only state; image bubble, composer limit; the 3 Message buttons open the chat; `main.dart` wiring; `MockChatRepository`, `MockConnectionRepository`, `MockProfileRepository` moved to `test/fakes/`; tests; docs. Not approved: push / notifications, typing, delete / edit, group chats, more than one photo, older history, dependencies, native changes.
- Implementation log: 2026-11-27 — implemented the approved scope. See Change Log.
- Exact changed files: see Change Log
- Purpose of every changed file: see Change Log
- Existing components reused: listed in Analysis
- New approved components: migration `20261129120000_chat.sql`, `chat_rls_checks.sql`, `SupabaseChatRepository`, `supabase_chat_repository_test.dart`, `MediaRepository.uploadChatImage`, `MediaBucket.chatImages`, `Message.imageUrl`, `Conversation.canSend`, `ValidationReason.messageTooLong`
- Deviations from the plan (recorded):
  - Chat photos use the existing `ImageCompressor.compressAvatar` (~512 px, ~60 KB) instead of the "~200 KB" target in decision 3: a sharper setting needs a new compressor method, which was not approved. Photos stay readable; a follow-up can add `compressPhoto`.
  - `createSignedUrls` is deprecated in the installed `storage_client` 2.8.1; the code uses `createSignedUrlsResult` (same package, no dependency change).
  - The "Chat is coming soon" string from PHASE_008 was removed (no longer used).
- Out-of-scope findings:
  - Photos the other person sent stay in Storage after an account deletion (only the deleting user's own files are removed); recorded in `KNOWN_ISSUES`.
  - Push for new messages and real notifications: Notifications phase.
  - Sample notifications keep sample ids; their "Message" links cannot reach real users until then.
- Unexpected risks: None

## Change Log

| File path | Change type | Approved in phase | What changed | Why it changed | Existing behavior preserved | Possible side effects | File-level checks |
|---|---|---|---|---|---|---|---|
| `supabase/migrations/20261129120000_chat.sql` | added | Yes | 2 tables, indexes, RLS, 4 private helpers, `open_conversation` / `send_message` / `mark_conversation_read` / `list_conversations`, Realtime publication for `messages`, `chat-images` bucket + 3 policies, rollback notes | Real chat | — | Needs the migration before the build | Not run against a database (no CLI) |
| `supabase/tests/chat_rls_checks.sql` | added | Yes | 16 rolled-back checks (open without / with connection, send, empty, long, direct insert, foreign photo path, member read + unread, mark read, outsider, removal read-only, block hides both ways, open across block, anon) | Verify rules | — | None (rolled back) | Not run (developer) |
| `lib/data/repositories/supabase/supabase_chat_repository.dart` | added | Yes | RPC writes, RLS reads, Realtime channels per stream (removed on cancel), latest 200 messages, signed photo URLs, rule-message mapping | Real chat | Contract signatures unchanged | Realtime connection per open chat / list | `supabase_chat_repository_test.dart` |
| `lib/data/repositories/chat_repository.dart` | modified | Yes | Contract wording (read-only history, new failures) | Decision 5 | Signatures unchanged | None | analyze |
| `lib/data/models/message.dart`, `lib/data/models/conversation.dart` | modified | Yes | `imageUrl`; `canSend` (default true) | Decisions 4, 5 | Other fields unchanged | Equality includes the new fields | tests |
| `lib/data/repositories/media_repository.dart`, `lib/data/models/enums/media_bucket.dart`, `lib/data/repositories/supabase/supabase_media_repository.dart` | modified | Yes | `uploadChatImage`; `MediaBucket.chatImages`; implementation (own folder, conversation-prefixed name) | Decision 8 | Avatar / certificate uploads unchanged; `deleteAllUserFiles` now also clears the user's chat photos | None | analyze, tests |
| `lib/core/errors/failures.dart` | modified | Yes | `messageTooLong` | Decision 7 | Other reasons unchanged | None | analyze |
| `lib/features/chat/bloc/chat_cubit.dart`, `chat_state.dart` | modified | Yes | Media / picker / compressor injected; `sendPhoto`; error state + `errorShown`; read-only (`canSend`); re-open read-only on `notConnected`; sample photo removed | Decisions 3, 5, 9 | Open, stream, mark-read and text send unchanged | Orphan photo deleted if its send fails | chat_notifications_test |
| `lib/features/chat/presentation/chat_screen.dart` | modified | Yes | Dependencies passed; error snackbar; read-only note instead of the composer; photo button opens `PhotoSourceSheet` | Decisions 3, 5 | Message list, dividers, header unchanged | — | tests |
| `lib/features/chat/presentation/widgets/chat_image_bubble.dart`, `message_composer.dart` | modified | Yes | Network photo (signed URL) with placeholder, asset fallback for sample data; 2,000-character limit (no counter) | Decisions 4, 7 | Bubble layout unchanged | — | tests |
| `lib/features/discover/presentation/{discover_screen,public_profile_screen}.dart`, `lib/features/connections/presentation/connections_screen.dart` | modified | Yes | Message opens the chat again (PHASE_008 snackbar removed) | Acceptance 1 | Other buttons unchanged | — | discover_connect_test |
| `lib/main.dart` | modified | Yes | `SupabaseChatRepository` registered; sample profiles / connections / mock chat removed; doc comment | Wiring, decision 10 | Other repositories unchanged | Needs the migration | analyze |
| `lib/l10n/app_en.arb` + 2 generated | modified | Yes | `chatReadOnlyMessage`, `messageTooLongError` added; `chatComingSoon` removed | Decisions 5, 7 | Other strings unchanged | — | gen-l10n |
| `lib/data/repositories/mock/{mock_chat,mock_connection,mock_profile}_repository.dart` → `test/fakes/` | renamed (`git mv`, staged) | Yes | Package imports; test-only notes; mock chat follows the new contract (read-only existing chat, 2,000 limit, `canSend`) | Decision 10 | Sample behaviour unchanged | Production can no longer import them (intended) | tests |
| `test/fakes/mock_media_repository.dart`, `mock_auth_repository.dart`, `mock_discover_repository.dart` | modified | Yes | `uploadChatImage`; imports of the moved fakes | Contract / moves | — | — | tests |
| Tests: `test/helpers/test_app.dart`, `test/data/mock_data_test.dart`, `test/features/{chat_notifications,cubits,discover_connect,media_upload_cubits,profile_settings,screens}_test.dart`; added `test/data/supabase/supabase_chat_repository_test.dart` | modified / added | Yes | Imports from `test/fakes/`; ChatCubit dependencies; new tests: photo send, > 2,000 refused, read-only after removal, Message opens the chat, row / error mapping | Cover the change | Existing assertions unchanged | — | `flutter test` |
| Docs: `DATABASE_AND_CACHE`, `API_REFERENCE`, `ARCHITECTURE`, `FILE_CATALOG`, `KNOWN_ISSUES`; phase / state / index | modified | Yes | PHASE_009 facts and limitations | Required docs | — | — | `validate_phase_structure.sh` |

Pre-existing uncommitted changes at the start: PHASE_009 phase docs only.

## Execute Technical Checks

- Changed-file evidence reviewed after changes: `git status --short` after implementation — exactly the files above (3 renames staged by `git mv`)
- Git status/diff rerun reason: baseline at start; once after implementation
- Patch/whitespace check result, when run: Not run
- Relevant Dart formatting: `dart format lib test` — clean
- Scoped or project analysis commands: `flutter analyze` — No issues found (one deprecation info fixed with `createSignedUrlsResult`)
- Relevant targeted tests: `flutter test` (full) — 164/164 passed (7 new; the PHASE_008 "coming soon" test now checks that Message opens the chat)
- Newly introduced issues found: deprecated `createSignedUrls`; 1 outdated test
- Newly introduced issues fixed: both
- Pre-existing unrelated issues: None recorded
- Commands that could not run and why: migration and `chat_rls_checks.sql` not run (no Supabase CLI or project link; developer applies them); Realtime and Storage need the real project (manual test); app not launched; iOS not built (Windows)

## Manual Testing

- Ready for developer manual testing: Yes (2026-11-27). First apply `supabase/migrations/20261129120000_chat.sql` and run `supabase/tests/chat_rls_checks.sql` (all PASS; needs two active profiles with no connection, block or chat between them); then follow the Manual tests with two phones.
- Developer manual-test confirmation: Not provided
- Manual-test notes requested by developer: None
- Failed case 1 (2026-11-27, developer): `chat_rls_checks.sql` stopped with `P0001: already_connected` (in `send_connection_request`).
  - Cause: the script took the two oldest active profiles, which the developer had already connected while testing PHASE_008; the database correctly refused a second request. Not an app or migration bug.
  - Fix attempt 1 (test script only): pick a pair with no connection / block / chat. Developer: the database has only those two profiles, already connected, and no new accounts should be created.
  - Fix 2 (test script only, in scope, replaces attempt 1): the script uses the two oldest active profiles and, **inside its rolled-back transaction**, first clears the connection, conversation (with its messages) and any block between them, so every check starts clean; the final `ROLLBACK` restores everything. Nothing is committed even if a check fails. No app code changed; no rerun of Dart checks needed.
  - Status: rerun by the developer — "All PASS" (2026-11-27). The migration is applied to the remote project (VERIFIED by the developer's run; check 10 "outsider" SKIPPED as expected with two profiles).
- App manual test on phones: not yet reported.
- Developer findings and approved changes (2026-11-27, developer: "Yes, make the fixes and point 3 … daily 300 messages and 30 photos … show proper message"):
  - Fix 2: a chat showed a blank screen while loading → skeleton message bubbles (built from the existing `SkeletonBox`, private widget in `chat_screen.dart`, no new file).
  - Fix 3: ticks never showed a single tick (the same ✓✓ icon was drawn faded / bright) → ✓ (`AppIcon.check`) when sent, ✓✓ (`AppIcon.readTicks`) when seen; plus a fallback reload of an open chat when the app returns to the foreground, in case a "seen" update was missed.
  - Change 4 (scope addition, approved): daily limits per sender — **300 messages** and **30 photos** in any 24 hours — enforced in `send_message` by a new migration `supabase/migrations/20261130120000_chat_daily_limits.sql` (new file, approved) with an index on `messages (sender_id, created_at)`; 2 new `ValidationReason`s (`dailyMessageLimit`, `dailyPhotoLimit`, shared failures change, approved) and clear messages; new SQL checks in `chat_rls_checks.sql`.
  - Not included: animated shimmer for all skeletons and a profile-details skeleton (not approved).
  - Implemented 2026-11-27 (files):
    - `supabase/migrations/20261130120000_chat_daily_limits.sql` (added) — index `messages (sender_id, created_at)`; `send_message` replaced with the same rules + `daily_message_limit` (300 / 24 h) and `daily_photo_limit` (30 / 24 h); rollback notes.
    - `supabase/tests/chat_rls_checks.sql` (modified) — checks 17–19 (30 photos OK, 31st refused; text still works; 300 messages OK, 301st refused) in a fresh connected pass inside the same rolled-back transaction.
    - `lib/core/errors/failures.dart` — `dailyMessageLimit`, `dailyPhotoLimit`.
    - `lib/data/repositories/supabase/supabase_chat_repository.dart` — maps the 2 limit messages; `lib/data/repositories/chat_repository.dart` — contract wording.
    - `lib/features/chat/presentation/chat_screen.dart` — `_ChatSkeleton` (placeholder bubbles from `SkeletonBox`) while loading; limit messages in the error snackbar; `AppLifecycleListener` → `ChatCubit.refresh()` on resume.
    - `lib/features/chat/bloc/chat_cubit.dart` — `refresh()`.
    - `lib/features/chat/presentation/widgets/chat_bubble.dart` — `ChatBubble.ticks`: ✓ sent / ✓✓ seen; semantics "Sent" / "Read"; `chat_image_bubble.dart` uses it.
    - `lib/l10n/app_en.arb` + generated — `dailyMessageLimitError` ("You've reached today's limit of 300 messages. You can send more tomorrow."), `dailyPhotoLimitError` ("You've reached today's limit of 30 photos. You can still send text, and more photos tomorrow."), `messageSentLabel`.
    - `test/fakes/mock_chat_repository.dart` — the same daily limits; tests: photo limit + text after it, tick icons, limit error mapping.
    - "Today" in the messages means the last 24 hours (rolling window, fair across time zones).
  - Checks: `flutter analyze` — No issues found; `flutter test` — 166/166 passed (2 new). Not run: the new migration and the extended SQL script (developer applies them).
  - Status: retested by the developer — "Tested and working fine" (2026-11-27).

## Closure

- Developer manual-test confirmation: "Tested and working fine" (2026-11-27, CLOSE PHASE request), after the fixes and the daily limits.
- Tested platforms: Not stated by the developer
- Tested devices: Not stated by the developer (two phones planned)
- SQL checks: `chat_rls_checks.sql` "All PASS" reported for the chat migration (check 10 SKIPPED with two profiles); a rerun after `20261130120000_chat_daily_limits.sql` (checks 17–19) was not reported separately — UNVERIFIED that the limits migration is applied.
- Failed and retested cases:
  1. `chat_rls_checks.sql` failed with `already_connected` (script used an already-connected pair) — script fixed (resets the pair inside its rolled-back transaction); rerun "All PASS".
  2. Chat opened on a blank screen while loading — skeleton bubbles added.
  3. Ticks never showed a single tick — ✓ sent / ✓✓ seen, plus a reload on app resume.
  - Scope addition (approved): daily limits 300 messages / 30 photos with clear messages.
- Developer change after Execute (recorded, kept): `chat_bubble.dart` — the ✓✓ icon size changed from 18 to 12 (same size as ✓) and a blank line removed. Affected checks rerun at closure: `dart analyze lib/features/chat lib/l10n` — No issues; `dart format --set-exit-if-changed` on the file — clean; `flutter test test/features/chat_notifications_test.dart` — 15/15 passed. The generated l10n files differ only by regeneration (line endings).
- Final changed files: as in the Change Log plus the fix / scope-addition list above. Nothing committed; 3 `git mv` renames staged.
- Reused technical evidence: full `flutter analyze` clean and `flutter test` 166/166 from after the fixes; the scoped reruns above cover the later developer edit.
- Known limitations: chat photos use the avatar compression (~512 px); latest 200 messages per chat; photos the other person sent stay in Storage after an account deletion; the Notifications tab's sample items cannot open real chats; no push for new messages yet; no typing / delete / edit; "today" in the limit messages means the last 24 hours.
- Follow-up phases: Notifications (push for messages, real Notifications tab), Feed (real posts, reports, auto-hide), optional chat-photo compression and skeleton shimmer.
- Rollback guidance: see Rollback Plan; for the limits, re-run the original `send_message` block from `20261129120000_chat.sql` and drop `messages_sender_created_idx` (rollback notes in `20261130120000_chat_daily_limits.sql`).
- Final status: CLOSED / COMPLETED
- Completion date: 2026-11-27
