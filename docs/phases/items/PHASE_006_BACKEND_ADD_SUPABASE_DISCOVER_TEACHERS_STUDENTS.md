# PHASE_006_BACKEND_ADD_SUPABASE_DISCOVER_TEACHERS_STUDENTS — Backend: Teachers / Students tabs on Supabase

## Identity

- Phase ID: PHASE_006_BACKEND_ADD_SUPABASE_DISCOVER_TEACHERS_STUDENTS
- Phase title: Teachers / Students tabs (Discover) on Supabase
- File name: PHASE_006_BACKEND_ADD_SUPABASE_DISCOVER_TEACHERS_STUDENTS.md
- Module: BACKEND
- Priority: High
- Risk level: Medium (adds 1 production class and 1 l10n state; no dependency, schema, RLS or native change in the recommended plan; touches visibility rules, which are a protected product rule)
- Current status: ACTIVE
- Current step: MANUAL_TEST
- Approval: APPROVED
- Outcome: NONE
- Version: 1.0
- Created date: 2026-11-25
- Last updated date: 2026-11-25
- Started date: 2026-11-25
- Completed date: Not completed
- Developer owner: Developer (owner) — VERIFIED (PHASE_001 decision)
- Dependency phases: PHASE_004_BACKEND_ADD_SUPABASE_AUTH_PROFILES (closed), PHASE_005_BACKEND_ADD_STORAGE_PHOTOS_CERTIFICATES (closed)

## Requirement

- Original developer request: "Create Discover phase" (next phase in the suggested order: discover → safety → connections → chat → feed → notifications).
- Business objective: Students find real, approved teachers and teachers find real students who are looking for a teacher (plan sections 6 flow 1, 7 and 8).
- Expected outcome: The Teachers tab (student viewer) and Students tab (teacher viewer), their search, filters and sort, and the people part of the search screen show real Supabase profiles instead of mock profiles.
- Acceptance criteria:
  1. A student sees only teachers with `is_visible = true` (verified **and** strength ≥ 80 %, computed server-side by `private.profile_strength`), never themselves.
  2. A teacher sees only students with `is_visible = true` (looking for a teacher **and** strength ≥ 60 %), never themselves, and never a student photo.
  3. Existing search, filters, filter-sheet counts and sort (`TeacherFilter`, `StudentFilter`, `DiscoverSort`) work unchanged on the real list.
  4. Tapping a person opens the real public profile (already on Supabase through `ProfileRepository`).
  5. A load failure (offline, server error) shows an error state with "Try again" instead of an endless skeleton; pull-to-refresh reloads the list.
  6. Changing your own profile so that you become (in)visible is reflected for other users on their next load or refresh.

## Analysis

- Current behavior (VERIFIED): `lib/main.dart:93` wires `MockDiscoverRepository(sampleProfiles, safety)`. Auth and profiles are real Supabase (PHASE_004), so a signed-in real user sees only the seeded mock people; their real UUID matches no mock data. `DiscoverCubit` and `SearchCubit` ignore stream errors (`onError: (Object _) {}`), so a failed load would leave the skeleton forever.
- Expected behavior: see acceptance criteria.
- Root cause or implementation gap: No Supabase implementation of `DiscoverRepository` exists; the cubits have no error/refresh path because the mock never fails.
- End-to-end flow (traced, VERIFIED):
  `DiscoverScreen` (`lib/features/discover/presentation/discover_screen.dart`) → `DiscoverCubit` (`watchTeachers` / `watchStudents`, then `TeacherFilter.apply` / `StudentFilter.apply` in pure Dart) → `DiscoverRepository` (`lib/data/repositories/discover_repository.dart`) → **new** `SupabaseDiscoverRepository` → `public.profiles` + `teacher_details` / `student_details` (`select '*, teacher_details(*), student_details(*)'`, `role = …`, `is_visible = true`, `id <> viewer`) → RLS "profiles: signed-in users read" (`using (true)`, migration `20261123120000_profiles.sql`).
  `SearchResultsScreen` → `SearchCubit` → same `DiscoverRepository` for people (posts stay on the mock `FeedRepository`).
  Person tap → `/profile/:id` → `PublicProfileCubit` → `SupabaseProfileRepository.watchProfile` (already real).
