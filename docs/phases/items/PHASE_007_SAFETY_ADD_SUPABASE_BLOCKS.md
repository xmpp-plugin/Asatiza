# PHASE_007_SAFETY_ADD_SUPABASE_BLOCKS — Safety: real blocks on Supabase

## Identity

- Phase ID: PHASE_007_SAFETY_ADD_SUPABASE_BLOCKS
- Phase title: Safety — real blocks on Supabase (post reports move to the Feed phase)
- File name: PHASE_007_SAFETY_ADD_SUPABASE_BLOCKS.md
- Module: SAFETY
- Priority: High
- Risk level: High (new table + RLS, a change to the `profiles` / detail-table read policies (protected block / visibility rule), a repository-interface split touching 6 cubits, new production files)
- Current status: CLOSED
- Current step: CLOSURE
- Approval: APPROVED
- Outcome: COMPLETED
- Version: 1.0
- Created date: 2026-11-26
- Last updated date: 2026-11-26
- Started date: 2026-11-26
- Completed date: 2026-11-26
- Developer owner: Developer (owner) — VERIFIED (PHASE_001 decision)
- Dependency phases: PHASE_004_BACKEND_ADD_SUPABASE_AUTH_PROFILES (closed), PHASE_006_BACKEND_ADD_SUPABASE_DISCOVER_TEACHERS_STUDENTS (closed)

## Requirement

- Original developer request: "A — Create phase safely … Continue with A and create the phase of above discussion safely": Safety now with **blocks only**; post / comment reports and the 3-reports auto-hide move to the Feed phase (they need real posts).
- Business objective: blocking really protects users (plan section 9: "Blocked users can't see your profile or posts, can't message you, and disappear from your lists"; section 12: "blocked users filtered from every query").
- Expected outcome: Block / Unblock and the blocked-users list work on Supabase, and a block hides people both ways in the real lists, search and profiles, enforced by the database.
- Acceptance criteria:
  1. Block from a public profile, from Connections, or from "Report and block" saves a real block. Blocking twice is a no-op; you cannot block yourself.
  2. Settings → Blocked users lists the real blocks, newest first, with names; Unblock removes the block.
  3. After **A blocks B**: B disappears from A's Teachers / Students list and search (app query), and A disappears from B's list and search **and** A's profile cannot be opened by B ("not available") — enforced by RLS.
  4. A user can only create, read and delete **their own** blocks (RLS); nobody can see who blocked them.
  5. A failed block or unblock (offline, server error) shows a message and changes nothing.
  6. Account deletion removes the user's blocks in both directions (cascade).
  7. Reports keep working exactly as now (mock) until the Feed phase.

## Analysis

- Current behavior (VERIFIED):
  - `lib/main.dart:94` wires `MockSafetyRepository()` as `SafetyRepository`; blocks live in memory and reset on restart.
  - `SupabaseDiscoverRepository` (PHASE_006) does **not** filter blocks (recorded gap, `docs/KNOWN_ISSUES.md`); only `MockDiscoverRepository` does (`blockedEitherWay`).
  - `profiles`, `teacher_details`, `student_details` RLS: "signed-in users read" `using (true)` — a blocked user can still read the blocker's profile.
  - There is no `blocks` table in `supabase/migrations/`.
- Expected behavior: acceptance criteria above.
- Root cause / gap: no Supabase implementation for blocks; one interface (`SafetyRepository`) mixes reports (must stay mock until real posts exist) and blocks (to become real). The PHASE_004 rule "each repository is either real or mock, never both" means the interface must be split.
- End-to-end flow (traced, VERIFIED):
  - Public profile: `PublicProfileScreen` (block sheet) → `PublicProfileCubit.block()` → `SafetyRepository.blockUser` (**no `Failure` handling today** — would throw on network errors once real).
  - Connections: `ConnectionsScreen` → `ConnectionsCubit.block()` → `blockUser` (wrapped in `_guard`, failures ignored).
  - Report sheet: `ReportSheet` → `ReportCubit.submit()` → `reportPost` (+ `blockUser` when "also block"); failures return to `choosing`.
  - Blocked users: `BlockedUsersScreen` → `BlockedUsersCubit` → `watchBlockedUsers` + `ProfileRepository.getProfiles` for names; `unblock()` → `unblockUser` (**no `Failure` handling**).
  - Feed / Notifications: `FeedCubit` and `NotificationsCubit` → `watchBlockedIds` to hide blocked authors / actors (data still mock).
  - Lists: `DiscoverCubit` / `SearchCubit` → `SupabaseDiscoverRepository` → `profiles` (`status = 'active'`) → RLS read policy.
