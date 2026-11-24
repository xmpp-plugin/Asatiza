# PHASE_004_BACKEND_ADD_SUPABASE_AUTH_PROFILES — Backend: Supabase Setup, Auth And Profiles

## Identity

- Phase ID: PHASE_004_BACKEND_ADD_SUPABASE_AUTH_PROFILES
- Phase title: Backend foundation — Supabase setup, auth and profiles
- File name: PHASE_004_BACKEND_ADD_SUPABASE_AUTH_PROFILES.md
- Module: BACKEND
- Priority: High
- Risk level: High (new production dependency, authentication, database schema, RLS, an account-deletion function, 2 interface changes, a native Android change)
- Current status: CLOSED
- Current step: CLOSURE
- Approval: APPROVED
- Outcome: COMPLETED
- Version: 1.0
- Created date: 2026-11-23 (first recorded as 2026-11-24 by mistake; corrected)
- Last updated date: 2026-11-24 (closed)
- Started date: 2026-11-23
- Completed date: 2026-11-24
- Developer owner: Repository owner (developer) — owner and manual tester
- Dependency phases: PHASE_003_UI_ADD_FULL_APP_DESIGN_MOCK_DATA_PART_TWO (closed)

## Requirement

- Original developer request: "CREATE PHASE: Backend foundation — Supabase setup, auth and profiles" (2026-11-23). Follow-up 2026-11-23: "continue and update it with your recommendations safely" — the recommended answers below are recorded as the plan; they become binding only with `APPROVE PHASE`.
- Business objective: Real accounts — sign-up with a 6-digit email code, log in, forgot password, change password, account deletion — and real profiles (setup, My profile, Edit profile) stored in Supabase Postgres behind Row Level Security, through the existing repository interfaces (plan sections 4, 7, 11, 12, 14, 16). DECIDED
- Expected outcome: With Supabase settings supplied at run time, `AuthRepository` and `ProfileRepository` use Supabase; without them the app keeps running fully on the mock repositories (tests and demos unchanged). The database schema for `profiles`, `teacher_details`, `student_details` exists as migrations in `supabase/migrations/` with RLS.
- Acceptance criteria (recommended answers applied; confirmed at approval):
  1. `supabase_flutter` added (exact version chosen at execution, approval); no other new package. Dio is deferred to the first phase that calls an Edge Function (none here).
  2. Supabase URL and anon key come only from `--dart-define` / `--dart-define-from-file`; never in source, docs or chat. An `env/dev.example.json` shows the two key names with empty values; real env files are git-ignored.
  3. Sign up (full name, email, password, role, 18+ consent) → Supabase sends a 6-digit code → code screen verifies (`verifyOTP` type `signup`) → profile row exists → role setup → Home. Resend works after 60 s.
  4. Log in with email + password → Home, also when setup was skipped (decision 6; the strength card leads to Edit profile). Log in with an unconfirmed email → a fresh code is sent and the code screen opens (plan section 4).
  5. Forgot password: email → 6-digit recovery code → new password → signed in.
  6. Change password (Settings) and Delete account (Settings) work against Supabase; deletion calls `rpc('delete_my_account')` (decision 4) and removes the auth user and every row that belongs to them.
  7. In backend mode the session survives an app restart (Splash restores it, decision 8). Mock mode keeps "every launch starts signed out".
  8. Teacher / student setup, My profile and Edit profile read and write the real `profiles` + detail rows; `completion_pct` and `is_visible` are filled by a Postgres trigger that mirrors `ProfileStrengthCalculator` (decision 5). The app never writes `role`, `is_verified`, `is_visible` (enforced by column privileges, not only by the app).
  9. RLS: a user can read profiles only when signed in, and insert / update only their own rows; `role` is set once from sign-up metadata by a trigger; `is_verified` and `is_visible` are admin-only.
  10. Supabase errors map to the existing `*Failure` types (wrong password, email taken, invalid / expired code, weak password, network) and show the existing messages.
  11. `flutter analyze` clean; mapping and error-mapping logic unit-tested; all existing tests stay green in mock mode.
  12. Nothing is deployed to the remote Supabase project unless the developer explicitly asks; the developer pastes the migrations into the Supabase SQL editor (decision 7).

## Analysis

- Current behavior (VERIFIED, commit `28c2a7c`, branch `PHASE_004_BACKEND_FOUNDATION`):
  - All 10 repositories are in-memory mocks created in `lib/main.dart`; every launch starts signed out; any 8-character password signs in; any 6 digits pass the code step. Both `MockAccounts` emails are the same address by developer decision (log-in opens Qari Ahmed).
  - No `supabase/` folder, no `lib/data/repositories/supabase/`, no `lib/core/network/`, no env files; `pubspec.yaml` has no Supabase, Firebase or Dio packages.
  - `android/app/src/main/AndroidManifest.xml` has **no `INTERNET` permission** (only the debug and profile manifests have it) — a release build could not reach Supabase. VERIFIED
  - `SessionCubit` is signed out at start; `SplashScreen` waits 1.2 s then goes to Home (the router sends signed-out users to Welcome). `splash_screen.dart` also holds the developer's committed empty `Row()` (left as is by request).
