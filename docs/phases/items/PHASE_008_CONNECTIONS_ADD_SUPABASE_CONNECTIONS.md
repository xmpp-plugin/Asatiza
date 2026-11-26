# PHASE_008_CONNECTIONS_ADD_SUPABASE_CONNECTIONS — Connections: real requests on Supabase

## Identity

- Phase ID: PHASE_008_CONNECTIONS_ADD_SUPABASE_CONNECTIONS
- Phase title: Connections — real requests, accept / decline / remove on Supabase
- File name: PHASE_008_CONNECTIONS_ADD_SUPABASE_CONNECTIONS.md
- Module: CONNECTIONS
- Priority: High
- Risk level: High (new table, RLS, 3 database functions, a trigger on `blocks`, a change to the shared failure reasons, repository-contract wording, several screens)
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
- Dependency phases: PHASE_006_BACKEND_ADD_SUPABASE_DISCOVER_TEACHERS_STUDENTS (closed), PHASE_007_SAFETY_ADD_SUPABASE_BLOCKS (closed)

## Requirement

- Original developer request: "A and after 3 days" — Connections now (option A: chat stays mock; "Message" on a real connection says chat is coming soon until the Chat phase); a declined requester may ask again after **3 days**.
- Business objective: students and teachers can really connect (plan sections 3.10, 4 "Connect and chat", 7 "Connect button", 12 `connections` table).
- Expected outcome: Connect, Pending, Accept / Decline, Remove and the connection counts work on real Supabase data, with the rules enforced by the database.
- Acceptance criteria:
  1. Connect (optional note up to 200 characters) creates a real pending request; the button shows **Pending**.
  2. The receiver sees it in **My connections → Requests** and can **Accept** or **Decline**; after Accept both see each other under **Connected** and the button shows **Message**.
  3. Either side can **Remove** an accepted connection; the sender can **cancel** a pending request.
  4. The database refuses a request when: either person is not active; there is a block either way; a pending or accepted connection already exists; the receiver declined the same requester less than **3 days** ago; the requester already sent **10 requests in the last 24 hours**; the request is to yourself; the note is over 200 characters.
  5. Each refusal shows the plan's message (Connect button / sheet).
  6. Blocking someone removes any connection between the two.
  7. Only the two people involved can see a connection; nobody can accept, decline or remove for someone else.
  8. Account deletion removes the user's connections.
  9. "Message" on a real connection shows "Chat is coming soon" (no crash, no mock chat error).

## Analysis

- Current behavior (VERIFIED): `lib/main.dart` wires `MockConnectionRepository(sampleProfiles)` as `ConnectionRepository`; it also feeds `MockChatRepository(connections)`. Requests to real users are kept in memory only. `DiscoverVisibilityRules.canSendRequest` (sender active) is the only rule checked; there is no daily limit, no re-request rule, no server check.
- Expected behavior: acceptance criteria.
- Root cause / gap: no `connections` table, functions or Supabase implementation.
- End-to-end flow (traced, VERIFIED):
  - Lists: `DiscoverScreen._connectButton` → state from `DiscoverCubit` (`watchConnections` → `connectionWith`) → Connect opens `ConnectSheet` → `ConnectRequestCubit.send()` → `ConnectionRepository.sendRequest`; incoming pending → `DiscoverCubit.accept` → `respond`.
  - Public profile: `PublicProfileScreen` → `PublicProfileCubit` (`watchConnections` for me and for them → count) → same sheet; Message → `AppRoutes.chat(id)`.
  - My connections: `ConnectionsScreen` → `ConnectionsCubit` (`watchConnections`, `respond`, `remove`, `block`) → Message → `AppRoutes.chat(id)`.
  - My profile: `MyProfileCubit` → `watchConnections` (count).
  - Notifications: `NotificationsCubit.respond` → `respond` for sample request notifications (mock data, `Failure` caught).
  - Chat: `MockChatRepository` reads `MockConnectionRepository.acceptedIdsOf` / `changes` (mock).
  - Server (proposed): `public.connections` + RLS (select only) → writes through `send_connection_request`, `respond_to_connection`, `remove_connection` (security definer RPCs) → `profiles.status`, `blocks`.
