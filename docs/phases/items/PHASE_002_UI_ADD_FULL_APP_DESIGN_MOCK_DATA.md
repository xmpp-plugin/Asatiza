# PHASE_002_UI_ADD_FULL_APP_DESIGN_MOCK_DATA — UI: Full App Design With Mock Data (Part 1 of 2)

## Identity

- Phase ID: PHASE_002_UI_ADD_FULL_APP_DESIGN_MOCK_DATA
- Phase title: Full App Design With Mock Data — Part 1 of 2 (UI foundation, onboarding & sign in, profile setup, home feed & posts)
- File name: PHASE_002_UI_ADD_FULL_APP_DESIGN_MOCK_DATA.md
- Module: UI
- Priority: High
- Risk level: High (3 production dependencies, ≈ 135 new Dart/test files + 50 SVG assets, new `mock/` data layer, first models and repository interfaces, shared core widgets and theme constants, router rewrite)
- Current status: APPROVED
- Current step: APPROVAL
- Approval: APPROVED
- Outcome: NONE
- Version: 1.0
- Created date: 2026-11-19
- Last updated date: 2026-11-19 (approved)
- Started date: Not started
- Completed date: Not completed
- Developer owner: Repository owner (developer) — owner and manual tester
- Dependency phases: PHASE_001_FOUNDATION_ADD_PROJECT_FOUNDATION

## Requirement

- Original developer request (2026-11-19, summarised): Build the full application UI to match the owner's design canvas 100 % (https://claude.ai/artifact/LUxhadrsA4EUF74spHVLLc). Use the design's theme and fonts; export the design's actual icons and images (SVG) into `assets/` and use them. Build custom reusable components. Show professional mock data from models — no test/placeholder text. UI only: no backend, no real-time data; filters, search, selections and screen interactions work on mock data. Use enums for selectable values. Later phases replace the mock data with backend functionality.
- Split (developer answer 1): the request is delivered in **2 phases**:
  - **This phase (part 1):** UI foundation + canvas rows "Onboarding & sign in", "Profile setup (skip-able)", "Home feed & posts".
  - **Part 2 (created after this phase closes):** rows "Find & connect", "Chats & notifications", "Me & settings" — Teachers/Students lists, Filter sheet, Public profile, Connect sheet, My connections, Chats, Chat, Notifications, My profile, Edit profile, Settings and its sub-screens, plus their models, repositories and mock data.