- Relevant files: `lib/data/repositories/discover_repository.dart`, `lib/data/repositories/mock/mock_discover_repository.dart`, `lib/data/repositories/supabase/supabase_profile_repository.dart`, `lib/data/repositories/supabase/profile_row_mapper.dart`, `lib/data/repositories/supabase/supabase_failure_mapper.dart`, `lib/core/logic/discover_visibility_rules.dart`, `lib/features/discover/bloc/discover_cubit.dart`, `discover_state.dart`, `search_cubit.dart`, `lib/features/discover/presentation/discover_screen.dart`, `search_results_screen.dart`, `lib/main.dart`, `supabase/migrations/20261123120000_profiles.sql`.
- Existing reusable components (VERIFIED): `ProfileRowMapper` (row → `Profile`, `select` constant), `SupabaseFailureMapper` (errors → `*Failure`), avatar public-URL logic in `SupabaseProfileRepository._avatarUrl`, `TeacherFilter` / `StudentFilter` / `DiscoverSort` (search, filters, sort — unchanged), `EmptyStateView` (error state with action), `TeacherCardSkeleton`, l10n `retryAction` ("Try again"), `NetworkFailure` / `UnexpectedFailure`.
- Existing API details: Supabase PostgREST through `supabase_flutter` (no Dio, no Edge Function).
- Existing models: `Profile`, `TeacherDetails`, `StudentDetails` — unchanged. Student photo is removed by clearing `photoPath` / `photoUrl` (the mock does the same by rebuilding the `Profile`).
- Existing state-management flow: Cubits listen to repository streams; `DiscoverStatus { loading, ready }` has no error value.
- Existing navigation flow: unchanged (tab → list → `/profile/:id`; search icon → search screen).
- Android / iOS behavior: no platform-specific code; `INTERNET` permission already added in PHASE_004.
- Lifecycle behavior: stream subscriptions are cancelled in `close()` (kept); refresh cancels and re-subscribes.
- Permission behavior: none.
- Database and cache behavior: no local cache; list loaded on tab open and on refresh. v1 target is 150+ teachers (plan section 2), so one query with a row cap (proposed 500, newest first) plus client-side filtering is enough; server-side filtering/paging is a later optimisation.
- Supabase tables, columns and migrations: uses existing `profiles.role`, `is_visible`, `created_at` and the detail tables. **No new migration** in the recommended plan (an index on `(role, is_visible)` is optional and not needed at this size).
- Row Level Security and Storage policies: unchanged. RLS lets any signed-in user read any profile (needed for public profiles, feed authors and connections). Lists filter `is_visible = true` in the query; `is_visible` is server-computed and the app cannot write it (no column grant). See decision 4 for tightening.
- Realtime, Edge Functions and push: none (see decision 2).
- Both roles and signed-out behavior: student viewer → teachers; teacher viewer → students; tabs are only reachable when signed in (router guard, PHASE_004). Signed-out users cannot read `profiles` (no `anon` grant).
- Security considerations: no secrets; app never writes `role`, `is_verified`, `is_visible`; blocked-user filtering cannot be enforced yet because the `blocks` table does not exist (decision 1).

## Missing Information / Decisions Needed

**Answered 2026-11-25** — developer: "Accept recommendations". All 6 decisions are DECIDED as the **(Recommended)** option:

- 1 → A: Discover now; blocks filtering is a documented temporary gap, added to `SupabaseDiscoverRepository` by the Safety phase (recorded in `docs/KNOWN_ISSUES.md` during Execute).
- 2 → A: load once per subscription; pull-to-refresh and "Try again" re-subscribe; no Realtime; `DiscoverRepository` doc comment updated, signatures unchanged.
- 3 → 500-row cap, newest first, client-side filters/sort.
- 4 → RLS unchanged; lists filter `is_visible = true` in the query.
- 5 → strings `discoverLoadFailedTitle` "Couldn’t load people" / `discoverLoadFailedMessage` "Check your connection and try again." + existing `retryAction`; error state reuses `EmptyStateView` (accepted design deviation).
- 6 → Connect / Message on real profiles are excluded from this phase's manual test (mock until the Connections phase).

Original options:

1. **Blocked users.** The `DiscoverRepository` contract says "not blocked in either direction", but there is no `blocks` table yet (Safety is the next phase). Blocking a real user now writes only to `MockSafetyRepository`.
   - A **(Recommended)**: Do Discover now and record a temporary, documented gap. The Supabase implementation filters blocks once the Safety phase adds the table (that phase updates this repository). Acceptable because there are no real users before launch.
   - B: Pull the `blocks` table + RLS + block/unblock into this phase (adds a migration and part of `SafetyRepository`; larger, High risk).
   - C: Do the Safety phase first, then Discover.