- Relevant files: `lib/data/repositories/safety_repository.dart`, `mock/mock_safety_repository.dart`, `mock/mock_discover_repository.dart`, `supabase/supabase_discover_repository.dart`, `supabase/supabase_profile_repository.dart`, `supabase/supabase_failure_mapper.dart`, the 6 cubits and their screens listed below, `lib/main.dart`, `supabase/migrations/20261123120000_profiles.sql`, `20261123120100_delete_my_account.sql`, `test/helpers/test_app.dart`.
- Existing reusable components (VERIFIED): `BlockedUser` record type, `MockSafetyRepository` (block logic, `blockedEitherWay`, `removeUser`), `SupabaseFailureMapper`, the "watch = initial load + changes made through this repository" pattern of `SupabaseProfileRepository.watchProfile`, `PublicProfileState.notFound` ("not available" path), `BlockedUsersScreen`, block confirmation sheet strings (`blockUserTitle`, `blockUserMessage`, `blockAction`), `EmptyStateView`.
- Existing API details: PostgREST via `supabase_flutter` only (no Dio, no Edge Function).
- Existing models: `BlockedUser` typedef; no model change needed.
- Existing state-management flow: cubits read `SafetyRepository` through constructors / `context.read`.
- Existing navigation flow: unchanged.
- Android / iOS behavior: none specific; no permissions; no native change.
- Lifecycle behavior: block streams cancelled in each cubit's `close()` (kept); the new repository's internal change controller lives for the app session (like `SupabaseProfileRepository`).
- Permission behavior: none.
- Database and cache behavior: no local cache; block ids loaded on subscribe and re-loaded after every block / unblock made on this device.
- Supabase tables, columns and migrations (proposed, plan section 12): `blocks (blocker_id, blocked_id, created_at)`, primary key `(blocker_id, blocked_id)`, both FKs to `profiles(id) on delete cascade`, `check (blocker_id <> blocked_id)`, index on `blocked_id`.
- Row Level Security and Storage policies (proposed): `blocks` — select / insert / delete only where `blocker_id = auth.uid()`; no update. `profiles`, `teacher_details`, `student_details` read policy: visible unless the profile's owner blocked the viewer (decision 2). No Storage change.
- Realtime, Edge Functions and push: none.
- Both roles and signed-out behavior: same for teachers and students; signed-out users have no access (no `anon` grant).
- Security considerations: no secrets; the app never writes another user's block; "who blocked me" is never readable; the blocked user only notices that the blocker is unavailable.

## Missing Information / Decisions Needed

**Answered 2026-11-26** — developer: "All accept recommendation". Decisions 1–7 below are DECIDED as the **(Recommended)** option. The developer added a new rule (decision 8); its detail was confirmed the same day: "Move to test/fakes" (option A).

1. **Split the safety interface** (repository-interface change).
   - A **(Recommended)**: new `BlockRepository` (`blockUser`, `watchBlockedIds`, `watchBlockedUsers`, `unblockUser`; `BlockedUser` moves with it). `SafetyRepository` keeps only `reportPost` and stays mock until the Feed phase. `MockSafetyRepository` implements both interfaces (no logic change). The 6 cubits that block depend on `BlockRepository`; `ReportCubit` depends on both.
   - B: keep one interface and write reports to a real `reports` table now — not recommended: mock post ids are not real posts, so reports would fail or store useless rows.