- Business objective: A navigable, design-accurate first half of the app (from first launch to posting in the feed) that the owner can review on Android and iOS, built on the data layer and components that part 2 and the backend phases reuse. DECIDED
- Expected outcome: The listed screens are built pixel-faithful to their 390×844 artboards with the design's icons and illustrations, wired into Splash → Welcome → Sign up / Log in → Email code → Profile setup → Home (feed, post detail, create post, report sheet), driven by in-memory mock data through the decided architecture (screens → cubits → repository interfaces → mock implementations). The Teachers, Chats and Alerts tabs keep their PHASE_001 placeholders until part 2.
- Acceptance criteria (proposed; confirm at approval):
  1. Each in-scope artboard (18, listed under Analysis) has a Flutter screen or sheet whose layout, spacing, sizes, colors, typography, radii, shadows, icons and copy match the artboard at 390×844 in light mode, checked side by side by the developer.
  2. All 41 design icons, the read-ticks glyph, 6 illustrations and 2 logo images are exported from the canvas as SVG into `assets/` (once, for both parts) and rendered from those files; the bottom bar uses the design icons (no Material icons where the design has its own).
  3. All visible data comes from mock model objects that read like real professional data; no "test", "lorem", "sample" or "placeholder" text anywhere.
  4. Every selectable value in scope (role, gender, subject, teaching language, learner age group, learner level, fee unit, teaches-audience, weekday, post tag, report reason, teacher-gender preference) is an enum with its label in `app_en.arb`.
  5. In-memory mock behaviour (developer answer 2; resets on restart): sign up / log in / code / password reset flows; setup steps (continue, skip, back) saving to the mock user; profile-strength % recalculated by `ProfileStrengthCalculator`; like/unlike, comment, create post (text, mock photo, tag, 1,500-char counter), report (+ "Also block" hides the author's posts); feed order connections-first.
  6. No network, Supabase, Firebase, Dio or real authentication.
  7. Dark mode renders every in-scope screen from the dark tokens (design illustrations keep their own colors).
  8. Every UI string comes from `app_en.arb`; layouts are direction-neutral.
  9. `flutter analyze` clean; unit, cubit and widget tests pass.
  10. SOLID per `CLAUDE.md`: no screen or cubit imports a mock class; mocks are registered by interface type only in `lib/main.dart`.

## Analysis

- Design source (VERIFIED, canvas version `1795090178-e295`, read 2026-11-19 after the developer added screens): **47 artboards** in 11 rows. The 27 original artboards and `tokens.json` are byte-identical to the first read (sha256 checked); 20 artboards were added in 5 new rows ("Onboarding & sign in (added)", "Profile setup (added)", "Find & connect (added)", "Me & settings (added)", "States (added)"). `20d Edit profile · teacher` is 390×1340 (whole scrolling form).
- Design assets (VERIFIED by parsing all 47 artboards): **41** unique 24×24 stroke icons (2 new on 14b: globe, user); a 22×12 read-ticks glyph (Chat); **6** illustrations (Welcome slides 1–3 heroes 342×330, Home certificate photo 326×150, Create post photo 326×110, Chat "Qaida page" 326×130); 2 uploaded logos (Splash logo 132×143, Log in mark 56×61 — cropped differently from `assets/logos/logo/*.svg`, so exported separately). No raster photos; avatars are initials on token tints.
- Off-token values used by the artboards (VERIFIED, all 47 artboards parsed; the added artboards use the same set, no new values; `tokens.json` unchanged) — design is the source of truth, so they are implemented exactly (see Developer Answers, 6c):
  - Font sizes: 11 px (badges, tag counts, Certificate photo label), 13 px (helper text, meta lines, help boxes), 15 px (body on auth/post text, inputs' placeholder lines), 18 px (sheet and page titles), 19 px (avatar initials 52 px), 28 px (auth/setup display titles, Fraunces 28/34), 29 px (My profile name), 44 px (Splash wordmark, Fraunces 44/48).
  - Radii: 4, 6 (checkbox), 9, 10 (OTP boxes), 14 (role cards), 18 (chat bubbles), 20 (profile-strength card).
  - Gaps: 2, 6, 10, 14, 18, 22 px.
- In-scope screen inventory — **18 artboards** (artboard → screen): 01 Splash · 02 / 02b / 02c Welcome slides 1–3 · 03 Sign up (role cards, name, email, password, 18+ consent) · 04 Email code (6 boxes, resend timer, help box) · 05 Log in · 06 / 06a / 06b Forgot password steps 1–3 (email → code → new password) · 07a–c Teacher setup 1–3 · 07e / 07d / 07f Student setup 1–3 (age group Child 6–12 / Teen 13–17 / Adult 18+ with parent note; subjects, level, languages; preferred teacher gender, "Looking for a teacher" switch, note 0/200) · 08 Home (top bar, strength card, feed) · 09 Post detail (comments, composer) · 10 Create post · 22 Report sheet (5 reasons, "Also block"). From the states row: the **feed** empty state (23) and the **post-card** skeleton (24).
- Part 2 artboards (not in this phase): 11, 12, 13, 13b, 14, 14b, 15, 16, 17, 18, 19, 20a–d, 21, 21a–g, 21b-empty, 08b Home search results (needs teacher search), and the chats/notifications/connections/search empty states and teacher-card/chat-row skeletons.
- Current behavior (VERIFIED, PHASE_001 committed `316b68e` and pushed): 4-branch shell with placeholders; theme tokens, fonts, l10n, router; Material icons in the bottom bar; no models, repositories, cubits, `flutter_bloc` or SVG support.
- Root cause or implementation gap: Everything in scope above the shell is missing.
- End-to-end flow (target, mock): `main()` creates mock repositories → `MultiRepositoryProvider` (by interface type) → `SessionCubit` (signed-out / code-pending / signed-in + current user + role) → `appRouter` redirect → Splash → Welcome → Sign up / Log in (cubits → `AuthRepository`) → Email code → setup (cubits → `ProfileRepository`) → Home (`FeedCubit` → `FeedRepository`) → Post detail / Create post / Report sheet (`PostDetailCubit`, `CreatePostCubit`, `ReportCubit` → `FeedRepository`, `SafetyRepository`). Mock repositories hold state in memory and expose streams so screens update after actions.
- Existing reusable components (PHASE_001): `AppColors`, `AppTextStyles`, `AppSpacing`, `AppRadius`, `AppShadows`, `AppTheme`, `AppRoutes`, `appRouter`, `MainShell`, placeholder screens, l10n, fonts — all reused.
- Existing API details / models / state management: none (go_router only). This phase adds `flutter_bloc`.
- Android / iOS behavior: No native or permission change. "Add a profile photo", "Upload certificates" and "Photo" show the designed UI and attach a mock illustration (no camera/gallery, no `image_picker`). Platform-native behaviour (developer answer 5): iOS back-swipe, platform scroll physics; Android back per PHASE_001.
- Lifecycle behavior: Cubits per route via `BlocProvider`; mock stream subscriptions cancelled in `close()`; text controllers disposed; the OTP resend countdown `Timer` belongs to `OtpCubit` and is cancelled in `close()`.
- Permission, database, Supabase, RLS, Realtime, push: None in this phase. Models mirror plan section 12 so backend phases map 1:1. Mock repositories apply plan rules through logic classes (feed order, post limits, blocked users hidden).
- Both roles and signed-out behavior (developer answer 4): every launch starts signed out (Splash → Welcome). Log in with any valid email + 8-character password; built-in mock accounts set the role: **Ayesha Khan** (student, `ayesha.khan@gmail.com`, as on the artboards) and **Qari Ahmed Khan** (teacher); any other email signs in as a student. Sign up uses the selected role card and continues to that role's setup.
- Security considerations: No secrets, network or real auth. Mock passwords are never stored or shown. "Create account" stays disabled until the 18+ / Terms consent is ticked. Report/block act on mock data only.

### Design Against The SOLID Checklist

- S: widgets render; cubits coordinate; logic classes decide rules (strength %, feed order, post rules, password rules, OTP rules, relative time); repositories move data; seed files hold data only.
- O: backend phases add `Supabase*Repository` classes and switch registrations in `lib/main.dart`; screens and cubits stay unchanged. Part 2 adds new interfaces without editing these.
- L: mock repositories honour the documented method contracts (returns, `*Failure` types, ordering) the Supabase versions must honour.
- I: one small interface per area in this phase: `AuthRepository`, `ProfileRepository`, `FeedRepository`, `SafetyRepository`.
- D: cubits receive interfaces through constructors; concrete mocks are created only in `lib/main.dart`.
- Balance: interfaces only at the repository boundary.

## Scope

- In scope (part 1):
  1. **Assets for both parts:** 41 icons + read-ticks glyph → `assets/icons/<name>.svg`; 6 illustrations → `assets/illustrations/`; 2 logos → `assets/images/`; folders declared in `pubspec.yaml`.
  2. **Dependencies:** `flutter_bloc`, `flutter_svg`, `equatable` (developer answer 7).
  3. **Theme constants for off-token artboard values** (developer answer 6c): added as clearly named constants to `AppTextStyles`, `AppSpacing`, `AppRadius` — design-token values themselves unchanged.
  4. **Models + enums** needed by part 1, mirroring plan section 12 (`copyWith`, `Equatable`, no JSON yet).
  5. **Repository interfaces** (4, with documented method contracts) + **mock implementations** (4) + **mock seed data** (≈ 24 teachers and 18 students as authors/profiles, 14 posts with comments, realistic Islamic-education content in the design's style).
  6. **Session** (`SessionCubit`) and **router**: full route map for part 1 + redirect.
  7. **Logic classes**, **shared components** and **feature widgets** for part 1.
  8. **Screens/sheets for the 18 in-scope artboards**, plus the feed empty state and post-card skeleton, replacing the Home and Create post placeholders.
  9. **`MainShell`**: design SVG icons and design label/pill styling (structure kept). Role-aware "Students" tab and unread badges come in part 2.
  10. **Strings** for all in-scope UI copy in `app_en.arb` (≈ 180 keys); **tests**; **doc updates**.
- Explicitly out of scope (part 2 or later): Teachers/Students lists, filters, public profile, connect, connections, chats, chat, notifications, my profile, edit profile, settings and their sub-screens, models/repositories for them (`DiscoverRepository`, `ConnectionRepository`, `ChatRepository`, `NotificationRepository`), unread badges, role-aware second tab; Supabase/Firebase/Dio; real auth; persistence; camera/gallery; push; deep links; launcher icons/native splash; Urdu/Arabic translations; golden (screenshot) tests (developer answer 8); changes to the design canvas.
- Files expected to change (existing):
  - `pubspec.yaml`, `pubspec.lock` — 3 dependencies, 3 asset folders.
  - `lib/main.dart` — mock repositories, `MultiRepositoryProvider`, `SessionCubit`.
  - `lib/app.dart` — router created with the session for redirects.
  - `lib/core/router/app_routes.dart`, `lib/core/router/app_router.dart` — part 1 route map + redirect.
  - `lib/core/widgets/main_shell.dart` — design SVG icons and label styling.
  - `lib/core/theme/app_text_styles.dart`, `app_spacing.dart`, `app_radius.dart` — off-token artboard constants added (existing values unchanged).
  - `lib/features/feed/presentation/home_screen.dart`, `lib/features/post/presentation/create_post_screen.dart` — placeholders replaced.
  - `lib/l10n/app_en.arb` (+ regenerated `app_localizations*.dart`).
  - `test/app_test.dart`, `test/core/router/app_router_test.dart`, `test/core/theme/app_theme_test.dart` — updated for the Splash start, new routes and new constants.
  - Docs: `ARCHITECTURE.md`, `DIRECTORY_STRUCTURE.md` (adds `mock/`, `session/`), `NAVIGATION.md`, `COMMON_COMPONENTS.md`, `STATE_MANAGEMENT.md`, `API_REFERENCE.md` (4 interfaces, provisional), `DATABASE_AND_CACHE.md` (models), `FILE_CATALOG.md`, `TESTING_GUIDE.md`, `KNOWN_ISSUES.md`, `PROJECT_OVERVIEW.md`.
- Files that must not change: `docs/product/*`, `android/**`, `ios/**`, `analysis_options.yaml`, `assets/fonts/**`, `assets/logos/**`, `lib/core/theme/app_colors.dart`, existing values in the theme classes, the Teachers/Chats/Alerts placeholder screens (part 2), `CLAUDE.md`, skill files.
- Proposed new files (approval requested):

  | Group | Count | Paths / classes |
  |---|---|---|
  | Icons | 42 | `assets/icons/{check,chevron_left,chevron_right,chevron_down,chat,more,people,close,home,plus,bell,search,user_plus,map_pin,send,mail,shield,sliders,graduation_cap,heart,comment,flag,eye,image,share,calendar,clock,camera,info,lock,settings,pencil,key,ban,document,log_out,trash,upload,book_open,globe,user,read_ticks}.svg` |
  | Illustrations / images | 8 | `assets/illustrations/{welcome_hero_1,welcome_hero_2,welcome_hero_3,certificate_photo,post_photo,qaida_page}.svg`, `assets/images/{logo_splash,logo_mark}.svg` |
  | Enums | 12 | `lib/data/models/enums/`: `UserRole`, `Gender`, `Subject`, `TeachingLanguage`, `LearnerAgeGroup`, `LearnerLevel`, `FeeUnit`, `TeachesAudience`, `Weekday`, `PostTag`, `ReportReason`, `TeacherGenderPreference` |
  | Models | 5 | `lib/data/models/`: `Profile`, `TeacherDetails`, `StudentDetails`, `Post`, `Comment` |
  | Failures | 1 | `lib/core/errors/failures.dart` (`Failure` sealed base + `ValidationFailure`, `NotFoundFailure`, `UnexpectedFailure`) |
  | Repository interfaces | 4 | `lib/data/repositories/{auth,profile,feed,safety}_repository.dart` |
  | Mock implementations | 4 | `lib/data/repositories/mock/mock_{auth,profile,feed,safety}_repository.dart` (**new `mock/` folder**) |
  | Mock seed data | 2 | `lib/data/mock/{mock_profiles,mock_posts}.dart` (**new folder**) |
  | Session | 2 | `lib/core/session/{session_cubit,session_state}.dart` (**new folder**) |
  | Logic | 6 | `lib/core/logic/profile_strength_calculator.dart`; `lib/features/feed/logic/feed_ordering.dart`; `lib/features/post/logic/post_rules.dart`; `lib/features/auth/logic/{password_rules,otp_rules}.dart`; `lib/core/utils/relative_time_formatter.dart` |
  | Shared widgets | 20 | `lib/core/widgets/`: `AppIcon`, `AppButton`, `AppTextField`, `AppTextArea`, `AppChip`, `TagChip`, `AppAvatar`, `VerifiedBadge`, `AppCheckbox`, `SectionLabel`, `BackHeader`, `AppBottomSheet`, `StepProgressHeader`, `NumberedStepper`, `OtpInput`, `ProfileStrengthCard`, `PostCard`, `EmptyStateView`, `SkeletonBox`, `PostCardSkeleton` |
  | Feature widgets | 10 | `auth/.../role_card.dart`, `auth/.../info_note.dart`, `onboarding/.../welcome_slide.dart`, `onboarding/.../page_dots.dart`, `profile_setup/.../weekday_picker.dart`, `profile_setup/.../photo_picker_tile.dart`, `profile_setup/.../upload_tile.dart`, `feed/.../home_top_bar.dart`, `feed/.../comment_tile.dart`, `feed/.../comment_composer.dart` |
  | Cubits + states | 22 | `SignUpCubit`, `OtpCubit`, `LoginCubit`, `PasswordResetCubit`, `TeacherSetupCubit`, `StudentSetupCubit`, `FeedCubit`, `PostDetailCubit`, `CreatePostCubit`, `ReportCubit`, `WelcomeCubit` (each `<name>_cubit.dart` + `<name>_state.dart`) |
  | Screens / sheets | 13 new + 2 replaced | `SplashScreen`, `WelcomeScreen`, `SignUpScreen`, `EmailCodeScreen`, `LogInScreen`, `ForgotPasswordScreen` (email + code steps), `NewPasswordScreen`, `TeacherSetupScreen` (3 steps), `StudentSetupScreen` (3 steps), `HomeScreen`*, `PostDetailScreen`, `CreatePostScreen`*, `ReportSheet` (* replaces placeholder) |
  | Tests | ≈ 28 | unit (logic, formatter, models), cubit tests with mock repositories, widget tests per screen, updated app/router/theme tests |

  Total ≈ 185 new files incl. 50 SVG assets (≈ 135 Dart/test files) plus ≈ 25 modified.
- Proposed new classes: as listed (≈ 95 incl. states). Approval requested per group.
- Dependency changes (approval requested): `flutter_bloc`, `flutter_svg`, `equatable` (pub.dev, latest compatible with Flutter 3.41 / Dart 3.11).
- Downloads: none from the internet — all assets come from the owner's design canvas.
- API contract changes: first definition of `AuthRepository`, `ProfileRepository`, `FeedRepository`, `SafetyRepository` (HIGH risk; marked **provisional** until each backend phase confirms it).
- Native changes: None. Supabase changes: None.
- Approval requirements: High risk. Explicit approval for the 3 dependencies, the new `lib/data/repositories/mock/`, `lib/data/mock/` and `lib/core/session/` folders, models/enums, repository interfaces, theme constants, shared widgets and every file group above.

## Developer Answers (2026-11-19)

| # | Question | Answer |
|---|---|---|
| 1 | Phase size | Split into **2 phases**: this file = part 1 (foundation + onboarding/sign in + profile setup + home feed/posts); part 2 = find & connect + chats/notifications + me/settings, created after this phase closes |
| 2 | What "working" means | Yes — actions change in-memory mock data; reset on restart; no persistence, no fake delay |
| 3 | Screens without artboards | Developer added 20 artboards to the same canvas (version `1795090178-e295`, verified 2026-11-19). Part 1 uses 02b, 02c, 06a, 07e, 07f + feed empty state + post-card skeleton; the rest belong to part 2 |
| 4 | Mock session | Yes — start signed out at Splash → Welcome; mock accounts Ayesha Khan (student) and Qari Ahmed Khan (teacher); other emails = student; Sign up uses the chosen role |
| 5 | "Hybrid" components | Yes — custom components from the design, native behaviour on Android and iOS |
| 6 | Design mismatches | Best recommendation: (a) "Also block" names the **post author**; (b) unread badge numbers come from mock counts (part 2); (c) off-token artboard values are implemented **exactly** as named constants in the theme classes (token values unchanged). Re-checked 2026-11-19: `tokens.json` unchanged and the added artboards use the same off-token values already listed → implemented as theme constants |
| 7 | `equatable` | Yes — use it |
| 8 | Golden (screenshot) tests | Recommendation accepted: **no golden tests**. Reason: baseline images differ between Windows, macOS and CI font rendering, need regenerating after every approved visual change, and add binary files without proving the match to the design. Instead: widget tests for structure, copy and interactions + a theme test for every constant + the developer's side-by-side visual check |

## Missing Information

None blocks approval. Resolved 2026-11-19: the added screens are published (canvas version `1795090178-e295`) and no new sizes exist beyond those measured.

For part 2 (not this phase): the legal texts on 21c Content policy, 21d Privacy policy and 21e Terms of use and the Blocked users names were written by the design tool — the owner should have the legal pages reviewed before launch.

## Readiness Checklist

- [x] Requirement is clear
- [x] Expected behavior is clear
- [x] Existing flow is traced
- [x] API is verified (not applicable — mock only)
- [x] Request contract is verified (not applicable)
- [x] Response contract is verified (not applicable)
- [x] Supabase tables, RLS and Storage policies are defined (not applicable; models mirror plan section 12)
- [x] Security, 18+ gate and moderation rules are unaffected or approved (18+ consent kept; report/block on mock data)
- [x] Required UI/design is available (canvas version `1795090178-e295`, 18 in-scope artboards)
- [x] Existing reusable components are identified
- [x] Proposed files are identified
- [x] New files/classes are approved
- [x] Platform behavior is understood
- [x] Permissions are understood (none)
- [x] Dependencies are available (approved: `flutter_bloc`, `flutter_svg`, `equatable`)
- [x] Risks are documented
- [x] Automated tests are defined
- [x] Manual tests are defined
- [x] Rollback plan is defined
- [x] Phase dependencies are completed (PHASE_001 closed, committed, pushed)
- [x] Developer approval is recorded

## Risks

- **"100 % match":** Flutter and the HTML canvas render text slightly differently (hinting, line breaks, Fraunces optical sizing, shadow blur). Target: identical layout, sizes, spacing, colors, icons and copy; the developer judges side by side.
- **Repository contracts before the backend** may change when Supabase work starts (provisional; screens depend only on interfaces).
- **SVG rendering:** stroke icons use `currentColor`, mapped with `ColorFilter`; the Welcome hero uses `rotate` transforms — checked on device.
- **Mock content** must be respectful and accurate (Arabic verse text, greetings); the developer reviews the seed files.
- **Dark mode** has no artboards; colors come from tokens.
- **Router rewrite** changes the app start (Splash/Welcome); PHASE_001 tests are updated.
- **Theme constants** added for off-token values could drift from a later design-system update; the theme test pins them.

## Test Plan

- Automated (execute): `flutter gen-l10n`; `dart format` on changed files; `flutter analyze`; `flutter test` — unit tests (strength %, feed ordering, post rules, password/OTP rules, relative time, model `copyWith`/equality), cubit tests against mock repositories (sign up, login, OTP countdown, password reset, setup steps + skip, feed load, like, comment, create post, report + block), widget tests per screen (design copy from ARB, key interactions, navigation), updated app/router/theme tests. No golden tests (developer answer 8).
- Manual (developer, Android + iOS, light and dark): Splash → Welcome (swipe slides 1–3, Skip) → Sign up as student and as teacher → Email code (timer, any 6 digits) → setup steps (Continue, Skip for now, back) → Home (strength card, feed) → Like → Post detail → Comment → Report with "Also block" → author's posts hidden → Create post (text, photo, tag, counter) → new post on top → Log in with Ayesha / Qari Ahmed accounts → Forgot password 3 steps (email → code → new password) → Student setup 1–3 (age group, Looking switch, note counter). Compare each screen with its artboard. Confirm no test/placeholder text.

## Rollback Plan

All changes are local Dart, assets, pubspec and docs; no native, data or remote effects. Roll back by reverting the phase commit (or, before commit, restoring modified files with Git and deleting the new files and folders) and running `flutter pub get`. PHASE_001 behaviour (placeholder shell, Home first) returns.

## Implementation

- Approved implementation plan: Approved 2026-11-19 by the developer (repository owner) with the explicit request "APPROVE PHASE: PHASE_002_UI_ADD_FULL_APP_DESIGN_MOCK_DATA". The approval covers the Scope section of part 1 exactly as written: the 3 dependencies (`flutter_bloc`, `flutter_svg`, `equatable`); the new folders `lib/data/repositories/mock/`, `lib/data/mock/`, `lib/core/session/`, `lib/data/models/enums/`; 50 SVG assets (42 icons, 6 illustrations, 2 logos) exported from the owner's canvas version `1795090178-e295`; 12 enums, 5 models, `failures.dart`; 4 provisional repository interfaces (`AuthRepository`, `ProfileRepository`, `FeedRepository`, `SafetyRepository`) and their mock implementations and seed data; `SessionCubit`; 6 logic files; off-token theme constants added to `AppTextStyles`, `AppSpacing`, `AppRadius` (existing values unchanged); 20 shared widgets, 10 feature widgets, 11 cubits with states; the screens for the 18 in-scope artboards (+ feed empty state, post-card skeleton); router/session redirect; `MainShell` design icons; ARB strings; tests; and the listed doc updates. Anything outside this list needs new approval (step `APPROVAL`, approval `PENDING`). No golden tests. Native code, Supabase and Firebase stay untouched.
- Implementation log: Not started
- Exact changed files: None
- Purpose of every changed file: None
- Existing components reused: PHASE_001 theme tokens, `AppTheme`, `AppRoutes`, `appRouter`, `MainShell`, l10n setup, bundled fonts.
- New approved components: None
- Out-of-scope findings:
  - Launcher icons / native splash from `assets/logos/` (separate phase; native change).
  - Check Amiri diacritics for the Quran verse on Android and iOS during manual test.
  - Git: the working branch is still `PHASE_001_FOUNDATION_ADD_PROJECT_FOUNDATION`; a new branch for this phase is recommended before execution.
- Unexpected risks: None

## Change Log

For every changed file, record:

| File path | Change type | Approved in phase | What changed | Why it changed | Existing behavior preserved | Possible side effects | File-level checks |
|---|---|---|---|---|---|---|---|
| None | Not changed | Not applicable | Not applicable | Not applicable | Not applicable | Not applicable | Not applicable |

## Execute Technical Checks

- Changed-file evidence reviewed after changes: Not reviewed
- Git status/diff rerun reason: Not needed yet
- Patch/whitespace check result, when run: Not run
- Relevant Dart formatting: Not run
- Scoped or project analysis commands: Not run
- Relevant targeted tests: Not run
- Newly introduced issues found: None recorded
- Newly introduced issues fixed: None recorded
- Pre-existing unrelated issues: None recorded
- Commands that could not run and why: None recorded

## Manual Testing

- Ready for developer manual testing: No
- Developer manual-test confirmation: Not provided
- Manual-test notes requested by developer: None

## Closure

- Developer manual-test confirmation: Not provided
- Tested platforms: Not provided
- Tested devices: Not provided
- Failed and retested cases: None recorded
- Known limitations: None recorded
- Follow-up phases: Part 2 (find & connect, chats & notifications, me & settings) — created after this phase closes.
- Reused Execute technical evidence at closure: Not evaluated
- Rollback guidance: See Rollback Plan
- Final status: Not closed
- Completion date: Not completed