2. **"Emits again on changes".** Without Realtime the stream cannot see other users' edits live.
   - A **(Recommended)**: Load once per subscription; pull-to-refresh and "Try again" re-subscribe. Interface unchanged (contract wording updated to "emits the current list; re-subscribe to reload"). No Realtime cost on the free plan.
   - B: Supabase Realtime on `profiles` (needs replication enabled on the remote project and approval; more load).
3. **Row cap.** **(Recommended)** 500 rows, newest first, client-side filters/sort as today. Alternative: server-side filters now.
4. **RLS for lists.** **(Recommended)** keep RLS unchanged; filter `is_visible` in the query (public profile, feed authors and connections need to read other profiles). Tightening RLS for hidden profiles belongs to the moderation work (`profiles.is_hidden` does not exist yet).
5. **Error UI copy.** **(Recommended)** add 2 strings: `discoverLoadFailedTitle` "Couldn’t load people" and `discoverLoadFailedMessage` "Check your connection and try again." with the existing `retryAction`. No artboard exists for this state → small design deviation reusing `EmptyStateView`.
6. **Mock connections.** Connections/chat stay mock until their phases, so **Connect / Message on a real profile is not part of this phase's manual test**. Confirm this is acceptable. **(Recommended)** yes.

## Scope

- In scope (decided 2026-11-25):
  - New `SupabaseDiscoverRepository implements DiscoverRepository` (query, viewer exclusion, role + `is_visible` filter, row cap, avatar URL for teachers, student photo removed, errors mapped to `*Failure`).
  - `lib/main.dart`: wire `SupabaseDiscoverRepository(client)` instead of `MockDiscoverRepository` (mock class kept for tests).
  - `DiscoverStatus.error`; `DiscoverCubit` and `SearchCubit` handle stream errors and expose `refresh()` (cancel + re-subscribe).
  - `DiscoverScreen`: error state (`EmptyStateView` + "Try again") and `RefreshIndicator`; `SearchResultsScreen` people section shows nothing on error (unchanged look).
  - 2 l10n strings (ARB + regenerated localizations).
  - Contract comment update in `discover_repository.dart` (wording only; no signature change).
  - Tests: `DiscoverCubit` error + refresh with a fake repository; `SupabaseDiscoverRepository` row handling where testable without network (student photo removed, self excluded) — exact test seam confirmed during Execute without adding packages.
  - Docs: `docs/FILE_CATALOG.md`, affected architecture/backend docs, `docs/KNOWN_ISSUES.md` (blocks gap if decision 1A).
- Explicitly out of scope: blocks/reports (Safety phase), connections, chat, feed/posts in search, notifications, Realtime, server-side filtering/paging, RLS changes, `is_hidden`, admin approval tooling, any migration, any dependency or native change.
- Files expected to change: `lib/main.dart`, `lib/data/repositories/discover_repository.dart` (comment only), `lib/features/discover/bloc/discover_cubit.dart`, `lib/features/discover/bloc/discover_state.dart`, `lib/features/discover/bloc/search_cubit.dart`, `lib/features/discover/presentation/discover_screen.dart`, `lib/l10n/app_en.arb`, `lib/l10n/app_localizations.dart`, `lib/l10n/app_localizations_en.dart`, `test/features/discover_connect_test.dart` or `test/features/cubits_test.dart`, docs listed above.
- Files that must not change: product plans, migrations, RLS/Storage SQL, `ProfileRepository` and other repository interfaces' signatures, `TeacherFilter` / `StudentFilter` behaviour, `DiscoverVisibilityRules`, models, native Android/iOS files, `pubspec.yaml`.
- Proposed new files (approval required):
  - `lib/data/repositories/supabase/supabase_discover_repository.dart` — reason: no Supabase implementation exists; `SupabaseProfileRepository` implements a different interface (small-interface rule).
  - `test/data/supabase/supabase_discover_repository_test.dart` — only if a test seam exists without new packages.
- Proposed new classes: `SupabaseDiscoverRepository` (constructor: `SupabaseClient`, `ProfileRowMapper`, `SupabaseFailureMapper`; method contract = `DiscoverRepository`, throws only `*Failure`).
- Dependency changes: None.
- API contract changes: `DiscoverRepository` doc comment only (decision 2A).
- Native changes: None.
- Supabase migration/RLS/function changes: None (recommended plan).
- Approval requirements: new production class/file, repository-wiring change in `main.dart`, visibility-rule-sensitive query, new l10n strings, design deviation (error state).

