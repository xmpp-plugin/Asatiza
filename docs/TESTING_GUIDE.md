# Testing Guide

## Verified Tests

- 2026-11-19 (`PHASE_002`): 57 tests, all passing — logic and formatter units, mock data and repositories, all cubits, screen flows (sign-up both roles, log-in, password reset, setup, post detail/report/block, create post), app/router/theme. `test/helpers/test_app.dart` builds the app with fresh mocks and loads the real fonts. Widget tests that await a stream cancel must use `tester.runAsync` (cancel futures complete in the real zone). No golden tests (developer decision). VERIFIED

- 2026-11-23 (`PHASE_003`): 101 tests (44 new: discover/connect, chat/notifications, profile/settings — logic, mocks, cubits, screen flows for both roles). `TestApp.startSignedIn` signs in by profile id (independent of the mock login emails). Both `MockAccounts` emails are the same address (developer decision), so logging in opens Qari Ahmed; the email-based tests expect that. 101/101 passing.

- 2026-11-19 (`PHASE_001`): `test/app_test.dart` (boot, tabs, light/dark), `test/core/router/app_router_test.dart` (navigation, system back), `test/core/theme/app_theme_test.dart` (design tokens). 12 tests, all passing. The global `appRouter` keeps its location between tests, so each test starts with `appRouter.go(AppRoutes.home)`. VERIFIED
- No `integration_test/`. VERIFIED
- Flutter lints configured through `analysis_options.yaml`. VERIFIED

## Standard Validation

Use only supported commands:

```bash
dart format <changed-dart-files>
flutter analyze
flutter test
```

When the repo has them (later phases):

```bash
dart run build_runner build --delete-conflicting-outputs   # only if code generation is approved
supabase db lint                                            # local project only
supabase migration list                                     # local project only
```

Run targeted tests when the full suite is not relevant. Reuse recorded passing results when relevant implementation files have not changed since those checks ran. Record every command and actual result compactly.

## Validation Rules

- Format only changed Dart files.
- Run `git diff --check` only when patch/whitespace integrity is relevant.
- Prefer targeted analysis/tests for small scoped changes.
- Do not rerun passed checks after documentation-only updates or while waiting for manual testing.
- Separate pre-existing issues from newly introduced issues.
- Never claim full analyzer/test success if the command did not pass.
- Do not fix unrelated analyzer warnings during phase technical checks.

## Test Folders (DECIDED)

- `test/` mirrors `lib/`.
- **Required with every new class (SOLID support):**
  - Logic classes: plain unit tests covering every rule and boundary (e.g. 59% / 60% / 80% thresholds).
  - Blocs/cubits: unit tests with fake or mocked repositories/services covering loading, success and each failure.
  - Repository implementations: tests against a mocked `SupabaseClient` / `Dio` proving exceptions map to the documented `*Failure` types.
  - Fakes implement the real interface and follow the same method contract.
- Test packages `bloc_test` and `mocktail` (dev dependencies): require approval when first added.
- `integration_test/` for end-to-end auth, post, connect and chat flows.

## RLS Test Accounts

Two teachers and two students (labels only; never record passwords): Teacher A, Teacher B, Student A, Student B. Every RLS change is checked for own-row, other-row, blocked-user and signed-out access.

## Manual Test Matrix (DECIDED)

Each feature is checked on a real Android device (and iOS when in scope), for both roles, signed-out and signed-in. Manual testing is developer-owned; Claude provides manual test cases only when asked, when a risky/non-obvious scenario needs highlighting, or when project requirements require documented cases.

## Prohibited Without Approval

```bash
flutter clean
pod update
pod repo update
flutter pub upgrade
dart fix --apply
supabase db reset        # never against the linked remote project
supabase db push / functions deploy
```