- Relevant files: `lib/data/repositories/connection_repository.dart`, `mock/mock_connection_repository.dart`, `mock/mock_chat_repository.dart`, `lib/data/models/connection.dart`, `enums/connection_status.dart`, `lib/core/errors/failures.dart`, `lib/core/logic/discover_visibility_rules.dart`, `lib/features/connections/{bloc,presentation}/*`, `lib/features/discover/bloc/{discover_cubit,public_profile_cubit}.dart`, `presentation/{discover_screen,public_profile_screen}.dart`, `lib/features/profile/bloc/my_profile_cubit.dart`, `lib/features/notifications/bloc/notifications_cubit.dart`, `lib/main.dart`, `supabase/migrations/20261127120000_blocks.sql`.
- Existing reusable components (VERIFIED): `Connection` model and `ConnectionStatus` (pending / accepted / declined / removed — already match the plan), `ConnectNoteRules` (200 characters), `ConnectSheet` + `ConnectRequestCubit` (error mapping by `ValidationReason`), `ConnectionsScreen` tabs, `SupabaseFailureMapper`, the "load on subscribe + after local changes" stream pattern (`SupabaseBlockRepository`), `RequestTile`, existing strings `connectAlreadyError`, `connectNoteTooLongError`, profile-incomplete message.
- Existing API details: PostgREST via `supabase_flutter` (`from` for reads, `rpc` for the 3 functions). No Dio, no Edge Function.
- Existing models: `Connection` (no `respondedAt`; not needed by the app). No model change proposed.
- State management: unchanged cubits; only error mapping and button states grow.
- Navigation: unchanged; the 3 "Message" buttons on connection-based screens show a snackbar instead of opening the mock chat for real connections (decision 5).
- Android / iOS: no platform code, permissions or native change.
- Lifecycle: streams cancelled in each cubit's `close()` (kept); repository change controller lives for the session.
- Database and cache: no local cache. No Realtime: connection lists load on subscribe and after changes made on this device; a request from someone else appears the next time the screen subscribes (opening My connections / the profile, or pull-to-refresh on lists).
- Supabase tables, columns and migrations (proposed, plan section 12): `connections (id, requester_id, receiver_id, status, note, created_at, responded_at)`; one row per pair (unique on the unordered pair); FKs to `profiles` on delete cascade; `check (requester_id <> receiver_id)`; note ≤ 200; index on `(requester_id, created_at)` for the 24-hour limit and on `receiver_id`.
- RLS (proposed): select where `auth.uid()` is requester or receiver; **no** direct insert / update / delete grants — all writes through the 3 functions.
- Realtime, Edge Functions, push: none (push for requests is the Notifications phase).
- Both roles: same rules for teachers and students; signed-out users have no access.
- Security: no secrets; functions use `auth.uid()` (never a client-supplied requester id); `security definer` with empty `search_path`; blocks checked both ways inside the function (the caller cannot read the other person's blocks).

## Missing Information / Decisions Needed

Decided by the developer (2026-11-26): **A** (Connections now, chat stays mock) and **re-request after 3 days** following a decline.

**Answered 2026-11-26** — developer: "Accept recommendations". Decisions 1–11 below are DECIDED as the **(Recommended)** option.

1. **One row per pair.** **(Recommended)** a single row per two people (unique on the unordered pair). Cancel / Remove set status `removed` (the row is kept so the 24-hour limit cannot be bypassed by cancel-and-resend); a later request resets the same row to `pending` (new requester, note, `created_at`).
2. **All writes through database functions.** **(Recommended)** `send_connection_request(receiver, note)`, `respond_to_connection(id, accept)`, `remove_connection(id)` (security definer). The table is read-only for the app. Each function checks the rules and returns the row (send) or nothing.
3. **3-day rule detail.** **(Recommended)** applies to the **same requester** asking the **same receiver** again after that receiver declined; the person who declined may send a request back at any time.
4. **Opposite pending request.** **(Recommended)** if B already sent A a pending request, A's Connect is refused with "already connected" (A sees Accept instead — the existing UI already does this).
5. **Message on real connections.** **(Recommended)** the "Message" buttons in Lists, Public profile and My connections show a snackbar "Chat is coming soon." until the Chat phase (sample notifications keep their current behaviour).
6. **Block removes the connection.** **(Recommended)** a trigger on `blocks` insert sets any connection between the two to `removed`.
7. **Mock connections stay as sample data.** **(Recommended)** under the PHASE_007 rule, `MockConnectionRepository` is no longer registered as `ConnectionRepository`, but it stays in `lib/` as the sample source for the still-mock chat (like `MockProfileRepository`) and moves to `test/fakes/` in the Chat phase.
8. **New failure reasons** (shared `failures.dart`, approval). **(Recommended)** `requestLimitReached` ("You've sent 10 requests in the last 24 hours. Try again later."), `declinedRecently` ("This person declined your request. You can ask again after 3 days."), `receiverNotActive` ("This teacher is still completing their profile. You can connect once it's complete." — "student" wording for a student receiver). `profileIncomplete` now means "your profile is not active".
9. **"Not accepting requests yet".** **(Recommended)** Connect on a not-active profile (only reachable from the feed) is disabled with "Not accepting requests yet"; tapping it shows the receiver-not-active message.
10. **Freshness.** **(Recommended)** no Realtime; My connections and the public profile load on open and after local changes; lists already reload on pull-to-refresh.
11. **Sample request notifications.** **(Recommended)** leave the mock Notifications tab as is; Accept on a sample request does nothing (sample data, `Failure` already caught). Real requests are handled in My connections until the Notifications phase.

## Scope

- In scope (decided 2026-11-26):
  - Migration: `connections` table, constraints, indexes, RLS (select only), 3 functions, block trigger, grants, rollback notes.
  - RLS / function check script (two users, rolled back).
  - `SupabaseConnectionRepository` (reads, 3 RPCs, error-code mapping to the new reasons, streams reload after local changes).
  - `ConnectionRepository` contract wording (signatures unchanged).
  - 3 new `ValidationReason` values + messages; `ConnectSheet` mapping; Connect button "Not accepting requests yet"; "Chat is coming soon" snackbar on 3 Message buttons.
  - `lib/main.dart`: real `ConnectionRepository`; `MockConnectionRepository` kept only as the mock chat's sample source.
  - Tests and docs.
- Explicitly out of scope: real chat (Chat phase), real notifications / push for requests (Notifications phase), feed ("posts from connections first", Feed phase), Realtime, admin views, dependencies, native changes, model changes.
- Files expected to change:
  - `lib/data/repositories/connection_repository.dart` (doc comments), `lib/core/errors/failures.dart` (3 reasons + display mapping), `lib/main.dart`
  - `lib/features/connections/presentation/connect_sheet.dart`, `lib/features/connections/presentation/connections_screen.dart`
  - `lib/features/discover/presentation/discover_screen.dart`, `lib/features/discover/presentation/public_profile_screen.dart`
  - `lib/data/repositories/mock/mock_connection_repository.dart` (doc comment: sample source only; reasons kept in step with the contract)
  - `lib/l10n/app_en.arb` + generated `app_localizations*.dart`
  - Tests: `test/helpers/test_app.dart`, `test/features/discover_connect_test.dart`, `test/features/cubits_test.dart`, others only if they construct changed classes
  - Docs: `docs/DATABASE_AND_CACHE.md`, `docs/API_REFERENCE.md`, `docs/ARCHITECTURE.md`, `docs/FILE_CATALOG.md`, `docs/KNOWN_ISSUES.md`; phase / state / index
- Files that must not change: product plans, earlier migrations, models, `DiscoverRepository` / `BlockRepository` / `ProfileRepository` signatures, chat and notifications implementations, auth, native files, `pubspec.yaml`.
- Proposed new files (approval required):
  - `supabase/migrations/20261128120000_connections.sql`
  - `supabase/tests/connections_rls_checks.sql`
  - `lib/data/repositories/supabase/supabase_connection_repository.dart` — reason: no Supabase implementation exists.
  - `test/data/supabase/supabase_connection_repository_test.dart` — row → `Connection` mapping and error-code mapping only (no network, no new packages).
- Proposed new classes: `SupabaseConnectionRepository` (constructor: `SupabaseClient`, `SupabaseFailureMapper`; contract = `ConnectionRepository`; throws only `*Failure`).
- Dependency changes: None.
- API contract changes: `ConnectionRepository.sendRequest` documents 3 new `ValidationFailure` reasons; signatures unchanged.
- Native changes: None.
- Supabase migration / RLS / function changes: new table, RLS, 3 functions, trigger on `blocks` (approval required).

## Execution Stop (2026-11-26) — resolved: option A approved (developer: "A: add count function")

Execution stopped before any code change (rule: an unplanned new database function and interface change need approval).

- Finding (VERIFIED): `PublicProfileCubit` shows **the other person's** connection count by calling `watchConnections(profileId)` for that person. With the approved RLS (a user reads only connections they are part of), the Supabase implementation would return only the row between the viewer and that person, so the count would show 0 or 1 — wrong.
- Options:
  - A **(Recommended)**: a 4th security-definer function `public.connection_count(p_user uuid)` returning the number of **accepted** connections of a profile the viewer may see (0 when the profile is hidden from the viewer by a block); a new interface method `ConnectionRepository.connectionCount(String userId)` (returns `Future<int>`); `PublicProfileCubit` uses it instead of watching the other person's list (re-read after the viewer connects / disconnects); the mock and fakes implement it.
  - B: hide the connection count on other people's profiles until a later phase (UI change: the "N connections" figure is removed from the public profile).
- Nothing else in the approved scope is affected; My profile counts the user's own connections (allowed by RLS).

## Readiness Checklist

- [x] Requirement is clear
- [x] Expected behavior is clear
- [x] Existing flow is traced
- [x] API is verified
- [x] Request contract is verified
- [x] Response contract is verified
- [x] Supabase tables, RLS and Storage policies are defined (decisions 1, 2, 6 decided)
- [x] Security, 18+ gate and moderation rules are unaffected or approved
- [x] Required UI/design is available (existing Connect sheet, buttons and My connections; only messages are new — plan section 7 wording)
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

- Real connections next to mock chat and notifications: "Message" must not open the mock chat for real people (decision 5); sample request notifications stay sample data.
- Function logic decides who can connect (protected rule) — mitigated by the rolled-back check script covering every refusal.
- Remote migration must be applied before the new build, otherwise every connection call fails.
- No Realtime: an incoming request is not pushed to an open screen.

## Test Plan

- Automated: repository row / error mapping; `ConnectRequestCubit` shows each new reason; Connect button states (not active / pending / connected) on the public profile and lists; Message snackbar; existing connection tests on the mock.
- SQL (developer, `connections_rls_checks.sql`, rolled back): send OK; duplicate refused; opposite pending refused; self refused; note > 200 refused; not-active sender / receiver refused; block either way refused; 11th request in 24 h refused; declined → re-request within 3 days refused (simulated by back-dating `responded_at`), after 3 days allowed; only receiver can respond; only involved users can remove; outsider cannot read; direct insert / update / delete refused; blocking removes the connection; anon has no access.
- Manual (two accounts, Android and iOS): connect with a note → Pending; other account accepts in My connections → both Connected, counts update; Message → "Chat is coming soon"; remove; decline → re-request refused with the 3-day message; send 10 requests then an 11th → limit message; block a connected person → connection gone.

## Rollback Plan

- App: revert the phase commit (`main.dart` returns to `MockConnectionRepository`).
- Database: the migration's rollback section drops the 3 functions, the block trigger and the `connections` table (connection rows are lost; they did not exist before).

## Implementation

- Approved implementation plan: Approved 2026-11-26 (developer: "APPROVE PHASE: PHASE_008_CONNECTIONS_ADD_SUPABASE_CONNECTIONS"). Covers decisions A, 3-day re-request and 1–11 and the Scope section: migration `20261128120000_connections.sql` (table, one row per pair, constraints, indexes, select-only RLS, `send_connection_request` / `respond_to_connection` / `remove_connection` security-definer functions, block trigger, grants, rollback notes); `supabase/tests/connections_rls_checks.sql`; `SupabaseConnectionRepository` + `test/data/supabase/supabase_connection_repository_test.dart`; `ConnectionRepository` contract wording (signatures unchanged); 3 new `ValidationReason` values (`requestLimitReached`, `declinedRecently`, `receiverNotActive`) with messages; Connect sheet mapping; "Not accepting requests yet" button; "Chat is coming soon" on 3 Message buttons; `main.dart` wiring with `MockConnectionRepository` kept only as the mock chat's sample source; tests; docs. Not approved: real chat, notifications / push, feed, Realtime, dependencies, native changes, model changes.
- Implementation log: 2026-11-26 — execution stopped once before any code (public profile count; option A approved), then the approved scope plus `connection_count` / `connectionCount` was implemented. See Change Log.
- Exact changed files: see Change Log
- Purpose of every changed file: see Change Log
- Existing components reused: listed in Analysis
- New approved components: migration `20261128120000_connections.sql` (4 functions + block trigger), `connections_rls_checks.sql`, `SupabaseConnectionRepository`, `supabase_connection_repository_test.dart`, `ConnectionRepository.connectionCount`
- Out-of-scope findings:
  - The Notifications tab's sample request notifications cannot reach real requests until the Notifications phase.
  - The feed rule "posts from connections first" needs real connections and real posts (Feed phase).
- Unexpected risks: None

## Change Log

| File path | Change type | Approved in phase | What changed | Why it changed | Existing behavior preserved | Possible side effects | File-level checks |
|---|---|---|---|---|---|---|---|
| `supabase/migrations/20261128120000_connections.sql` | added | Yes | Table, pair unique index, indexes, select-only RLS, `send_connection_request` / `respond_to_connection` / `remove_connection` / `connection_count`, block trigger, grants, rollback | Real connections with server rules | — | Needs the migration before the build | Not run against a database (no CLI) |
| `supabase/tests/connections_rls_checks.sql` | added | Yes | 15 rolled-back checks (direct insert, self, long note, send, duplicate, requester accept, opposite pending, decline, 3-day refuse / allow, accept + count, block removes, request across block, count hidden, anon) | Verify rules | — | None (rolled back) | Not run (developer) |
| `lib/data/repositories/supabase/supabase_connection_repository.dart` | added | Yes | Reads (members, pending / accepted, newest first), RPC writes, rule-message → `Failure` mapping, `connectionCount`, streams reload after local changes; **fix 1**: every load shared with all open streams of the same user | Real connections | Contract unchanged except `connectionCount` | No Realtime | `supabase_connection_repository_test.dart` |
| `lib/data/repositories/connection_repository.dart` | modified | Yes | Contract wording + `connectionCount` | Execution-stop option A | Other signatures unchanged | Every implementation needs `connectionCount` | analyze |
| `lib/core/errors/failures.dart` | modified | Yes | `requestLimitReached`, `declinedRecently`, `receiverNotActive` | Decision 8 | Other reasons unchanged | None (no exhaustive switches broke) | analyze |
| `lib/data/repositories/mock/mock_connection_repository.dart` | modified | Yes | Doc (sample source only); receiver-not-active check; `connectionCount` | Decision 7; contract | Sample data unchanged | None | tests |
| `lib/main.dart` | modified | Yes | `SupabaseConnectionRepository` registered; `sampleConnections` feeds the mock chat only; doc comment | Wiring | Other repositories unchanged | Needs the migration | analyze |
| `lib/features/discover/bloc/public_profile_cubit.dart` | modified | Yes | Count via `connectionCount` (re-read when the viewer's connections change) instead of watching the other person's list | RLS-safe count | Own connection state unchanged | One small RPC per change | tests |
| `lib/features/discover/presentation/public_profile_screen.dart` | modified | Yes | "Not accepting requests yet" for a not-active profile; Message → "Chat is coming soon." | Decisions 5, 9 | Other buttons unchanged | — | tests |
| `lib/features/discover/presentation/discover_screen.dart`, `lib/features/connections/presentation/connections_screen.dart` | modified | Yes | Message → "Chat is coming soon." | Decision 5 | Other actions unchanged | — | discover_connect_test |
| `lib/features/connections/presentation/connect_sheet.dart`, `bloc/connect_request_cubit.dart` | modified | Yes | Messages for the 3 new reasons + network / unexpected; cubit reports every failure | Decision 8; acceptance 5 | Existing messages unchanged | — | tests |
| `lib/l10n/app_en.arb` + 2 generated | modified | Yes | 6 new strings; `requestedLabel` → "Pending" (plan section 7); profile-incomplete text → "Finish setting up your profile to connect." | Plan wording | Other strings unchanged | — | gen-l10n |
| `lib/features/discover/bloc/discover_cubit.dart` | modified (fix 1) | Yes (in-scope failure fix) | `refresh()` also re-subscribes the viewer's connections | Stale Pending on list cards | People loading, filters, errors unchanged | One extra small read on refresh | discover_connect_test |
| Tests: `test/data/supabase/supabase_connection_repository_test.dart` (added), `test/features/discover_connect_test.dart` | added / modified | Yes | Row + error mapping; Pending label; Message snackbar; receiver not active; connection count | Cover the change | — | — | `flutter test` |
| Docs: `DATABASE_AND_CACHE`, `API_REFERENCE`, `ARCHITECTURE`, `FILE_CATALOG`, `KNOWN_ISSUES`; phase / state / index | modified | Yes | PHASE_008 facts and limitations | Required docs | — | — | `validate_phase_structure.sh` |

Pre-existing uncommitted changes at the start: PHASE_008 phase docs only.

## Execute Technical Checks

- Changed-file evidence reviewed after changes: file list above (all new or edited in this phase)
- Git status/diff rerun reason: baseline at start only
- Patch/whitespace check result, when run: Not run
- Relevant Dart formatting: `dart format lib test` — clean
- Scoped or project analysis commands: `flutter analyze` (shared failures enum + interface method) — No issues found (2 new unused-import warnings fixed)
- Relevant targeted tests: `flutter test` (full) — 157/157 passed (5 new; the "Requested" expectation updated to "Pending")
- Newly introduced issues found: 2 unused imports; 1 test expecting the old "Requested" label
- Newly introduced issues fixed: both imports removed; test updated to the plan's "Pending"
- Pre-existing unrelated issues: None recorded
- Commands that could not run and why: migration and `connections_rls_checks.sql` not run (no Supabase CLI or project link; developer applies them); the 10-per-24-hours limit is not exercised by the SQL script (needs 11 active profiles) — covered by the function and the manual test; app not launched; iOS not built (Windows)

## Manual Testing

- Ready for developer manual testing: Yes (2026-11-26). First apply `supabase/migrations/20261128120000_connections.sql` and run `supabase/tests/connections_rls_checks.sql` (all PASS; needs two active profiles); then follow the Manual tests with two accounts.
- Developer manual-test confirmation: Not provided
- Manual-test notes requested by developer: None
- Failed case 1 (2026-11-26, developer): after the teacher accepted, the student's **Teachers list card still showed Pending**, while the profile and other screens showed Connected.
  - Cause: the Teachers tab stays alive (indexed shell); its `DiscoverCubit` loaded the connections once, and without Realtime the repository reloaded only after changes made on the same device (the accept happened on the teacher's device).
  - In scope: yes (acceptance 2). Fix inside the phase, no new files:
    - `SupabaseConnectionRepository`: every load is shared with all open streams of the same user, so opening the profile (a fresh load) also updates the list card.
    - `DiscoverCubit.refresh()` (pull-to-refresh / Try again) also re-subscribes the viewer's connections.
    - Test: `discover cubit: refresh picks up a request accepted elsewhere`.
  - Checks: `flutter analyze` — No issues found; `flutter test` — 158/158 passed.
  - Status: retested by the developer — "Tested, all working" (2026-11-26).

## Closure

- Developer manual-test confirmation: "Tested, all working" (2026-11-26), after the fix for failed case 1.
- Tested platforms: Not stated by the developer
- Tested devices: Not stated by the developer
- Failed and retested cases: 1 — Teachers list card stayed Pending after the other person accepted; fixed inside the phase (shared loads in `SupabaseConnectionRepository`, `DiscoverCubit.refresh()` reloads connections); retested OK.
- Final changed files: as in the Change Log, plus `lib/features/discover/bloc/discover_cubit.dart` and the new test from fix 1. Nothing committed.
- Known limitations: no Realtime — an open list updates after pull-to-refresh or opening the profile, not the instant the other person acts; "Message" shows "Chat is coming soon" until the Chat phase; the Notifications tab's sample requests cannot act on real requests (Notifications phase); the SQL script does not exercise the 10-per-24-hours limit (covered by the function and the manual test).
- Follow-up phases: Chat (real conversations from accepted connections; move `MockConnectionRepository` to `test/fakes/`), Feed (posts from connections first), Notifications (request / accept notifications and push).
- Reused technical evidence at closure: Yes — the checks rerun after fix 1 (`flutter analyze` clean, `flutter test` 158/158); no implementation file changed afterwards.
- Rollback guidance: see Rollback Plan (app: revert the phase changes; database: the migration's rollback section drops the functions, the block trigger and `connections`).
- Final status: CLOSED / COMPLETED
- Completion date: 2026-11-26