## Readiness Checklist

- [x] Requirement is clear
- [x] Expected behavior is clear
- [x] Existing flow is traced
- [x] API is verified
- [x] Request contract is verified
- [x] Response contract is verified
- [x] Supabase tables, RLS and Storage policies are defined
- [x] Security, 18+ gate and moderation rules are unaffected or approved (decision 1A accepted — blocks gap until Safety phase)
- [x] Required UI/design is available (decision 5 — error-state deviation accepted)
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

- Visible list relies on the server-computed `is_visible`; if the remote project's migration differs from the repo, lists may be empty. Mitigation: manual test with one verified ≥ 80 % teacher and one looking ≥ 60 % student. Setting `is_verified = true` is an admin action in the Supabase dashboard (the app never writes it).
- Blocks not filtered until the Safety phase (decision 1A).
- Real profiles mixed with mock connections: Connect / Message on real people do not work end-to-end until the Connections phase.

## Manual Tests (planned)

1. Student account → Teachers tab lists only the verified ≥ 80 % teacher(s); an unverified or < 80 % teacher is absent.
2. Teacher account → Students tab lists only looking ≥ 60 % students, with no photo; turning "Looking for a teacher" off hides the student after refresh.
3. Search, each filter and sort still work on real data; filter-sheet counts match.
4. Tap a person → their real public profile opens.
5. Airplane mode → open tab → error state → reconnect → "Try again" loads the list. Pull-to-refresh works.
6. Android and iOS.

## Rollback Plan

Revert the `lib/main.dart` wiring to `MockDiscoverRepository(sampleProfiles, safety)` (one line) and remove the new repository file; cubit error/refresh handling is backward-compatible with the mock. No database change to roll back.

## Implementation

- Approved implementation plan: Approved 2026-11-25 (developer: "Approve phase"). Covers the Scope section with decisions 1–6: new `SupabaseDiscoverRepository` (`lib/data/repositories/supabase/supabase_discover_repository.dart`) and optional `test/data/supabase/supabase_discover_repository_test.dart` (only without new packages); `lib/main.dart` wiring; `DiscoverStatus.error`; `refresh()` and error handling in `DiscoverCubit` / `SearchCubit`; error state + `RefreshIndicator` on `DiscoverScreen`; 2 l10n strings; `DiscoverRepository` doc-comment update (no signature change); tests; docs (`FILE_CATALOG`, `KNOWN_ISSUES` blocks gap). Not approved: migrations, RLS, dependencies, native changes, Realtime, interface signature changes.
- Implementation log: 2026-11-25 — `SupabaseDiscoverRepository` added and wired; `DiscoverStatus.error` + `DiscoverCubit.refresh()`; error state and pull-to-refresh (list, empty and error states) on `DiscoverScreen`; 2 strings; contract comment; 4 tests; docs. `SearchCubit` needed no change: it already ignores stream errors (people section stays empty, unchanged look) and every search-screen open subscribes afresh — smaller than the planned `refresh()` there.
- Exact changed files: see Change Log
- Purpose of every changed file: see Change Log
- Existing components reused: listed in Analysis
- New approved components: `SupabaseDiscoverRepository`; test file `test/data/supabase/supabase_discover_repository_test.dart` (seam: `@visibleForTesting toProfiles` with an offline `SupabaseClient`, no new packages)
- Out-of-scope findings:
  - `profiles` has no `is_hidden` column although plan section 12 lists admin-hidden profiles (moderation work).
  - Profiles RLS allows any signed-in user to read any profile by id, including unverified/hidden ones (by design for now; revisit with moderation).
- Unexpected risks: None

## Change Log