- Root cause / gap: no backend exists; the app's data contracts (`AuthRepository`, `ProfileRepository`, models, `ValidationReason`) were designed for it but have no Supabase implementation, schema or RLS.
- End-to-end flow (target): screens → existing cubits (`SignUpCubit`, `OtpCubit`, `LoginCubit`, `PasswordResetCubit`, setup cubits, `EditProfileCubit`, `ChangePasswordCubit`, `DeleteAccountCubit`, `SessionCubit`) → `AuthRepository` / `ProfileRepository` interfaces → `SupabaseAuthRepository` / `SupabaseProfileRepository` (receive `SupabaseClient` by constructor) → Supabase Auth + tables `profiles`, `teacher_details`, `student_details` → RLS policies, column privileges, trigger `handle_new_user`, function `delete_my_account()`.
- Supabase contract (plan section 12, adapted to the existing models):
  - `profiles`: `id uuid pk → auth.users(id) on delete cascade`, `role text check (student|teacher)`, `full_name`, `headline`, `photo_path`, `gender`, `country`, `timezone`, `languages text[]`, `bio`, `completion_pct int`, `is_visible bool`, `is_verified bool default false`, `created_at`, `updated_at`. Email stays in `auth.users` (not copied).
  - `teacher_details`: `profile_id pk → profiles on delete cascade`, `subjects text[]`, `experience_years int`, `qualifications text`, `fee_amount int`, `fee_currency text default 'USD'`, `fee_unit text check (per_class|per_month)`, `availability jsonb` (`{days:[…], from_minutes, to_minutes}`), `teaches text[]`, `certificate_paths text[]`.
  - `student_details`: `profile_id pk`, `age_group`, `goals text[]`, `level`, `preferred_teacher_gender`, `looking_for_teacher bool`, `note text check (length ≤ 200)`.
  - Enum values are stored as text with `check` constraints matching the Dart enum names (snake_case in SQL, mapped in Dart).
  - Trigger on `auth.users` insert creates the `profiles` row (+ empty detail row) from `raw_user_meta_data` `full_name` and `role`; the app never inserts or updates `role`.
  - `delete_my_account()` — `security definer` SQL function, callable only by the signed-in user, deletes `auth.users` where `id = auth.uid()` (cascades to all owned rows).
- Existing reusable components: every screen, cubit, model, enum, `ValidationReason`, `PasswordRules`, `OtpRules`, `ProfileStrengthCalculator`, all mock repositories (kept for mock mode and tests).
- Not in this phase (later phases): Storage buckets and `MediaRepository` (photos and certificates stay sample paths — avatars still show initials), feed, discover, connections, chat, notifications, safety tables, Edge Functions, FCM, Crashlytics, Dio, Brevo SMTP setup (dashboard), admin views.

### Design Against The SOLID Checklist

- S: row ↔ model mapping in `ProfileRowMapper` (pure); Supabase / Postgrest exception → `Failure` in `SupabaseFailureMapper` (pure); repositories only call Supabase and map.
- O: Supabase implementations are added beside the mocks; screens and cubits do not change except the approved session / log-in additions.
- L: both implementations honour the documented contracts (same `Failure` types, same nullability).
- I: no new interface; 2 small additions on `AuthRepository`.
- D: `SupabaseClient` is created only in `lib/main.dart` (the only `Supabase.instance` read) and passed by constructor.

## Scope