2. **Hide the blocker's profile from the blocked person (RLS on `profiles`).**
   - A **(Recommended)**: a profile is readable unless its owner blocked the viewer — **except** when the viewer also blocked the owner (so a mutual block still shows the name in the viewer's Blocked users list and can be undone). Lists additionally drop the people the viewer blocked (app query). Result: hidden both ways in lists; the blocked person cannot open the blocker's profile.
   - B: lists-only filter in the app, no RLS change — weaker (a blocked user could still read the blocker's profile directly).
3. **Detail tables.** **(Recommended)** apply the same rule to `teacher_details` and `student_details`, so no detail row leaks without its profile.
4. **Freshness (no Realtime).** **(Recommended)** block streams emit on subscribe and again after each block / unblock made on this device; `SupabaseDiscoverRepository` re-loads its list when the viewer's blocks change, so a just-blocked person disappears without a manual refresh. A block made by the **other** person shows on the next load or pull-to-refresh.
5. **Error handling.** **(Recommended)** `PublicProfileCubit.block()` and `BlockedUsersCubit.unblock()` catch `Failure` and show a snackbar with a new string `blockFailedMessage` "Couldn't update the block. Check your connection and try again."; the state stays unchanged. Connections and the report sheet keep their current handling.
6. **Migration and checks.** **(Recommended)** the developer applies the migration in the SQL editor and runs a new check script `supabase/tests/blocks_rls_checks.sql` (transaction, rolled back) with two signed-up users, like PHASE_004.
7. **Where blocks also apply later.** **(Recommended)** record (not build) that the Connections, Chat and Feed phases must refuse requests / messages / posts across a block in their database functions and RLS.
8. **New rule from the developer: "when we convert an implementation to real we remove all mock repositories; we keep only the single real class."**
   - DECIDED (principle): the app (`lib/`) keeps only the implementation it runs. When a feature becomes real, its mock repository leaves `lib/`.
   - Current facts (VERIFIED): `MockAuthRepository`, `MockDiscoverRepository` and `MockMediaRepository` are no longer used by the app at all — only by tests (5, 2 and 4 test files). `MockProfileRepository` is still used by `lib/main.dart` as the sample-people source for the mock feed, connections and chat, so it cannot leave `lib/` until those features are real. `MockSafetyRepository` is used by `lib/main.dart` (reports stay mock until the Feed phase).
   - Detail — what happens to a removed mock (DECIDED 2026-11-26: **A, move to `test/fakes/`**):
     - A **(Recommended)**: **move** it to `test/fakes/` as a test-only fake (same code, new location, imported only by tests). The app has a single real class; the 140+ automated tests keep running without Supabase.
     - B: **delete** it completely. Every test that uses it is deleted or rewritten; screen and cubit tests for auth, profile setup, media upload, discover and blocks would be lost (tests cannot call the real Supabase project).
   - Proposed application in this phase (with A):
     - Blocks: the block code leaves `MockSafetyRepository` (which keeps only `reportPost`); a test fake `test/fakes/fake_block_repository.dart` takes the block code.
     - Already-real features: move `mock_auth_repository.dart`, `mock_discover_repository.dart` and `mock_media_repository.dart` from `lib/data/repositories/mock/` to `test/fakes/` (imports in tests updated). `MockDiscoverRepository` then depends on the block test fake instead of `MockSafetyRepository`.
     - `MockProfileRepository` and the other mocks (feed, connections, chat, notifications, safety-reports) stay in `lib/` until their phases, and each later phase moves its own mock when it becomes real.
   - Docs: add the rule to `docs/ARCHITECTURE.md` and `docs/CLASS_AND_COMPONENT_RULES.md` (test doubles live in `test/`).

## Scope

- In scope (recommended answers):
  - Migration: `blocks` table, constraints, index, RLS, grants; updated read policies on `profiles` / `teacher_details` / `student_details`; rollback notes.
  - RLS check script (two users, rolled back).
  - `BlockRepository` interface; `SupabaseBlockRepository`; `SafetyRepository` reduced to `reportPost`; `MockSafetyRepository` implements both.
  - `SupabaseDiscoverRepository`: drops people the viewer blocked; re-loads on block changes (takes `BlockRepository` in its constructor).
  - `lib/main.dart`: `BlockRepository` = Supabase; `SafetyRepository` = mock (reports).
  - 6 cubits + their screens switch the block dependency to `BlockRepository`; failure handling in `PublicProfileCubit.block()` and `BlockedUsersCubit.unblock()` + 1 string.
  - Tests and docs.
- Decision 8 (A confirmed): move `MockAuthRepository`, `MockDiscoverRepository`, `MockMediaRepository` to `test/fakes/`; block code from `MockSafetyRepository` to `test/fakes/fake_block_repository.dart`; rule added to the architecture docs.
- Explicitly out of scope: post / comment reports on Supabase, the `reports` table, the 3-reports auto-hide, report reasons UI changes (Feed phase); connection / chat / feed block enforcement on the server (their phases); admin ban (`profiles.is_banned` — open decision in `KNOWN_ISSUES`); Realtime; dependencies; native changes.
- Files expected to change:
  - `lib/data/repositories/safety_repository.dart`, `lib/data/repositories/mock/mock_safety_repository.dart`, `lib/data/repositories/supabase/supabase_discover_repository.dart`, `lib/main.dart`
  - `lib/features/connections/bloc/connections_cubit.dart`, `lib/features/connections/presentation/connections_screen.dart`
  - `lib/features/discover/bloc/public_profile_cubit.dart`, `lib/features/discover/presentation/public_profile_screen.dart`
  - `lib/features/feed/bloc/feed_cubit.dart`, `lib/features/feed/presentation/home_screen.dart`
  - `lib/features/notifications/bloc/notifications_cubit.dart`, `lib/features/notifications/presentation/notifications_screen.dart`
  - `lib/features/safety/bloc/report_cubit.dart`, `lib/features/safety/presentation/report_sheet.dart`
  - `lib/features/settings/bloc/blocked_users_cubit.dart`, `lib/features/settings/presentation/blocked_users_screen.dart`
  - `lib/l10n/app_en.arb` + generated `app_localizations*.dart` (1 string)
  - Tests: `test/helpers/test_app.dart`, `test/features/cubits_test.dart`, `test/features/discover_connect_test.dart`, `test/features/profile_settings_test.dart`, `test/features/chat_notifications_test.dart`, `test/features/screens_test.dart`, `test/data/supabase/supabase_discover_repository_test.dart` (only where they construct these cubits / repositories)
  - Docs: `docs/DATABASE_AND_CACHE.md`, `docs/API_REFERENCE.md`, `docs/ARCHITECTURE.md`, `docs/FILE_CATALOG.md`, `docs/KNOWN_ISSUES.md` (close the PHASE_006 blocks gap), phase / state / index
- Files that must not change: product plans, earlier migrations (new migration only), models, `ProfileRepository` / `DiscoverRepository` signatures, auth and account-deletion code, native files, `pubspec.yaml`.
- Proposed new files (approval required):
  - `supabase/migrations/20261127120000_blocks.sql`
  - `supabase/tests/blocks_rls_checks.sql`
  - `lib/data/repositories/block_repository.dart` — interface `BlockRepository` + `BlockedUser` (moved). Reason: interface segregation; reports stay mock while blocks become real.
  - `lib/data/repositories/supabase/supabase_block_repository.dart` — `SupabaseBlockRepository`. Reason: no Supabase block implementation exists.
  - `test/fakes/fake_block_repository.dart` (decision 8A) — `FakeBlockRepository`, test-only, holds the block code moved out of `MockSafetyRepository`.
  - Moves (decision 8A, renames — approval required): `lib/data/repositories/mock/mock_auth_repository.dart` → `test/fakes/mock_auth_repository.dart`, `mock_discover_repository.dart` → `test/fakes/mock_discover_repository.dart`, `mock_media_repository.dart` → `test/fakes/mock_media_repository.dart`; every test importing them is updated (`test/helpers/test_app.dart`, `test/features/*.dart`, `test/data/*.dart`).
  - `test/data/supabase/supabase_block_repository_test.dart` — only for logic testable without network (row → `BlockedUser` mapping, ordering), no new packages.
- Proposed new classes: `BlockRepository` (interface; contract: `blockUser` idempotent, refuses self with `ValidationFailure`; streams emit now and after local changes; throws only `*Failure`), `SupabaseBlockRepository` (constructor: `SupabaseClient`, `SupabaseFailureMapper`).
- Dependency changes: None.
- API contract changes: `SafetyRepository` loses the 4 block methods (moved unchanged to `BlockRepository`); `SupabaseDiscoverRepository` constructor gains `BlockRepository`.
- Native changes: None.
- Supabase migration / RLS / function changes: new `blocks` table + RLS; changed read policies on `profiles`, `teacher_details`, `student_details` (approval required).
- Approval requirements: everything above (High risk).

## Readiness Checklist

- [x] Requirement is clear
- [x] Expected behavior is clear
- [x] Existing flow is traced
- [x] API is verified
- [x] Request contract is verified
- [x] Response contract is verified
- [x] Supabase tables, RLS and Storage policies are defined (decisions 2, 3 decided)
- [x] Security, 18+ gate and moderation rules are unaffected or approved (decision 2 decided: profile read rule change; final approval at Approve Phase)
- [x] Required UI/design is available (existing block sheet and Blocked users screen; only a snackbar string is new)
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
- [x] Decision 8 detail confirmed (move mocks to `test/fakes/`)

## Risks

- RLS change on `profiles` affects every profile read (public profile, feed authors, connections, chat headers). A wrong policy could hide profiles from everyone — mitigated by the rolled-back RLS check script and the "viewer also blocked the owner" exception.
- Policy cost: each profile read checks `blocks`; mitigated by the primary key and the `blocked_id` index (small table).
- Interface split touches 6 cubits and their screens; behaviour must stay the same (tests cover each).
- Remote migration must be applied before the new build, otherwise every block call fails (missing table).
- Mixed data until later phases: feed, connections and notifications are still mock, so blocking a real user does not change mock posts or requests.

## Test Plan

- Automated: `SupabaseBlockRepository` mapping / ordering (no network); `SupabaseDiscoverRepository` drops blocked ids and re-loads on block change (fake `BlockRepository`); `PublicProfileCubit.block()` and `BlockedUsersCubit.unblock()` keep state and report failure; existing block tests pass on `MockSafetyRepository` through `BlockRepository`.
- SQL (developer, `blocks_rls_checks.sql`, rolled back): own insert / select / delete pass; inserting a block for someone else fails; self-block fails; reading another user's blocks returns nothing; after A blocks B, B cannot read A's profile / details; A still reads B; mutual block still lets each read the other's name.
- Manual (two accounts, Android and iOS): block from a profile → gone from lists and search on both sides; the blocked account sees "not available" on the blocker's profile; Blocked users shows the person; Unblock → both see each other again after refresh; airplane mode → block / unblock shows the error and nothing changes; delete an account → its blocks disappear.

## Rollback Plan

- App: revert the phase commit (`main.dart` wiring returns to `MockSafetyRepository` for blocks).
- Database: the migration's rollback section restores the PHASE_004 read policies (`using (true)`) on the three profile tables and drops `blocks`. No profile data is lost; block rows are lost (they did not exist before).

## Implementation

- Approved implementation plan: Approved 2026-11-26 (developer: "Approve phase"). Covers decisions 1–8 and the Scope section: `blocks` migration (table, constraints, index, RLS, grants; changed read policies on `profiles` / `teacher_details` / `student_details` with the mutual-block exception; rollback notes) and `supabase/tests/blocks_rls_checks.sql`; `BlockRepository` interface (`lib/data/repositories/block_repository.dart`) and `SupabaseBlockRepository`; `SafetyRepository` reduced to `reportPost`; `SupabaseDiscoverRepository` block filter + reload (constructor gains `BlockRepository`); `main.dart` wiring; 6 cubits + screens switched; `Failure` handling in `PublicProfileCubit.block()` / `BlockedUsersCubit.unblock()` + string `blockFailedMessage`; moves of `mock_auth_repository.dart`, `mock_discover_repository.dart`, `mock_media_repository.dart` to `test/fakes/` and `test/fakes/fake_block_repository.dart`; optional `test/data/supabase/supabase_block_repository_test.dart`; tests; docs (incl. the mock rule in `ARCHITECTURE` / `CLASS_AND_COMPONENT_RULES`). Not approved: reports table or post reports, Realtime, dependencies, native changes, other migrations, model changes.
- Implementation log: 2026-11-26 — implemented the approved scope (decisions 1–8). See Change Log.
- Exact changed files: see Change Log
- Purpose of every changed file: see Change Log
- Existing components reused: listed in Analysis
- New approved components: `BlockRepository`, `SupabaseBlockRepository`, `FakeBlockRepository` (test), migration `20261127120000_blocks.sql`, `blocks_rls_checks.sql`, `supabase_block_repository_test.dart`
- Deviations from the plan (recorded, no approval impact):
  - `BlockRepository.blockUser` treats blocking yourself as a **no-op** (the plan text said "refuses with `ValidationFailure`"); no existing reason fits and the UI never offers self-block; the database also refuses it (check constraint).
  - The profile read rule needs a `security definer` helper `private.hidden_by_block(uuid)`: a user cannot read other people's block rows under the blocks RLS, so the policy cannot query `blocks` directly. `authenticated` gets usage on schema `private` and execute on this one function (other private functions stay revoked; `private` is not exposed by the API).
- Out-of-scope findings:
  - `PublicProfileCubit.block()` and `BlockedUsersCubit.unblock()` have no `Failure` handling today (harmless with the mock; included in scope because the real repository can fail).
  - Admin "ban user" still has no column (`KNOWN_ISSUES` open decision 1).
- Unexpected risks: None

## Change Log

| File path | Change type | Approved in phase | What changed | Why it changed | Existing behavior preserved | Possible side effects | File-level checks |
|---|---|---|---|---|---|---|---|
| `supabase/migrations/20261127120000_blocks.sql` | added | Yes | `blocks` table, PK / FKs / check / index, RLS, column-limited insert grant, `private.hidden_by_block`, new read policies on 3 profile tables, rollback notes | Real blocks enforced by the database | Owner update / insert policies unchanged | Every profile read evaluates the helper (indexed) | Not run against a database (no CLI); developer runs the check script |
| `supabase/tests/blocks_rls_checks.sql` | added | Yes | 13 rolled-back checks (own block, duplicate, someone else, self, created_at, read rules both ways, mutual block, unblock, anon) | Verify RLS | — | None (rolled back) | Not run (developer) |
| `lib/data/repositories/block_repository.dart` | added | Yes | `BlockRepository` + `BlockedUser` (moved) | Interface split (decision 1) | Same 4 methods and record type | None | analyze |
| `lib/data/repositories/safety_repository.dart` | modified | Yes | Only `reportPost` remains | Reports stay mock | `reportPost` unchanged | None | analyze |
| `lib/data/repositories/supabase/supabase_block_repository.dart` | added | Yes | Insert (duplicate = success, self = no-op), delete, load newest first, streams reload after local changes, `Failure` mapping | Real blocks | — | No Realtime: others' blocks show on next load | `supabase_block_repository_test.dart` |
| `lib/data/repositories/supabase/supabase_discover_repository.dart` | modified | Yes | Constructor takes `BlockRepository`; lists reload per blocked-ids emission and drop blocked people | Decision 4 | Query, cap, photo rules unchanged | One extra small query per load | `supabase_discover_repository_test.dart` |
| `lib/data/repositories/mock/mock_safety_repository.dart` | modified | Yes | Reports only (`reportCount`, `removeUser`) | Decision 8 | Report behaviour unchanged | None | tests |
| `lib/data/repositories/mock/mock_auth_repository.dart` → `test/fakes/mock_auth_repository.dart` | renamed (`git mv`, staged) | Yes | Package imports; test-only note | Decision 8 | Code unchanged | Production can no longer import it (intended) | analyze, tests |
| `lib/data/repositories/mock/mock_discover_repository.dart` → `test/fakes/mock_discover_repository.dart` | renamed (`git mv`, staged) | Yes | Package imports; uses `FakeBlockRepository` | Decision 8 | Listing logic unchanged | None | tests |
| `lib/data/repositories/mock/mock_media_repository.dart` → `test/fakes/mock_media_repository.dart` | renamed (`git mv`, staged) | Yes | Package imports; test-only note | Decision 8 | Code unchanged | None | tests |
| `test/fakes/fake_block_repository.dart` | added | Yes | Block code from `MockSafetyRepository` + `failWith` + self no-op | Decision 8 | Same behaviour as the old mock blocks | None | tests |
| `lib/main.dart` | modified | Yes | `SupabaseBlockRepository` registered as `BlockRepository` and passed to `SupabaseDiscoverRepository`; doc comment (real / mock list, mock rule) | Wiring | Other repositories unchanged | Needs the migration | analyze |
| `lib/features/connections/bloc/connections_cubit.dart`, `presentation/connections_screen.dart` | modified | Yes | `BlockRepository` instead of `SafetyRepository` | Decision 1 | Behaviour unchanged | None | tests |
| `lib/features/discover/bloc/public_profile_cubit.dart`, `presentation/public_profile_screen.dart` | modified | Yes | `BlockRepository`; `block()` returns false on `Failure`; screen shows `blockFailedMessage` | Decisions 1, 5 | Success path unchanged | None | cubits_test |
| `lib/features/feed/bloc/feed_cubit.dart`, `presentation/home_screen.dart` | modified | Yes | `BlockRepository` | Decision 1 | Unchanged | None | tests |
| `lib/features/notifications/bloc/notifications_cubit.dart`, `presentation/notifications_screen.dart` | modified | Yes | `BlockRepository` | Decision 1 | Unchanged | None | tests |
| `lib/features/safety/bloc/report_cubit.dart`, `presentation/report_sheet.dart` | modified | Yes | Takes `SafetyRepository` (report) and `BlockRepository` (also-block) | Decision 1 | Unchanged | None | cubits_test |
| `lib/features/settings/bloc/blocked_users_cubit.dart`, `blocked_users_state.dart`, `presentation/blocked_users_screen.dart` | modified | Yes | `BlockRepository`; `unblock()` returns false on `Failure`; screen shows `blockFailedMessage` | Decisions 1, 5 | Unchanged on success | None | cubits_test |
| `lib/l10n/app_en.arb` + 2 generated | modified | Yes | `blockFailedMessage` | Decision 5 | Other strings unchanged | None | gen-l10n |
| Tests: `test/helpers/test_app.dart`, `test/data/mock_data_test.dart`, `test/data/supabase/supabase_discover_repository_test.dart`, `test/features/{chat_notifications,cubits,discover_connect,media_upload_cubits,profile_settings,screens}_test.dart`; added `test/data/supabase/supabase_block_repository_test.dart` | modified / added | Yes | Imports from `test/fakes/`; `FakeBlockRepository` where blocks are used; new tests: block row mapping, self no-op, discover drops blocked, block / unblock failure | Cover the change | Existing assertions unchanged | — | `flutter test` |
| Docs: `DATABASE_AND_CACHE`, `API_REFERENCE`, `ARCHITECTURE`, `CLASS_AND_COMPONENT_RULES`, `FILE_CATALOG`, `KNOWN_ISSUES`; phase / state / index | modified | Yes | PHASE_007 facts, mock rule, blocks gap closed | Required docs | — | — | `validate_phase_structure.sh` |

Pre-existing uncommitted changes at the start: PHASE_007 phase docs only (not claimed as implementation).

## Execute Technical Checks

- Changed-file evidence reviewed after changes: `git status --short` after implementation — exactly the files in the Change Log (3 renames staged by `git mv`)
- Git status/diff rerun reason: baseline at start; once after implementation to confirm the file list
- Patch/whitespace check result, when run: Not run
- Relevant Dart formatting: `dart format lib test` — clean after formatting
- Scoped or project analysis commands: `flutter analyze` (interface split across features) — No issues found (one new unused-import warning fixed)
- Relevant targeted tests: `flutter test` (full) — 152/152 passed (5 new)
- Newly introduced issues found: 1 unused import in `chat_notifications_test.dart`
- Newly introduced issues fixed: the unused import
- Pre-existing unrelated issues: None recorded
- Commands that could not run and why: migration and `blocks_rls_checks.sql` not run (no Supabase CLI or project link; the developer applies them); app not launched (not requested); iOS not built (Windows)

## Manual Testing

- Ready for developer manual testing: Yes (2026-11-26). First apply `supabase/migrations/20261127120000_blocks.sql` in the SQL editor and run `supabase/tests/blocks_rls_checks.sql` (all PASS); then follow the Manual tests in the Test Plan with two accounts.
- Developer manual-test confirmation: Not provided
- Manual-test notes requested by developer: None

## Closure

- Developer manual-test confirmation: "Tested and working" (2026-11-26, CLOSE PHASE request). Migration and `blocks_rls_checks.sql` results not reported separately.
- Tested platforms: Not stated by the developer
- Tested devices: Not stated by the developer
- Failed and retested cases: None reported
- Final changed files: as in the Change Log (no change after Execute; `git status` file list identical, nothing committed; 3 renames staged by `git mv`).
- Known limitations: no Realtime — a block made by the other person shows on the next load / pull-to-refresh; feed, connections, chat and notifications are still mock, so blocks do not affect their data yet; post / comment reports and the 3-reports auto-hide are still mock (Feed phase); `MockProfileRepository` stays in `lib/` as the sample-people source until those phases.
- Follow-up phases: Connections (refuse requests across a block on the server), Chat (refuse messages across a block), Feed (real posts, reports, auto-hide, hide blocked authors on the server).
- Reused Execute technical evidence at closure: Yes — `flutter analyze` clean, `flutter test` 152/152; no implementation file changed afterwards.
- Rollback guidance: see Rollback Plan (app: revert the phase changes; database: the migration's rollback section restores the PHASE_004 read policies and drops `blocks`).
- Final status: CLOSED / COMPLETED
- Completion date: 2026-11-26