| File path | Change type | Approved in phase | What changed | Why it changed | Existing behavior preserved | Possible side effects | File-level checks |
|---|---|---|---|---|---|---|---|
| `lib/data/repositories/supabase/supabase_discover_repository.dart` | added | Yes | `DiscoverRepository` on `profiles` + details: `role`, `is_visible = true`, `neq id viewer`, newest first, limit 500; `toProfiles` drops viewer, removes student photos, fills teacher avatar URLs; errors → `*Failure` | Discover on Supabase | Same contract as the mock; RLS untouched | Empty lists if the remote migration differs; blocks not filtered (decision 1A) | analyze; `supabase_discover_repository_test.dart` |
| `lib/main.dart` | modified | Yes | `SupabaseDiscoverRepository(client)` replaces `MockDiscoverRepository`; doc comment lists discover as real | Wiring | Other repositories unchanged; `sampleProfiles` / `safety` still feed the other mocks | Discover now needs network | analyze |
| `lib/data/repositories/discover_repository.dart` | modified | Yes (comment only) | Contract wording: emit once or on changes, re-subscribe to reload, viewer excluded, blocks from Safety phase | Decision 2A | No signature change | None | analyze |
| `lib/features/discover/bloc/discover_state.dart` | modified | Yes | `DiscoverStatus.error` | Error state | `loading` / `ready` unchanged | Exhaustive switches on the enum (none found) | analyze |
| `lib/features/discover/bloc/discover_cubit.dart` | modified | Yes | `_listenPeople()` (error → `DiscoverStatus.error`), `refresh()` keeps search/filters | No endless skeleton; pull-to-refresh | Filtering, counts, connections stream, `close()` cleanup unchanged | None | analyze; discover cubit tests |
| `lib/features/discover/presentation/discover_screen.dart` | modified | Yes | Error state (`EmptyStateView`, people icon, "Try again"); `RefreshIndicator` on the list; `_scrollable` wraps empty and error states so pull-to-refresh works there | Decision 5 (accepted design deviation) | Skeleton, list, cards, empty-state copy and layout unchanged | Slight scroll physics change (always scrollable) | analyze; discover screen tests |
| `lib/l10n/app_en.arb` | modified | Yes | `discoverLoadFailedTitle`, `discoverLoadFailedMessage` | Decision 5 | Existing strings unchanged | None | `flutter gen-l10n` |
| `lib/l10n/app_localizations.dart`, `lib/l10n/app_localizations_en.dart` | generated | Yes | 2 getters | Regenerated | — | None | analyze |
| `test/data/supabase/supabase_discover_repository_test.dart` | added | Yes | Viewer dropped; teacher avatar URL; student photo removed | Repository rules | — | None | `flutter test` |
| `test/features/discover_connect_test.dart` | modified | Yes | Cubit error then `refresh()` reloads, filters kept (`_FlakyDiscover` test fake) | Error / refresh path | Existing tests unchanged | None | `flutter test` |
| `docs/API_REFERENCE.md`, `docs/ARCHITECTURE.md`, `docs/DATABASE_AND_CACHE.md`, `docs/KNOWN_ISSUES.md`, `docs/FILE_CATALOG.md` | modified | Yes | PHASE_006 facts, blocks gap, `is_hidden` finding, catalog rows | Required docs | — | None | — |
| `docs/phases/items/PHASE_006_…md`, `docs/phases/PHASE_INDEX.md`, `docs/phases/state/PHASE_STATE.md` | modified | Yes | Phase lifecycle records | Phase workflow | — | None | `validate_phase_structure.sh` |

## Execute Technical Checks

- Changed-file evidence reviewed after changes: `git status --short` after implementation — only the files in the Change Log
- Git status/diff rerun reason: baseline at start (clean except PHASE_006 docs) and once after implementation
- Patch/whitespace check result, when run: Not run
- Relevant Dart formatting: `dart format` on changed Dart files — 2 files reformatted, then clean
- Scoped or project analysis commands: `flutter analyze` (project-wide; main.dart wiring and an enum value change) — No issues found
- Relevant targeted tests: `flutter test` (full; shared enum and wiring) — 151/151 passed (4 new)
- Newly introduced issues found: None recorded
- Newly introduced issues fixed: None recorded
- Pre-existing unrelated issues: None recorded
- Commands that could not run and why: app not launched (not requested); iOS not built (Windows)

## Manual Testing

- Ready for developer manual testing: Yes — see Manual Tests (planned). Needs on the remote project: one teacher with `is_verified = true` set in the dashboard and ≥ 80 % strength, and one student with "Looking for a teacher" on and ≥ 60 %.
- Developer manual-test confirmation: Not provided
- Manual-test notes requested by developer: None

## Closure

- Developer manual-test confirmation: Not provided
- Tested platforms: Not provided
- Tested devices: Not provided
- Failed and retested cases: None recorded
- Known limitations: None recorded
- Follow-up phases: Safety (blocks/reports), Connections
- Reused Execute technical evidence at closure: Not evaluated
- Rollback guidance: see Rollback Plan
- Final status: Not closed
- Completion date: Not completed