- In scope: dependency, run-time config, Supabase Auth + Profile repositories, session restore, unconfirmed-email log-in, change password, account deletion, schema + RLS + trigger + function migrations, Android `INTERNET` permission, mock / backend mode switch in `lib/main.dart`, tests, docs.
- Explicitly out of scope: see "Not in this phase" above; deploying anything to the remote project without an explicit request; Supabase dashboard settings (developer does them, with written steps).
- Files expected to change (existing):
  - `pubspec.yaml`, `pubspec.lock` (add `supabase_flutter`). **Dependency — approval.**
  - `.gitignore` (`env/*.json`, keep `env/*.example.json`).
  - `android/app/src/main/AndroidManifest.xml` (`INTERNET` permission). **Native — approval.**
  - `lib/main.dart` (mode switch, `Supabase.initialize`, register Supabase Auth + Profile repositories).
  - `lib/data/repositories/auth_repository.dart` + `mock/mock_auth_repository.dart`: add `restoreSession()` (signed-in profile or null). **Interface change — approval.**
  - `lib/core/errors/failures.dart`: `ValidationReason.emailNotConfirmed`, `codeExpired`, `weakPassword`; new `NetworkFailure`. **Shared core — approval.**
  - `lib/core/session/session_cubit.dart` (+ state): `restore()` on start; `lib/features/onboarding/presentation/splash_screen.dart`: wait for restore (developer's `Row()` kept).
  - `lib/features/auth/bloc/login_cubit.dart` (+ state) and `log_in_screen.dart`: unconfirmed email → resend code → code screen.
  - Auth / settings screens only where a new `ValidationReason` needs its message; `lib/l10n/app_en.arb` (+ generated).
  - Docs: `API_REFERENCE`, `DATABASE_AND_CACHE`, `ARCHITECTURE`, `DIRECTORY_STRUCTURE`, `TESTING_GUIDE`, `KNOWN_ISSUES`, `PROJECT_OVERVIEW`, `ERROR_HANDLING`, `FILE_CATALOG`.
- Files that must not change: `docs/product/*`, `ios/**` (no native change needed — UNVERIFIED until a device run), theme, screens' layouts, other repository interfaces, `CLAUDE.md`, skill files.
- Proposed new files (approval requested):

  | Group | Count | Paths / classes |
  |---|---|---|
  | Config | 2 | `lib/core/config/app_config.dart` (`AppConfig`: URL, anon key from `String.fromEnvironment`, `hasBackend`); `env/dev.example.json` (key names only) |
  | Supabase repositories | 4 | `lib/data/repositories/supabase/supabase_auth_repository.dart`, `supabase_profile_repository.dart`, `profile_row_mapper.dart` (`ProfileRowMapper`), `supabase_failure_mapper.dart` (`SupabaseFailureMapper`) |
  | Migrations | 2 | `supabase/migrations/<timestamp>_profiles.sql` (tables, checks, trigger, RLS, column privileges, `updated_at`), `supabase/migrations/<timestamp>_delete_my_account.sql` |
  | RLS checks | 1 | `supabase/tests/profiles_rls_checks.sql` (manual SQL-editor checks: own row update OK, other row update denied, `role` / `is_verified` update denied, anon read denied) |
  | Tests | 3 | `test/data/supabase/profile_row_mapper_test.dart`, `supabase_failure_mapper_test.dart`, `test/core/config/app_config_test.dart` |

  Total ≈ 12 new files, ≈ 15 modified.
- Approval requirements: High risk — explicit approval for the dependency, the interface change, the new `Failure` / reasons, the migrations and RLS, the deletion function, the Android permission, and the answers below.

## Decisions (recommended answers, recorded 2026-11-23)

The developer asked to apply the recommendations. Each one is the safest option that needs no temporary code and no remote action by me. All stay open to change until `APPROVE PHASE`.

1. **Run modes — (a) two modes.** No Supabase settings → the whole app runs on mocks as today (default for tests and demos). Settings present (`--dart-define-from-file=env/dev.json`) → `SupabaseAuthRepository` + `SupabaseProfileRepository`; feed, discover, connections, chat, notifications and safety stay mock. Known limitation in backend mode: actions that need the real user inside a mock store (connect, chat, post, block) may fail or show empty states until their phases. No bridge code. DECIDED (pending approval)
2. **Supabase project and dashboard settings — developer prerequisite before manual testing, not before execution.** Code, migrations and tests can be written without a project. Before manual testing the developer creates the project (or uses the existing one) and sets, with written steps from me: email confirmation ON; email OTP length 6; "Confirm signup" and "Reset password" templates use `{{ .Token }}`; minimum password length 8. URL and anon key go only into the developer's git-ignored `env/dev.json`; never into chat, code or docs. UNVERIFIED — whether the project exists; developer confirms at approval.
3. **Email sending — built-in Supabase email now.** Team addresses only, low hourly limit (recorded in Risks). Brevo SMTP is set up in a later phase before any real users. DECIDED (pending approval)
4. **Account deletion — SQL function.** `delete_my_account()` (`security definer`, `set search_path = ''`, `execute` granted to `authenticated` only, revoked from `public` / `anon`) deletes `auth.users where id = auth.uid()`; owned rows go by `on delete cascade`. Called with `rpc`. No Edge Function, no Dio. DECIDED (pending approval)
5. **Profile strength on the server — now.** `completion_pct` and `is_visible` are set by a `before insert or update` trigger on `profiles` / detail tables that mirrors `ProfileStrengthCalculator` (same items and weights; documented side by side; a unit test fixes the Dart side). The app never writes these two columns (column privileges). DECIDED (pending approval)
6. **Log-in after skipped setup — Home.** Matches the mock flow; the strength card leads to Edit profile. DECIDED (pending approval)
7. **Applying migrations — developer, Supabase SQL editor.** I write the files in `supabase/migrations/` and `supabase/tests/profiles_rls_checks.sql`; the developer pastes them in order. No Supabase CLI requirement; I never run anything against the remote project unless asked in words. DECIDED (pending approval)
8. **Stay signed in — yes, backend mode only.** `supabase_flutter` persists the session; `SessionCubit.restore()` reads it at Splash. Mock mode unchanged. DECIDED (pending approval)

## Readiness Checklist

- [x] Requirement is clear (decisions 1–8)
- [x] Expected behavior is clear
- [x] Existing flow is traced
- [x] API is verified (Supabase Auth / Postgrest methods and the schema contract are defined; the remote project's existence is UNVERIFIED and, per decision 2, is a prerequisite for manual testing, not for execution)
- [x] Request contract is verified (Supabase Auth methods listed in `API_REFERENCE.md`)
- [x] Response contract is verified (models exist; mapping proposed)
- [x] Supabase tables, RLS and Storage policies are defined (contract above + decisions 4, 5; no Storage in this phase)
- [x] Security, 18+ gate and moderation rules are unaffected or approved (age gate stays in the sign-up form; admin-only columns enforced by privileges)
- [x] Required UI/design is available (no new screens)
- [x] Existing reusable components are identified
- [x] Proposed files are identified
- [x] New files/classes are approved
- [x] Platform behavior is understood (Android `INTERNET` gap found)
- [x] Permissions are understood (`INTERNET` only)
- [x] Dependencies are available (`supabase_flutter` approved; exact version chosen at execution and recorded)
- [x] Risks are documented
- [x] Automated tests are defined
- [x] Manual tests are defined
- [x] Rollback plan is defined
- [x] Phase dependencies are completed (PHASE_003 closed)
- [x] Developer approval is recorded

## Risks

- Auth and RLS mistakes are security issues: RLS checked with the manual SQL checks; admin-only columns protected by column privileges.
- Email OTP depends on dashboard templates (`{{ .Token }}`); with the default link template the 6-digit screens cannot work.
- Built-in Supabase email is limited (team addresses, low hourly limit) — testing may hit the limit.
- Free projects pause after 7 days without activity (plan section 13).
- Mixed mode (decision 1): mock features cannot see the real user.
- Server strength trigger (decision 5) must stay in step with `ProfileStrengthCalculator`; a later change to one needs the same change in the other.
- Interface change on `AuthRepository` touches both implementations and the session start.
- `supabase_flutter` brings transitive packages (app size, iOS pods) — checked on first iOS build by the developer.

## Test Plan

- Automated: `flutter analyze`; unit tests for `ProfileRowMapper` (both roles, nulls, enum names, availability JSON), `SupabaseFailureMapper` (known Auth / Postgrest errors → `Failure`), `AppConfig` (no defines → mock mode); `SessionCubit.restore` with the mock; all existing tests green in mock mode. Supabase repositories are not unit-tested against a live server.
- SQL: `supabase/tests/profiles_rls_checks.sql` run by the developer in the SQL editor after applying migrations.
- Manual (developer, Android + iOS, backend mode with your env file): sign up student and teacher (real code email), resend, wrong code, log in, unconfirmed log-in → code screen, forgot password, setup save → rows visible in the dashboard, Edit profile save, restart → still signed in, log out, change password, delete account → user and rows gone; then run once without settings → mock mode unchanged.

## Rollback Plan

App: revert the phase commit (or restore modified files, delete new ones) and run `flutter pub get` — mock mode returns. Database: migrations are additive; on a project with no real users, drop the three tables, the trigger and the function (written down in the migration file header) — never run against production data without explicit approval.

## Implementation

- Approved implementation plan: Approved 2026-11-23 by the developer ("Approve phase", after the 8 recommended decisions were recorded and shown). Approval covers:
  - Scope, acceptance criteria 1–12 and decisions 1–8 as written above.
  - Dependency: `supabase_flutter` only (no Dio, no Firebase).
  - Interface change: `AuthRepository.restoreSession()` (+ mock).
  - Shared core: `ValidationReason.emailNotConfirmed`, `codeExpired`, `weakPassword`; new `NetworkFailure`.
  - Native: `INTERNET` permission in `android/app/src/main/AndroidManifest.xml`.
  - New files (≈ 12): `AppConfig`, `env/dev.example.json`, `SupabaseAuthRepository`, `SupabaseProfileRepository`, `ProfileRowMapper`, `SupabaseFailureMapper`, 2 migrations (tables, checks, strength trigger, RLS, column privileges, `handle_new_user`; `delete_my_account()`), `supabase/tests/profiles_rls_checks.sql`, 3 test files.
  - Modified files as listed under Scope.
  - Not approved: any remote Supabase action, any other package, iOS native changes, Storage, Edge Functions. Anything unplanned during execution stops at step `APPROVAL`.
  - Open fact (does not block execution): whether the Supabase project exists — UNVERIFIED; needed before manual testing.
- Implementation log:
  - 2026-11-23 Developer: "Execute phase". Status `ACTIVE`. Implemented the approved scope in one pass; step `MANUAL_TEST`.
  - Decisions taken inside the approved scope (smaller than planned, no new approvals needed):
    - `ValidationReason.codeExpired` and `weakPassword` were **not** added: Supabase returns one code (`otp_expired`) for a wrong and an expired code, so it maps to the existing `invalidCode`; `weak_password` maps to `passwordTooShort` (decision 2: the only rule is 8+ characters). Only `emailNotConfirmed` and `NetworkFailure` were added. As a result no ARB strings and no auth / settings screen messages changed.
    - `profiles.city` column added: the existing `Profile.city` field needed a column (the draft contract missed it).
    - Server helper functions live in a non-exposed `private` schema (not callable through the API); `execute` revoked from `public`, `anon`, `authenticated`.
    - `Supabase.initialize(publishableKey: …)`: `anonKey` is deprecated in `supabase_flutter` 2.18; the same public key works in either parameter. The define stays `SUPABASE_ANON_KEY`.
    - Login / session tests were added to the existing `test/features/cubits_test.dart` (not a new file).
- Exact changed files: see Change Log.
- Purpose of every changed file: see Change Log.
- Existing components reused: see Analysis.
- New approved components: `AppConfig`, `SupabaseAuthRepository`, `SupabaseProfileRepository`, `ProfileRowMapper`, `SupabaseFailureMapper`, `NetworkFailure` (see approved plan).
- Out-of-scope findings:
  - `android/app/src/main/AndroidManifest.xml` lacks `INTERNET` (included in this phase's scope for approval because the backend needs it in release builds).
  - Git: the old remote branch `PHASE_003_BACKEDN_FOUNDATION` may still exist on GitHub until the developer deletes it.
- Unexpected risks:
  - Network and unexpected errors: fixed 2026-11-24 for the auth flow, change password and My profile (developer fix request); setup, edit profile, post and connection screens still only re-enable the button.
  - A verified reset code signs the user in on Supabase; leaving before saving a new password keeps that session, so the next launch opens signed in.

## Change Log

Branch `PHASE_004_BACKEND_FOUNDATION` (base `28c2a7c`). Pre-existing uncommitted changes before execution: only this phase's docs (`PHASE_INDEX.md`, `PHASE_STATE.md`, this file). All paths below are in approved groups.

| File | Type | Approved | What / why | Preserved / risk |
|---|---|---|---|---|
| `pubspec.yaml`, `pubspec.lock` | modified | yes (dependency) | `supabase_flutter: ^2.18.3` (+ transitive: gotrue, postgrest, realtime_client, storage_client, functions_client, shared_preferences, url_launcher, app_links …) | No other direct package; first iOS build will add pods (developer) |
| `.gitignore` | modified | yes | Ignore `/env/*.json`, keep `/env/*.example.json` | — |
| `env/dev.example.json` | added | yes | Key names `SUPABASE_URL`, `SUPABASE_ANON_KEY`, empty values | No secrets |
| `android/app/src/main/AndroidManifest.xml` | modified | yes (native) | `INTERNET` permission for release builds | Debug / profile unchanged |
| `lib/core/config/app_config.dart` | added | yes | `AppConfig` from defines; `hasBackend` | — |
| `lib/core/errors/failures.dart` | modified | yes (shared core) | `ValidationReason.emailNotConfirmed`; `NetworkFailure` | Additive; no exhaustive switch on `Failure` exists |
| `lib/data/repositories/auth_repository.dart` | modified | yes (interface) | `restoreSession()`; `logIn` doc lists `emailNotConfirmed` / `NetworkFailure` | Other contracts unchanged |
| `lib/data/repositories/mock/mock_auth_repository.dart` | modified | yes | `restoreSession()` → null | Mock behaviour unchanged (signed out each launch) |
| `lib/data/repositories/supabase/profile_row_mapper.dart` | added | yes | Row ↔ model, snake_case enums, admin columns never written | Pure |
| `lib/data/repositories/supabase/supabase_failure_mapper.dart` | added | yes | Supabase / network errors → `Failure` | Pure |
| `lib/data/repositories/supabase/supabase_auth_repository.dart` | added | yes | Auth on Supabase (codes, reset, change password with current-password check, delete via rpc, restore) | Backend mode only |
| `lib/data/repositories/supabase/supabase_profile_repository.dart` | added | yes | Profiles + detail rows; `watchProfile` re-emits own saves | Backend mode only |
| `lib/core/session/session_cubit.dart` | modified | yes | `restore()`; failure keeps the user signed out | `signedIn` / `logOut` unchanged |
| `lib/features/onboarding/presentation/splash_screen.dart` | modified | yes | Continues after both the 1.2 s pause and `restore()` | Layout and the developer's `Row()` kept; `dart format` removed the trailing space in the doc comment |
| `lib/features/auth/bloc/login_state.dart`, `login_cubit.dart` | modified | yes | `LoginStatus.needsCode`: unconfirmed email → resend code → back to editing | Other log-in results unchanged |
| `lib/features/auth/presentation/log_in_screen.dart` | modified | yes | `needsCode` pushes the code screen with the email | Layout unchanged |
| `lib/main.dart` | modified | yes | Mock / backend modes; `Supabase.initialize`; Supabase Auth + Profile registered by interface in backend mode | Mock mode identical to before |
| `supabase/migrations/20261123120000_profiles.sql` | added | yes | Tables, checks, strength trigger, `handle_new_user`, RLS, column privileges | Not applied remotely by me |
| `supabase/migrations/20261123120100_delete_my_account.sql` | added | yes | `delete_my_account()` (`authenticated` only) | Not applied remotely by me |
| `supabase/tests/profiles_rls_checks.sql` | added | yes | 10 PASS / FAIL checks in a rolled-back transaction | Changes nothing |
| `test/data/supabase/profile_row_mapper_test.dart` | added | yes | 6 tests incl. SQL weights = Dart weights | — |
| `test/data/supabase/supabase_failure_mapper_test.dart` | added | yes | 4 tests | — |
| `test/core/config/app_config_test.dart` | added | yes | 2 tests | — |
| `test/features/cubits_test.dart` | modified | yes | 2 tests: unconfirmed log-in, `SessionCubit.restore` | Existing tests unchanged |
| `docs/API_REFERENCE.md`, `DATABASE_AND_CACHE.md`, `ARCHITECTURE.md`, `DIRECTORY_STRUCTURE.md`, `ERROR_HANDLING.md`, `TESTING_GUIDE.md` (backend setup steps), `KNOWN_ISSUES.md`, `PROJECT_OVERVIEW.md`, `FILE_CATALOG.md` | modified | yes | PHASE_004 facts | — |
| `docs/phases/items/…`, `PHASE_INDEX.md`, `state/PHASE_STATE.md` | modified | yes | Phase records | — |

Not changed: `ios/**`, theme, other repository interfaces, ARB / localizations, `docs/product/*`, `CLAUDE.md`, skill files.

### Fix 2026-11-24 — loading and error display (developer request, inside this active phase)

Developer: "show loading on button left side in all place … loading on screen load … error show properly in this auth flow … nothing change in logic". No repository, interface, migration or dependency change. No new production file.

| File | Type | What / why | Preserved / risk |
|---|---|---|---|
| `lib/core/widgets/app_button.dart` | modified (shared core, requested) | `loading`: spinner left of the label, colours kept, taps ignored | Default `false`: every existing button unchanged |
| `lib/core/widgets/confirm_sheet.dart` | modified (shared core, requested) | `loading` → confirm spinner, Cancel disabled | Default `false` |
| `lib/core/errors/failures.dart` | modified | `ValidationReason.network`, `unexpected` (display only, never thrown); `Failure.displayReason`; `ValidationReason.isGeneral` | Additive |
| `lib/features/auth/bloc/login_cubit.dart`, `sign_up_cubit.dart`, `password_reset_cubit.dart`, `otp_cubit.dart`; `lib/features/settings/bloc/change_password_cubit.dart` | modified | Non-validation failures now set `failure` / `error` to `network` / `unexpected` instead of nothing. `OtpCubit.resend` catches failures (before: an offline or rate-limited resend threw unhandled) and keeps the link active | Flow and validation results unchanged |
| `lib/features/auth/presentation/log_in_screen.dart`, `sign_up_screen.dart`, `email_code_screen.dart`, `forgot_password_screen.dart`, `new_password_screen.dart`; `lib/features/settings/presentation/change_password_screen.dart` | modified | Button `loading`; general error text above the button; code screens show network / unexpected instead of "code didn't work" | Layout otherwise unchanged |
| `lib/features/settings/presentation/delete_account_sheet.dart` | modified | Confirm button `loading` while deleting | Existing failure text kept |
| `lib/features/profile_setup/presentation/student_setup_screen.dart`, `teacher_setup_screen.dart`, `lib/features/profile/presentation/edit_profile_screen.dart`, `lib/features/post/presentation/create_post_screen.dart`, `lib/features/safety/presentation/report_sheet.dart`, `lib/features/connections/presentation/connect_sheet.dart` | modified | Button `loading` from the existing `saving` / `posting` / `sending` flags | — |
| `lib/features/profile/bloc/my_profile_state.dart`, `my_profile_cubit.dart`, `presentation/my_profile_screen.dart` | modified | Spinner while the profile loads; `loadError` + "Couldn't load your profile" message when it fails (before: blank forever) | Loaded view unchanged |
| `lib/features/discover/presentation/public_profile_screen.dart` | modified | Spinner while the profile loads | Not-found view unchanged |
| `lib/l10n/app_en.arb` (+ generated) | modified | `errorNoConnection`, `errorSomethingWentWrong`, `profileLoadFailedTitle` | — |
| `test/features/cubits_test.dart`, `test/features/screens_test.dart` | modified | 4 tests: `displayReason`, log-in network error, failed resend, `AppButton.loading` | — |
| `docs/COMMON_COMPONENTS.md`, `ERROR_HANDLING.md`, `KNOWN_ISSUES.md` | modified | Facts above | — |

Not covered (recorded): per-item buttons in lists (Connect on cards, Accept / Decline, Unblock) have no per-item busy state in their cubits — adding one would change cubit logic; mock calls are instant today. Their phases (discover / connections on Supabase) should add it.

Checks: `flutter gen-l10n` OK; `dart format lib test`; `flutter analyze` — No issues found; `flutter test` — 119 / 119 passed (115 + 4).

### Fix 2026-11-24 — one run mode (developer request, inside this active phase)

Developer: each part should be real or mock, never both; auth real, other data mock until implemented. No new file, dependency or interface change.

| File | Type | What / why | Preserved / risk |
|---|---|---|---|
| `lib/main.dart` | modified | Full-mock app mode removed: Auth + Profile always Supabase; missing settings → `StateError` with the run command. Other repositories stay mock; `MockProfileRepository` kept only as the sample-people source for those mocks (not registered). `MockAuthRepository` no longer created here | Backend wiring unchanged; a plain `flutter run` without `env/dev.json` now stops instead of running on mocks |
| `lib/core/config/app_config.dart` | modified | Doc comments only | — |
| `test/core/config/app_config_test.dart` | modified | Test name only | — |
| `docs/ARCHITECTURE.md`, `FILE_CATALOG.md`, `PROJECT_OVERVIEW.md`, `TESTING_GUIDE.md`, `KNOWN_ISSUES.md` | modified | One run mode; dependency order for later phases | — |

Mock classes stay in `lib/data/repositories/mock/` for tests. Checks: `dart format`; `flutter analyze` — No issues found; `flutter test` — 119 / 119 passed. Not done (needs approval: new file): an IDE run configuration that passes `--dart-define-from-file=env/dev.json`.

### Fix 2026-11-24 — default settings file (developer request, inside this active phase)

Developer: run with real Supabase by default, from a separate public file (chosen because `env/dev.json` also holds two non-public keys that must not ship in the app).

| File | Type | What / why | Preserved / risk |
|---|---|---|---|
| `env/supabase.json` | added (git-ignored, local only) | URL + public key copied from `env/dev.json` by script (values not shown) | Not committed; `env/dev.json` untouched |
| `pubspec.yaml` | modified (approved by developer) | Asset `env/supabase.json` | A fresh clone must create the file before building |
| `lib/core/config/app_config.dart` | modified | `fromJson` (only `SUPABASE_URL`, `SUPABASE_ANON_KEY`; any other key → `StateError`), `assetPath`, `allowedKeys` | `fromEnvironment` unchanged |
| `lib/main.dart` | modified | `_loadConfig`: defines win, else the bundled file | Repository wiring unchanged |
| `test/core/config/app_config_test.dart` | modified | 2 tests: file read, extra key refused | — |
| `docs/TESTING_GUIDE.md`, `ARCHITECTURE.md`, `FILE_CATALOG.md`, `KNOWN_ISSUES.md` | modified | Setup step and facts | — |

Checks: `dart format`; `flutter pub get`; `flutter analyze` — No issues found; `flutter test` — 121 / 121 passed. `git status`: `env/supabase.json` not listed (ignored).

Follow-up (developer: "Yes, do both"): `env/dev.example.json` renamed to `env/supabase.example.json` (`git mv`); local git-ignored `env/dev.json` deleted (no longer read; it held two non-public keys). References updated in `app_config.dart` and `main.dart` (comments / error text), `pubspec.yaml` (comment), `TESTING_GUIDE.md`, `KNOWN_ISSUES.md`, `FILE_CATALOG.md`, `DIRECTORY_STRUCTURE.md`, `PROJECT_OVERVIEW.md`; older log rows keep the old names as history.

## Execute Technical Checks

2026-11-23:

- `flutter pub add supabase_flutter` — resolved `^2.18.3`, 45 dependencies changed.
- `dart format lib test` — applied (new / changed files; splash doc-comment trailing space removed).
- `flutter analyze` — No issues found (one deprecation `anonKey` fixed by using `publishableKey`).
- `flutter test` — 115 / 115 passed (101 existing + 14 new), mock mode.
- Source assertions — `supabase_flutter` imported only in `lib/main.dart` and `lib/data/repositories/supabase/`; `Supabase.instance` only in `lib/main.dart`; no keys or tokens in `lib/`, `env/`, `supabase/`, `test/`; `env/dev.json` ignored, `env/dev.example.json` not ignored (`git check-ignore`).
- Not run: migrations and `profiles_rls_checks.sql` (no access to the remote project — developer applies, decision 7); app launch / builds (not requested); iOS pod install (developer's first iOS build).

## Manual Testing

- Developer manual-test confirmation: 2026-11-24 — "tested and working fine" (CLOSE PHASE request).
- Tested platforms / devices: not stated by the developer.
- Failed and retested cases: none reported. Developer note during testing: a teacher profile showed 85 % because no photo was attached (photo = 15 %); expected, real photo upload deferred to the Storage phase.
- Manual-test notes requested by developer: None
- Needed before manual testing (decision 2): Supabase project with the dashboard settings and steps in `docs/TESTING_GUIDE.md` → "Backend Mode Setup"; migrations applied; `env/supabase.json` filled in by the developer (from `env/supabase.example.json`).
- Manual cases (high-risk: auth, RLS, deletion), plain `flutter run` / IDE Run (reads `env/supabase.json`), Android and iOS:
  1. Sign up as a student and as a teacher → 6-digit code email → code screen → setup → Home; rows visible in Table Editor with the right `role`.
  2. Wrong code → error; Resend after 60 s → new code works.
  3. Sign up again with a used email → "already has an account".
  4. Sign up, close the app before the code, then Log in → a new code is sent and the code screen opens.
  5. Log in with a wrong password → error; right password → Home.
  6. Forgot password → code → new password → Home; log in again with the new password.
  7. Edit profile / setup save → values persist after restart; `completion_pct` in the table matches the app's %.
  8. Restart the app → still signed in; Log out → restart → Welcome.
  9. Settings → Change password (wrong current password → error; right → saved).
  10. Settings → Delete account → user gone from Authentication and all three tables.
  11. Run `supabase/tests/profiles_rls_checks.sql` → all PASS.
  12. Plain `flutter run` / IDE Run (no flag) → real Supabase from `env/supabase.json`; an extra key in that file → the app stops with a clear error (changed 2026-11-24: no full-mock mode).

## Closure

- Closed 2026-11-24: status `CLOSED`, step `CLOSURE`, outcome `COMPLETED`.
- Final changed files: as in the Change Log and the four 2026-11-24 fix sections (loading / error display; one run mode; default settings file; env file rename). No unapproved dependency or architecture change: the only new dependency is the approved `supabase_flutter`; the `pubspec.yaml` asset `env/supabase.json` and the `env/` rename were approved by the developer in chat.
- Technical evidence reused (no implementation file changed after it): `dart format`; `flutter analyze` — No issues found; `flutter test` — 121 / 121 passed (after the last change on 2026-11-24). Not rerun at closure.
- Known limitations:
  - Feed, discover, connections, chat, notifications and safety are still mock and only know the sample people.
  - Photos and certificates are placeholder paths (no Storage upload).
  - Per-item list buttons (Connect on cards, Accept / Decline, Unblock) have no busy state; setup, edit profile, post and connection screens show no network / unexpected error text.
  - After a verified reset code the user stays signed in if they leave before saving a new password.
  - A fresh clone must create `env/supabase.json` from `env/supabase.example.json` before building.
  - Remote migrations applied by the developer (confirmed by the successful manual test); not verified by me.
- Follow-up phases (to be created on request, dependency order): Storage (profile photos, certificates, replacing placeholder paths) → discover → safety → connections → chat → feed → notifications; each replaces only its own mock in `lib/main.dart`.
- Security follow-up (developer): the Brevo SMTP key and database password that were pushed earlier must be rotated.
- Rollback: revert the phase commit(s) (or restore modified files and delete new ones) and run `flutter pub get`. Database: migrations are additive; on a project without real users drop the three tables, the trigger and the functions as written in the migration headers — never against production data without explicit approval.
- Commit: not requested; nothing committed by this closure.
