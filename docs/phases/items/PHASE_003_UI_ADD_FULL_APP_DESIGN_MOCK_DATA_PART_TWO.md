# PHASE_003_UI_ADD_FULL_APP_DESIGN_MOCK_DATA_PART_TWO — UI: Full App Design With Mock Data (Part 2 of 2)

## Identity

- Phase ID: PHASE_003_UI_ADD_FULL_APP_DESIGN_MOCK_DATA_PART_TWO
- Phase title: Full App Design With Mock Data — Part 2 of 2 (find & connect, chats & notifications, me & settings)
- File name: PHASE_003_UI_ADD_FULL_APP_DESIGN_MOCK_DATA_PART_TWO.md
- Module: UI
- Priority: High
- Risk level: High (≈ 125 new Dart/test files, 4 new and 2 changed repository interfaces, new models, shared-widget promotion touching part 1 screens, account-deletion and block flows on mock data)
- Current status: CLOSED
- Current step: CLOSURE
- Approval: APPROVED
- Outcome: COMPLETED
- Version: 1.0
- Created date: 2026-11-23
- Last updated date: 2026-11-23 (closed)
- Started date: 2026-11-23
- Completed date: 2026-11-23
- Developer owner: Repository owner (developer) — owner and manual tester
- Dependency phases: PHASE_002_UI_ADD_FULL_APP_DESIGN_MOCK_DATA

## Requirement

- Original developer request: "Create part 2 phase" (2026-11-23) — the second half of the request recorded in PHASE_002: build the full application UI to match the owner's design canvas 100 %, with the design's icons/images, custom reusable components, professional mock data from models, enums for selections, UI only (no backend, no real-time data), filters/search/selections working on mock data.
- Business objective: Complete, navigable, design-accurate app for review and demos on Android and iOS, on the same data layer the backend phases will plug into. DECIDED
- Expected outcome: Every remaining artboard is built in Flutter on in-memory mock data: Teachers/Students tabs with search, filters and visibility rules; public profiles; connect requests; My connections; Home search results; Chats and Chat; Notifications; unread badges; role-aware second tab; My profile and Edit profile for both roles; Settings with every sub-screen and sheet; remaining empty and loading states. The Home avatar, Home search and sign-up Terms/Privacy links reach their real screens.
- Acceptance criteria (proposed; confirm at approval):
  1. Each in-scope artboard (29, listed under Analysis) has a Flutter screen, sheet or state whose layout, spacing, sizes, colors, typography, radii, icons and copy match the artboard at 390×844 in light mode (20d at its 390×1340 scroll height), checked side by side by the developer.
  2. All data comes from professional mock model objects; no test/placeholder text.
  3. New selectable values are enums with ARB labels (connection status, notification type, experience filter, sort order).
  4. Working on in-memory mock data (resets on restart):
     - Teachers (student view) / Students (teacher view): search by name, headline and subjects; filter sheets with live result count and active-filter chips; Reset; teacher fee filter "Monthly fee $10 – $100" (all fees in USD per month); default sort "verified + most complete first", students "newest first".
     - Visibility (plan section 7): teachers listed only when ≥ 80 % complete and verified; students only when "Looking for a teacher" is on and ≥ 60 %; sending a request needs the sender's own profile ≥ 60 %; student photos never in the Students list; blocked people hidden everywhere.
     - Connect sheet with 200-character note → request appears under Sent; mock teacher accounts can accept/decline under Requests and in Notifications; accepted → chat opens; remove connection.
     - Chats list with unread counts; Chat: send text (appended with "sent" ticks), image message from a sample, day dividers; opening a chat marks it read.
     - Notifications: New / Earlier, Accept / Decline on requests, Mark all read, grouped likes; tapping an item opens its target.
     - Bottom-bar badges show the mock unread counts; second tab reads "Teachers" for students and "Students" for teachers.
     - My profile and Edit profile (both roles) save to the mock profile; strength % updates. Teacher Edit profile and Teacher setup step 3 have a "Qualifications" text field under Experience; the strength item "Experience + qualifications" needs years **and** that text (a certificate stays its own item).
     - Public profile: Message is enabled only for accepted connections; otherwise disabled with the hint "Connect first to send a message".
     - Settings: notification switches, Change password (rules), Blocked users with Unblock and empty state, Content / Privacy / Terms pages, Log out sheet, Delete account sheet.
     - Home search results (All / Teachers / Posts).
  5. No network, Supabase, Firebase, Dio or real auth.
  6. Dark mode renders every new screen from the tokens.
  7. All UI strings in `app_en.arb`; direction-neutral layouts.
  8. `flutter analyze` clean; new logic, cubits and screen flows tested; all tests pass.
  9. SOLID per `CLAUDE.md`: screens/cubits never import mocks; mocks registered by interface type only in `lib/main.dart`.

## Analysis

- Design source (canvas version `1795151725-6615`, listed 2026-11-23): 47 artboards; file sizes identical to version `1795090178-e295` read in PHASE_002, so the saved copies are used. Icons, illustrations and logos needed by part 2 were already exported in PHASE_002 (`assets/icons/` includes globe, user, read_ticks, send, image, calendar, clock, share, key, ban, document, log_out, trash, sliders, map_pin…). VERIFIED (sizes) / re-check at execution start.
- In-scope artboards (29):
  - Find & connect: 11 Teachers list · 13 Filter sheet (teachers) · 14 Public profile (teacher) · 15 Connect sheet · 12 Students list (teacher view) · 13b Student filter sheet · 14b Public profile (student) · 16 My connections (Connected / Requests / Sent) · 08b Home search results (All / Teachers / Posts).
  - Chats & notifications: 17 Chats list · 18 Chat conversation (bubbles, day divider, Zoom link, image message, read ticks, composer) · 19 Notifications (New / Earlier; request with note + Accept / Decline; accepted; comment; teacher approved; grouped likes; Mark all read).
  - Me & settings: 20a My profile (student) · 20c My profile (teacher) · 20b Edit profile (student) · 20d Edit profile (teacher, 390×1340) · 21 Settings · 21a Change password · 21b Blocked users · 21b-empty Blocked users empty · 21c Content policy · 21d Privacy policy · 21e Terms of use · 21f Delete account sheet · 21g Log out sheet.
  - States: 23 Empty states (chats, notifications, connections, search) · 24 Loading states (teacher card, chat rows).
- Current behavior (VERIFIED, PHASE_002 closed, commit `faa7b13`): Teachers, Chats and Alerts tabs are PHASE_001 placeholders (`DiscoverScreen`, `ChatsScreen`, `NotificationsScreen`); Home avatar opens setup, Home search opens Teachers; sign-up Terms/Privacy links are not tappable; bottom bar has no badges and always says "Teachers". Existing data layer: `Profile`, `TeacherDetails`, `StudentDetails`, `Post`, `Comment`; `AuthRepository`, `ProfileRepository`, `FeedRepository`, `SafetyRepository` (+ mocks); `SessionCubit`; `ProfileStrengthCalculator`.
- Root cause / gap: the screens, their models, repositories and mock data do not exist yet.
- End-to-end flow (target, mock): screens → cubits → `DiscoverRepository` / `ConnectionRepository` / `ChatRepository` / `NotificationRepository` / `ProfileRepository` / `SafetyRepository` / `AuthRepository` interfaces → mock implementations (in memory, streams) → registered by interface type in `lib/main.dart`. A shell-level `ShellBadgesCubit` combines unread chats and notifications for the bottom bar.
- Design findings (VERIFIED from artboards):
  - 20c My profile (teacher) says "Your profile is 90% complete — Add your qualifications to reach 100%". Plan section 7 weights "Experience + qualifications" together (10 %), but the PHASE_002 calculator counts experience only. → `ProfileStrengthCalculator` must require experience **and** qualifications (bug fix to match the plan). The teacher Edit profile artboard (20d) has **no qualifications field** → DECIDED (answer 1): add a "Qualifications" text field (new `TeacherDetails.qualifications`).
  - Mock teachers have no `photoPath`, so after that fix most would fall under the 80 % listing threshold. → teacher seed data gets photo paths (avatars still show initials, as in the design) and qualifications, except where the design shows a missing item (Qari Ahmed: no qualifications → 90 %).
  - 13 Filter sheet: "Monthly fee PKR 2,000 – 10,000" range slider; some mock teachers charge GBP, CAD or AED per class/month → DECIDED (answer 2): every fee in USD per month; filter "$10 – $100 per month"; part 1 "Fee (PKR)" becomes "Fee (USD)" (approved design deviation).
  - 21b Blocked users shows block dates; 21a Change password has "Different from your current password"; 21f Delete account lists what is deleted plus a confirm checkbox.
  - Public profile has both Connect and Message; plan section 4 allows chat only after a connection is accepted → DECIDED (answer 3): disabled with a hint until accepted.
  - Legal texts on 21c/21d/21e were written by the design tool (owner review needed before launch).
- Existing reusable components (PHASE_002): `AppIcon`, `AppButton`, `AppTextField`, `AppTextArea`, `AppChip`, `TagChip`, `AppAvatar`, `VerifiedBadge`, `AppCheckbox`, `SectionLabel`, `BackHeader`, `AppBottomSheet`, `StepProgressHeader`, `NumberedStepper`, `OtpInput`, `ProfileStrengthCard`, `PostCard`, `EmptyStateView`, `SkeletonBox`, `PostCardSkeleton`, `MainShell`; feature widgets `RoleCard`, `InfoNote`, `WeekdayPicker`, `PhotoPickerTile`, `UploadTile`, `CommentTile`, `CommentComposer`, `HomeTopBar`. Screen-local private widgets in part 1 that part 2 also needs: segmented control, radio option tile, design switch, info box (missing info 4).
- Lifecycle: cubits per route, stream subscriptions cancelled in `close()`; chat composer and search controllers disposed.
- Permissions / native / Supabase / RLS / push: none. Visibility and block rules are applied in mock repositories through logic classes, mirroring the RLS the backend phase will write.
- Both roles: second tab and its list depend on the session role; My profile / Edit profile have student and teacher variants; Requests tab and Accept/Decline are exercised with the mock teacher account.
- Security: no secrets or network. Delete account removes the mock account's data from memory and signs out (missing info 5). Report/block remain mock-only.

### Design Against The SOLID Checklist

- S: list filtering in `TeacherFilter` / `StudentFilter` logic; visibility in `DiscoverVisibilityRules`; note limit in `ConnectNoteRules`; cubits only coordinate.
- O: new repositories are added beside the existing ones; existing interfaces gain methods only where the design needs them (approval).
- L: every new mock honours its documented contract; failures only `*Failure`.
- I: four small new interfaces (discover, connection, chat, notification); no fat "social" repository.
- D: cubits receive interfaces by constructor; mocks created only in `lib/main.dart`.

## Scope

- In scope: the 29 artboards above, their navigation, the Home avatar / Home search / Terms-Privacy link destinations, bottom-bar badges and role-aware second tab, models, repositories, mock data, logic, cubits, widgets, strings, tests and docs.
- Explicitly out of scope: backend, real auth, persistence, push notifications, real-time updates, camera/gallery/file pickers, deep links, launcher icons, Urdu/Arabic translations, golden tests, design-canvas changes.
- Files expected to change (existing):
  - `lib/main.dart` (register 4 new mock repositories), `lib/core/router/app_routes.dart`, `lib/core/router/app_router.dart` (new routes), `lib/core/widgets/main_shell.dart` (badges, role-aware tab).
  - `lib/core/logic/profile_strength_calculator.dart` (experience **and** qualifications text; hint "Add your qualifications to reach 100%").
  - `lib/data/models/teacher_details.dart` (add `qualifications` text; default `feeCurrency` `USD`). **Shared model change — approval.**
  - `lib/features/profile_setup/presentation/teacher_setup_screen.dart` + `teacher_setup_cubit.dart` (Qualifications field under Experience, Bio style; fee label reads USD).
  - `lib/data/repositories/auth_repository.dart` + mock (add `changePassword`, `deleteAccount`), `lib/data/repositories/safety_repository.dart` + mock (add `watchBlockedUsers` with dates, `unblockUser`). **Interface changes — approval.**
  - `lib/data/mock/mock_profiles.dart` (teacher photo paths, qualifications, all fees USD per month), `lib/data/repositories/mock/mock_profile_repository.dart` (account deletion support).
  - `lib/features/discover/presentation/discover_screen.dart`, `chat/presentation/chats_screen.dart`, `notifications/presentation/notifications_screen.dart` (placeholders replaced); `feed/presentation/home_screen.dart` (avatar → My profile, search → results); `auth/presentation/sign_up_screen.dart` (Terms/Privacy links).
  - Answer 4 (yes): `profile_setup/presentation/teacher_setup_screen.dart`, `student_setup_screen.dart`, `safety/presentation/report_sheet.dart`, `auth/presentation/email_code_screen.dart`, `forgot_password_screen.dart` switch to the promoted shared widgets (behaviour unchanged).
  - `lib/l10n/app_en.arb` (+ generated), tests, docs (`ARCHITECTURE`, `DIRECTORY_STRUCTURE`, `NAVIGATION`, `COMMON_COMPONENTS`, `STATE_MANAGEMENT`, `API_REFERENCE`, `DATABASE_AND_CACHE`, `FILE_CATALOG`, `TESTING_GUIDE`, `KNOWN_ISSUES`, `PROJECT_OVERVIEW`).
- Files that must not change: `docs/product/*`, `android/**`, `ios/**`, `pubspec.yaml` dependencies (no new packages), `analysis_options.yaml`, `assets/**`, theme token values, `CLAUDE.md`, skill files.
- Proposed new files (approval requested):

  | Group | Count | Paths / classes |
  |---|---|---|
  | Enums | 4 | `lib/data/models/enums/`: `ConnectionStatus` (pending, accepted, declined, removed), `NotificationType` (connectionRequest, requestAccepted, comment, likes, teacherApproved, teacherNeedsChanges), `ExperienceFilter` (any, twoPlus, fivePlus, tenPlus), `DiscoverSort` (recommended, newest) |
  | Models | 5 | `lib/data/models/`: `Connection`, `Conversation`, `Message`, `AppNotification`, `NotificationSettings` (+ `BlockedUser` record type inside `safety_repository.dart`) |
  | Repository interfaces | 4 | `lib/data/repositories/{discover,connection,chat,notification}_repository.dart` (provisional contracts) |
  | Mock implementations | 4 | `lib/data/repositories/mock/mock_{discover,connection,chat,notification}_repository.dart` |
  | Mock seed data | 3 | `lib/data/mock/{mock_connections,mock_chats,mock_notifications}.dart` |
  | Logic | 4 | `lib/core/logic/discover_visibility_rules.dart`; `lib/features/discover/logic/{teacher_filter,student_filter}.dart`; `lib/features/connections/logic/connect_note_rules.dart` |
  | Shared widgets | 13 | `lib/core/widgets/`: `SearchField`, `CountBadge`, `SettingsTile`, `AppSwitchTile`, `ProfileHeader`, `InfoRow` (icon + text line), `TeacherCardSkeleton`, `ChatRowSkeleton`, `ConfirmSheet` (log-out / delete pattern). Promoted (answer 4): `AppSegmentedControl`, `AppOptionTile`, `AppSwitch`, `AppInfoNote` |
  | Feature widgets | ≈ 16 | discover: `TeacherCard`, `StudentCard`, `FilterChipsBar`, `FeeRangeSlider`, `PersonRow`; connections: `ConnectionTile`, `RequestTile`; chat: `ConversationTile`, `ChatBubble`, `ChatImageBubble`, `DayDivider`, `MessageComposer`, `ChatHeader`; notifications: `NotificationTile`, `RequestNotificationTile`; profile: `CertificateRow` |
  | Cubits + states | ≈ 30 | `DiscoverCubit` (teachers / students mode, search, filters), `PublicProfileCubit`, `ConnectRequestCubit`, `ConnectionsCubit`, `SearchCubit`, `ChatsCubit`, `ChatCubit`, `NotificationsCubit`, `ShellBadgesCubit`, `MyProfileCubit`, `EditProfileCubit`, `SettingsCubit`, `ChangePasswordCubit`, `BlockedUsersCubit`, `DeleteAccountCubit` (each `_cubit.dart` + `_state.dart`) |
  | Screens / sheets | 15 new + 3 replaced | discover: `DiscoverScreen`* (Teachers/Students), `TeacherFilterSheet`, `StudentFilterSheet`, `PublicProfileScreen` (teacher and student layouts), `SearchResultsScreen`; connections: `ConnectSheet`, `ConnectionsScreen`; chat: `ChatsScreen`*, `ChatScreen`; notifications: `NotificationsScreen`*; profile: `MyProfileScreen`, `EditProfileScreen` (teacher and student layouts); settings: `SettingsScreen`, `ChangePasswordScreen`, `BlockedUsersScreen`, `PolicyScreen` (content / privacy / terms), `LogOutSheet`, `DeleteAccountSheet` (* replaces placeholder) |
  | Tests | ≈ 10 | filters and visibility logic, connect-note rules, strength fix, new mocks, all new cubits, screen flows (discover + filters, connect → accept → chat, notifications, settings sub-screens, delete account, both roles) |

  Total ≈ 125 new files plus ≈ 25 modified.
- Dependency changes: None (uses `flutter_bloc`, `flutter_svg`, `equatable`, `intl`, `go_router` already approved).
- API contract changes (approval requested): 4 new provisional interfaces; `TeacherDetails.qualifications`; `AuthRepository` + `changePassword`, `deleteAccount`; `SafetyRepository` + `watchBlockedUsers`, `unblockUser`.
- Native changes: None. Supabase changes: None.
- Approval requirements: High risk. Explicit approval for every group above, the 2 interface changes, the strength-calculator fix, the seed-data change and the decisions below.

## Developer Answers (2026-11-23)

No missing information remains.

| # | Question | Answer (DECIDED) |
|---|---|---|
| 1 | Teacher qualifications field | Developer first proposed "text field or uploaded file". Agreed refinement (so one upload does not count twice and the 20c "Add your qualifications" state stays): add a "Qualifications" text field under Experience in teacher Edit profile and Teacher setup step 3, Bio style; only that text (with experience years) completes "Experience + qualifications" (10 %); the certificate upload stays its own 10 % item. Qari Ahmed's seed has no qualifications → 90 %. |
| 2 | Fee currency | US dollars only, worldwide. Every mock fee becomes USD per month; teacher filter "Monthly fee $10 – $100"; part 1 "Fee (PKR)" becomes "Fee (USD)". Approved deviation from the canvas (which shows PKR). |
| 3 | Message before connecting | Yes — visible but disabled with "Connect first to send a message" until the request is accepted. |
| 4 | Promote part 1 private widgets | Yes — `AppSegmentedControl`, `AppOptionTile`, `AppSwitch`, `AppInfoNote` in `lib/core/widgets/`; the 5 part 1 files switch to them, behaviour unchanged. |
| 5 | Mock delete account | Yes (as recommended): removes the account's profile, posts, comments, likes, connections, chats and notifications from memory, then signs out to Welcome; mock accounts return after restart. |
| 6 | Phase size | One phase, three checkpoints, no new phase: (1) find & connect → (2) chats & notifications → (3) me & settings. After each checkpoint: `flutter analyze` + `flutter test`, report changed files, **stop** until the developer says continue. Status stays `ACTIVE` / `EXECUTION` between checkpoints; fixes found at a checkpoint stay in this phase; `MANUAL_TEST` after checkpoint 3. |

## Readiness Checklist

- [x] Requirement is clear
- [x] Expected behavior is clear
- [x] Existing flow is traced
- [x] API is verified (not applicable — mock only)
- [x] Request contract is verified (not applicable)
- [x] Response contract is verified (not applicable)
- [x] Supabase tables, RLS and Storage policies are defined (not applicable; models mirror plan section 12)
- [x] Security, 18+ gate and moderation rules are unaffected or approved (visibility, block and delete flows on mock data only)
- [x] Required UI/design is available (qualifications field and USD fee derived per answers 1–2)
- [x] Existing reusable components are identified
- [x] Proposed files are identified
- [x] New files/classes are approved
- [x] Platform behavior is understood
- [x] Permissions are understood (none)
- [x] Dependencies are available (no new packages)
- [x] Risks are documented
- [x] Automated tests are defined
- [x] Manual tests are defined
- [x] Rollback plan is defined
- [x] Phase dependencies are completed (PHASE_002 closed)
- [x] Developer approval is recorded

## Risks

- Size (≈ 125 files): mitigated by three stop-and-report checkpoints (answer 6).
- USD change touches part 1 copy ("Fee (USD)") and differs from the canvas; recorded as an approved deviation.
- Interface changes on `AuthRepository` / `SafetyRepository` and four new provisional contracts — backend phases may refine them.
- Strength-calculator fix changes teachers' % and therefore who is listed; seed data is adjusted and tested.
- Shared-widget promotion touches 5 part 1 screens; widget tests from PHASE_002 guard their behaviour.
- Mock delete account must clean every store consistently (tested).
- Long legal copy in ARB was written by the design tool; legal review needed before launch.
- Flutter vs HTML rendering differences, as in PHASE_002.

## Test Plan

- Automated: `flutter gen-l10n`, `dart format`, `flutter analyze`, `flutter test` — logic (filters, visibility, note rules, strength fix), mocks (discover visibility, connection lifecycle, chat send/read, notification read/accept, block/unblock, delete account), cubits, screen flows for both roles; PHASE_002 tests stay green.
- Manual (developer, Android + iOS, light and dark): student — Teachers search/filters/chips/Reset → public profile → Connect with note → Sent; teacher account — Students list/filters → Requests → Accept → Chats → Chat send text and image → Notifications (Accept/Decline, Mark all read, tap through) → badges; both roles — My profile, Edit profile save, Settings switches, Change password, Blocked users (Unblock, empty), Content/Privacy/Terms, Log out, Delete account; Home search results; compare every screen with its artboard.

## Rollback Plan

Local Dart, ARB, docs and tests only; no native, data or remote effects. Revert the phase commit (or restore modified files and delete new ones before commit) and run `flutter pub get`; PHASE_002 behaviour returns.

## Implementation

- Approved implementation plan: Approved 2026-11-23 by the developer (repository owner) with the explicit request "APPROVE PHASE: PHASE_003_UI_ADD_FULL_APP_DESIGN_MOCK_DATA_PART_TWO". The approval covers the Scope section exactly as written: the 29 in-scope artboards and their navigation; 4 enums, 5 models and the `BlockedUser` record; 4 new provisional repository interfaces (`DiscoverRepository`, `ConnectionRepository`, `ChatRepository`, `NotificationRepository`) with mock implementations and 3 seed-data files; the interface changes `AuthRepository` + `changePassword`, `deleteAccount` and `SafetyRepository` + `watchBlockedUsers`, `unblockUser`; the shared model change `TeacherDetails.qualifications` and default `feeCurrency` `USD`; the `ProfileStrengthCalculator` fix (experience **and** qualifications text); teacher seed data (photo paths, qualifications, USD per month); 4 logic files; 13 shared widgets (9 new + 4 promoted from part 1, with the 5 part 1 files switched to them, behaviour unchanged); ≈ 16 feature widgets; ≈ 15 cubits with states; 15 new and 3 replaced screens/sheets; Teacher setup Qualifications field and "Fee (USD)"; router, shell badges and role-aware tab; ARB strings; tests; and the listed doc updates. Execution runs in three stop-and-report checkpoints (answer 6). Anything outside this list needs new approval (step `APPROVAL`, approval `PENDING`). No new packages, no native, Supabase or Firebase changes, no golden tests.
- Implementation log:
  - 2026-11-23 Execute start: readiness OK, no other active phase. Git baseline: branch `PHASE_002_UI_ADD_FULL_APP_DESIGN` at `d55b393` (developer did not create a new branch; work continues on this branch, recorded). Pre-existing uncommitted changes: this phase file, `PHASE_INDEX.md`, `PHASE_STATE.md` (phase docs only). Checkpoint 1 (find & connect) started.
  - 2026-11-23 Checkpoint 1 done (find & connect): answer-4 widget promotion; data layer (3 enums, `Connection`, `DiscoverRepository`, `ConnectionRepository` + mocks and seed); visibility / filter / note logic; strength fix + seed (photos, qualifications, USD per month); 5 shared widgets; 5 discover widgets + `RequestTile`; Discover, PublicProfile, ConnectRequest, Connections, Search cubits; Teachers/Students tab, both filter sheets, public profile (teacher + student), Connect sheet, My connections, Home search results; routes `/home/search`, `/profile/:id`, `/connections`; role-aware second tab; 105 strings. Checks: `flutter analyze` no issues; `flutter test` 77/77; `dart format` clean. Stopped for the developer (answer 6).
  - 2026-11-23 Developer: "Continue". Checkpoint 2 done (chats & notifications): `NotificationType`, `Conversation`, `Message`, `AppNotification`; `ChatRepository`, `NotificationRepository` + mocks and seed; `ChatsCubit`, `ChatCubit`, `NotificationsCubit`, `ShellBadgesCubit`; `ChatRowSkeleton`; 6 chat widgets, 2 notification widgets; Chats (search, unread rows, empty, skeleton), Chat (day dividers, "Connected N days ago", text / link / image bubbles, read ticks, composer, sample photo), Notifications (New / Earlier, Accept / Decline → chat, Mark all read, tap-through, empty); bottom-bar unread badges; route `/chat/:userId`; Message buttons from checkpoint 1 now open the chat; 37 strings. Checks: `flutter analyze` no issues; `flutter test` 88/88; `dart format` clean. Stopped for the developer.
  - 2026-11-23 Developer: "Continue". Checkpoint 3 done (me & settings): `AuthRepository` + `changePassword`, `deleteAccount`; `SafetyRepository` + `watchBlockedUsers` (`BlockedUser`), `unblockUser`; `NotificationSettings` + `NotificationRepository.watchSettings` / `updateSettings`; mock deletion helpers wired in `main.dart`; `SettingsTile`, `AppSwitchTile`, `ConfirmSheet`; `CertificateRow`; `MyProfileCubit`, `EditProfileCubit`, `SettingsCubit`, `ChangePasswordCubit`, `BlockedUsersCubit`, `DeleteAccountCubit`; My profile (both roles), Edit profile (both roles, teacher Qualifications field), Settings, Change password, Blocked users (+ empty), Content / Privacy / Terms, Log out sheet, Delete account sheet; Teacher setup step 3 Qualifications field; Home avatar → My profile; sign-up Terms / Privacy links; 100 strings; docs and `FILE_CATALOG.md` (223 rows) updated. Checks: `flutter analyze` no issues; `flutter test` 98/101 — the 3 failures come from the developer's uncommitted edit of `MockAccounts` (see Out-of-scope findings); `dart format` clean. Status `ACTIVE`, step `MANUAL_TEST`.
- Exact changed files: None
- Purpose of every changed file: None
- Existing components reused: see Analysis.
- New approved components: None
- Out-of-scope findings:
  - A new Git branch for this phase was recommended; execution continues on `PHASE_002_UI_ADD_FULL_APP_DESIGN` (developer did not create one).
- Checkpoint 1 notes (design deviations / decisions inside scope):
  - Fees show US dollars per answer 2 (canvas shows PKR); the fee filter is "$10 – $100".
  - `ValidationReason` gained `connectNoteTooLong`, `profileIncomplete`, `alreadyConnected` (needed by the approved `ConnectionRepository` contract).
  - Mock helpers added inside mock files only: `MockProfileRepository.all` / `changes`, `MockSafetyRepository.changes` / `blockedEitherWay`, `MockConnectionRepository.acceptedIdsOf` / `removeUser`.
  - `AppAvatar` keeps its 18 px verified badge on the 88 px profile avatar (design: 26 px) and its id-based tint for student initials (design: neutral grey) — changing the shared avatar was not approved.
  - The small 24 px detail chip is a private widget in 3 files (teacher card, student card, public profile); promoting it to a shared widget would need approval.
  - (Resolved in checkpoint 2) Message buttons now open the chat. My connections is reachable from My profile in checkpoint 3 (tested through its route now).
- **Pre-existing developer change (not made by this phase, not reverted):** `lib/data/mock/mock_profiles.dart` `MockAccounts.studentEmail` and `teacherEmail` were both changed to the same address `farhan@gmail.com` (uncommitted, found 2026-11-23 during checkpoint 3). With one email for both accounts, logging in always opens Qari Ahmed (teacher); Ayesha (student) cannot be reached by log-in. 3 tests that log in by those emails fail (`mock_data_test` "mock accounts keep their role", `cubits_test` "PasswordResetCubit…", `screens_test` "Log in as Ayesha…"). `TestApp.startSignedIn` now signs in by profile id so the other screen tests are unaffected. Developer decision needed: restore the two emails or keep the change (then those 3 tests need updating).
- Checkpoint 3 notes:
  - `PasswordRules.differs` added (artboard 21a rule "Different from your current password"); `ValidationReason.passwordUnchanged`.
  - Teacher setup country / time-zone lists made public top-level constants (`profileCountries`, `profileTimeZones`) and reused by Edit profile (no duplicate lists).
  - "Forgot your current password?" asks to confirm, logs out and opens the reset flow (the reset screens are signed-out routes).
  - My posts shows the latest 3 own posts (no separate "all my posts" screen is in the design list, so "See all" is not shown).
  - Policy routes are reachable signed in or out (sign-up consent links); `PolicyPage` enum lives in `policy_screen.dart`.
  - Seed has no blocked users; the canvas shows three sample names that are not mock profiles.
  - Student Edit profile follows 20b (name, gender, age group, country, time zone, goals, note); level / languages / preference stay editable in setup.
- Checkpoint 2 notes:
  - `ValidationReason` gained `notConnected`, `messageEmpty` (approved `ChatRepository` contract).
  - `ShellBadgesCubit` / state live in `lib/core/session/` (shell-level, next to `SessionCubit`).
  - Seed connection Ayesha → Qari Ahmed moved to 3 days ago so the chat shows "Connected 3 days ago" (artboard 18).
  - Chat list rows follow artboard 17; the design's Hira / Sana rows are student-to-student chats, which the seed does not have — Ayesha's 3 chats are her 3 teacher connections (Qari Ahmed's are Ayesha, Hira, Yusuf).
  - Links in chat copy to the clipboard ("Link copied"): no URL-launcher package is approved.
  - Chat options (⋯) opens the other person's profile, where block lives.
  - Time and day labels are private helpers in `ConversationTile`, `NotificationTile` and `ChatScreen` (the shared `RelativeTimeFormatter` format differs: "58m" vs "10 min ago").
  - Report-sheet `_ReasonTile` and the forgot-password screen did not use the 4 promoted widgets, so they were not changed.
- Unexpected risks: None

## Change Log

Checkpoint 1 (find & connect). All paths are in approved groups.

| File | Type | Approved | What / why | Preserved / risk |
|---|---|---|---|---|
| `lib/core/widgets/app_segmented_control.dart`, `app_option_tile.dart`, `app_switch.dart`, `app_info_note.dart` | added | yes (answer 4) | Promoted from part 1 private widgets (same code, public, `super.key`; `AppSwitch` gains `semanticLabel`) | Behaviour unchanged |
| `lib/features/profile_setup/presentation/teacher_setup_screen.dart`, `student_setup_screen.dart`, `lib/features/auth/presentation/email_code_screen.dart` | modified | yes (answer 4) | Use the promoted widgets; private copies removed | PHASE_002 screen tests green |
| `lib/features/auth/presentation/widgets/info_note.dart` | deleted | yes (answer 4) | Moved to `AppInfoNote` | — |
| `lib/data/models/enums/connection_status.dart`, `experience_filter.dart`, `discover_sort.dart` | added | yes | Selection enums with ARB labels | — |
| `lib/data/models/connection.dart` | added | yes | Connection request model | — |
| `lib/data/repositories/discover_repository.dart`, `connection_repository.dart` | added | yes | Provisional contracts | Backend may refine |
| `lib/data/repositories/mock/mock_discover_repository.dart`, `mock_connection_repository.dart`, `lib/data/mock/mock_connections.dart` | added | yes | In-memory implementations and seed (accepted pairs = feed connections) | Reset on restart |
| `lib/data/repositories/mock/mock_profile_repository.dart`, `mock_safety_repository.dart` | modified | yes | Mock helpers for the new mocks | Interfaces unchanged |
| `lib/core/errors/failures.dart` | modified | yes (contract) | 3 `ValidationReason` values for connection requests | Additive |
| `lib/core/logic/profile_strength_calculator.dart` | modified | yes | Experience item needs years **and** qualifications | Teachers without qualifications drop 10 % |
| `lib/data/models/teacher_details.dart` | modified | yes | Default currency `USD` (field `qualifications` already existed) | — |
| `lib/data/mock/mock_profiles.dart` | modified | yes | Teacher photo paths, qualifications (not Qari Ahmed → 90 %), all fees USD per month | Feed and Home unchanged |
| `lib/core/logic/discover_visibility_rules.dart`, `lib/features/discover/logic/teacher_filter.dart`, `student_filter.dart`, `lib/features/connections/logic/connect_note_rules.dart` | added | yes | Plan section 7 rules, filters, note limit | Pure Dart, tested |
| `lib/core/widgets/search_field.dart`, `count_badge.dart`, `info_row.dart`, `profile_header.dart`, `teacher_card_skeleton.dart` | added | yes | Shared widgets from the artboards | — |
| `lib/features/discover/presentation/widgets/teacher_card.dart`, `student_card.dart`, `filter_chips_bar.dart`, `fee_range_slider.dart`, `person_row.dart`; `lib/features/connections/presentation/widgets/request_tile.dart` | added | yes | Feature widgets | — |
| `lib/features/discover/bloc/*` (discover, public_profile, search), `lib/features/connections/bloc/*` (connect_request, connections) | added | yes | 5 cubits + states; subscriptions cancelled in `close()` | — |
| `lib/features/discover/presentation/discover_screen.dart` | modified | yes | Placeholder replaced: Teachers / Students list, search, filters, chips, skeletons, empty state | — |
| `lib/features/discover/presentation/teacher_filter_sheet.dart`, `student_filter_sheet.dart`, `public_profile_screen.dart`, `search_results_screen.dart`; `lib/features/connections/presentation/connect_sheet.dart`, `connections_screen.dart` | added | yes | Artboards 13, 13b, 14, 14b, 08b, 15, 16 | — |
| `lib/core/router/app_routes.dart`, `app_router.dart` | modified | yes | `/home/search` (inside Home tab), `/profile/:id`, `/connections` | Existing routes unchanged |
| `lib/core/widgets/main_shell.dart` | modified | yes | Second tab reads "Students" for teachers | — |
| `lib/features/feed/presentation/home_screen.dart` | modified | yes | Search opens search results | Avatar still opens setup until checkpoint 3 |
| `lib/main.dart`, `test/helpers/test_app.dart` | modified | yes | Register `DiscoverRepository`, `ConnectionRepository` mocks by interface | — |
| `lib/l10n/app_en.arb` (+ generated `app_localizations*.dart`) | modified / generated | yes | 105 strings; experience hint text | — |
| `test/core/logic/profile_strength_calculator_test.dart` | modified | yes | Complete teacher has qualifications; new fix tests (Qari Ahmed 90 %) | — |
| `test/features/discover_connect_test.dart` | added | yes | 18 tests: logic, mocks, cubits, screen flows for both roles | — |

Checkpoint 2 (chats & notifications). All paths are in approved groups.

| File | Type | Approved | What / why | Preserved / risk |
|---|---|---|---|---|
| `lib/data/models/enums/notification_type.dart`; `lib/data/models/conversation.dart`, `message.dart`, `app_notification.dart` | added | yes | Enum and 3 models | — |
| `lib/data/repositories/chat_repository.dart`, `notification_repository.dart` | added | yes | Provisional contracts (chat only between accepted connections) | Backend may refine |
| `lib/data/repositories/mock/mock_chat_repository.dart`, `mock_notification_repository.dart`; `lib/data/mock/mock_chats.dart`, `mock_notifications.dart` | added | yes | In-memory implementations and seed | Reset on restart |
| `lib/data/mock/mock_connections.dart` | modified | yes | Ayesha → Qari Ahmed accepted 3 days ago | Feed order unchanged |
| `lib/core/errors/failures.dart` | modified | yes (contract) | `notConnected`, `messageEmpty` | Additive |
| `lib/core/session/shell_badges_cubit.dart`, `shell_badges_state.dart` | added | yes | Unread chats + notifications for the bottom bar | — |
| `lib/core/widgets/chat_row_skeleton.dart` | added | yes | Loading row (artboard 24) | — |
| `lib/core/widgets/main_shell.dart` | modified | yes | Red badges on Chats / Alerts (value read out by screen readers) | Tab labels unchanged |
| `lib/features/chat/bloc/*` (chats, chat), `lib/features/notifications/bloc/*` | added | yes | 3 cubits + states; subscriptions cancelled in `close()`; chat marks read while open | — |
| `lib/features/chat/presentation/widgets/conversation_tile.dart`, `chat_bubble.dart`, `chat_image_bubble.dart`, `day_divider.dart`, `message_composer.dart`, `chat_header.dart` | added | yes | Artboards 17 / 18 | — |
| `lib/features/notifications/presentation/widgets/notification_tile.dart`, `request_notification_tile.dart` | added | yes | Artboard 19 | — |
| `lib/features/chat/presentation/chats_screen.dart`, `lib/features/notifications/presentation/notifications_screen.dart` | modified | yes | Placeholders replaced | — |
| `lib/features/chat/presentation/chat_screen.dart` | added | yes | Artboard 18 | — |
| `lib/core/router/app_routes.dart`, `app_router.dart` | modified | yes | `/chat/:userId` | — |
| `lib/features/discover/presentation/discover_screen.dart`, `public_profile_screen.dart`, `lib/features/connections/presentation/connections_screen.dart` | modified | yes | Message opens the chat | — |
| `lib/main.dart`, `test/helpers/test_app.dart` | modified | yes | Register `ChatRepository`, `NotificationRepository` mocks by interface | — |
| `lib/l10n/app_en.arb` (+ generated) | modified / generated | yes | 37 strings | — |
| `test/features/chat_notifications_test.dart` | added | yes | 11 tests: mocks, cubits, time labels, screen flows (chat, accept → chat, Mark all read, Message disabled before connecting) | — |

Checkpoint 3 (me & settings). All paths are in approved groups.

| File | Type | Approved | What / why | Preserved / risk |
|---|---|---|---|---|
| `lib/data/repositories/auth_repository.dart` + mock | modified | yes (interface change) | `changePassword`, `deleteAccount`; mock clears every store through an `onDelete` hook | Sign-in flows unchanged |
| `lib/data/repositories/safety_repository.dart` + mock | modified | yes (interface change) | `BlockedUser`, `watchBlockedUsers`, `unblockUser`; block dates; `removeUser` | `watchBlockedIds` unchanged |
| `lib/data/models/notification_settings.dart`; `notification_repository.dart` + mock | added / modified | yes | Settings switches stored per user | — |
| `lib/data/repositories/mock/mock_profile_repository.dart`, `mock_feed_repository.dart` | modified | yes | `remove` / `removeUser` for mock account deletion | — |
| `lib/core/errors/failures.dart`, `lib/features/auth/logic/password_rules.dart` | modified | yes | `passwordUnchanged`; `differs` rule | Additive |
| `lib/main.dart`, `test/helpers/test_app.dart` | modified | yes | Account deletion wiring; test sign-in by profile id | — |
| `lib/core/widgets/settings_tile.dart`, `app_switch_tile.dart`, `confirm_sheet.dart` | added | yes | Artboards 21 / 21f / 21g | — |
| `lib/features/profile/bloc/*`, `lib/features/settings/bloc/*` | added | yes | 6 cubits + states | — |
| `lib/features/profile/presentation/my_profile_screen.dart`, `edit_profile_screen.dart`, `widgets/certificate_row.dart` | added | yes | Artboards 20a–20d | — |
| `lib/features/settings/presentation/settings_screen.dart`, `change_password_screen.dart`, `blocked_users_screen.dart`, `policy_screen.dart`, `log_out_sheet.dart`, `delete_account_sheet.dart` | added | yes | Artboards 21–21g | — |
| `lib/features/profile_setup/presentation/teacher_setup_screen.dart`, `bloc/teacher_setup_cubit.dart`, `bloc/teacher_setup_state.dart` | modified | yes (answer 1) | Qualifications field in step 3; public country / time-zone lists | Other steps unchanged |
| `lib/features/auth/presentation/sign_up_screen.dart` | modified | yes | Terms / Privacy links open the policy pages | Consent checkbox unchanged |
| `lib/features/feed/presentation/home_screen.dart` | modified | yes | Avatar → My profile; Complete profile → Edit profile | — |
| `lib/core/router/app_routes.dart`, `app_router.dart` | modified | yes | `/me`, `/me/edit`, `/settings`, `/settings/password`, `/settings/blocked`, `/policy/:page` (allowed signed out) | Redirect otherwise unchanged |
| `lib/l10n/app_en.arb` (+ generated) | modified / generated | yes | 100 strings (incl. policy texts) | — |
| `test/features/profile_settings_test.dart` | added | yes | 13 tests: mocks, cubits, screen flows | — |
| `docs/ARCHITECTURE.md`, `DIRECTORY_STRUCTURE.md`, `NAVIGATION.md`, `COMMON_COMPONENTS.md`, `STATE_MANAGEMENT.md`, `API_REFERENCE.md`, `DATABASE_AND_CACHE.md`, `TESTING_GUIDE.md`, `KNOWN_ISSUES.md`, `PROJECT_OVERVIEW.md`, `FILE_CATALOG.md` (regenerated, 223 rows) | modified | yes | PHASE_003 facts | — |

## Execute Technical Checks

Checkpoint 1 (2026-11-23):

- `flutter gen-l10n` — OK.
- `dart format lib test` then `dart format --output=none --set-exit-if-changed lib test` — exit 0.
- `flutter analyze` — No issues found.
- `flutter test` — 77/77 passed (57 PHASE_002 + 20 new). A new test first caught a real accessibility assertion in `FeeRangeSlider` (missing increased/decreased values) — fixed.
- Source assertions — no mock imports in `lib/features` or `lib/core` widgets; no new hard-coded colours (only the pre-existing one in `app_icon.dart`); no Material icons; no Supabase/Dio.
- App not launched (not requested).

Checkpoint 2 (2026-11-23):

- `flutter gen-l10n` — OK. `dart format --output=none --set-exit-if-changed lib test` — exit 0.
- `flutter analyze` — No issues found.
- `flutter test` — 88/88 passed. The logout test first failed (badges read with no signed-in user) — fixed in `MainShell`.
- Source assertions — no mock imports in `lib/features` / `lib/core`; no new hard-coded colours or Material icons.
- App not launched (not requested).

Checkpoint 3 / final (2026-11-23):

- `flutter gen-l10n` — OK. `dart format --output=none --set-exit-if-changed lib test` — exit 0.
- `flutter analyze` — No issues found.
- `flutter test` — 98 passed, 3 failed (101). The 3 failures are caused by the developer's uncommitted `MockAccounts` email edit (both emails `farhan@gmail.com`), not by this phase; they pass with the original emails (they passed at checkpoint 2, before the edit).
- Source assertions — no mock imports in `lib/features` / `lib/core`; no new hard-coded colours or Material icons; no Supabase / Dio / new packages.
- App not launched (not requested).

## Manual Testing

- Ready for developer manual testing: No
- Developer manual-test confirmation: Not provided
- Manual-test notes requested by developer: None

## Closure

- Developer manual-test confirmation: "Tested and working fine" — developer, 2026-11-23 (explicit `CLOSE PHASE` request).
- Tested platforms: Not provided.
- Tested devices: Not provided.
- Failed and retested cases: None reported.
- Final changed files: every path in the Change Log (checkpoints 1–3), all in approved groups; uncommitted on branch `PHASE_002_UI_ADD_FULL_APP_DESIGN` (base `d55b393`).
- Technical checks at closure: implementation files had been reformatted / touched after Execute, so the cheap checks were rerun (2026-11-23):
  - `flutter analyze` — No issues found.
  - `flutter test` — 98 passed, 3 failed (101); the same 3 failures as at Execute, caused by the developer's `MockAccounts` email edit (below).
  - `dart format --output=none --set-exit-if-changed lib test` — exit 1, only `lib/features/onboarding/presentation/splash_screen.dart` (developer edit, below). All phase files are formatted.
- Pre-existing developer changes found at closure (not part of this phase, not changed or reverted):
  - `lib/data/mock/mock_profiles.dart`: `MockAccounts.studentEmail` and `teacherEmail` both `farhan@gmail.com` — log-in always opens Qari Ahmed; 3 email-based tests fail (`mock_data_test` "mock accounts keep their role", `cubits_test` "PasswordResetCubit…", `screens_test` "Log in as Ayesha…"). Decision 2026-11-23 (after closure): developer keeps the shared email. The 3 tests were updated as a scoped test fix (`mock_data_test` "the mock login email opens Qari Ahmed (teacher)", `cubits_test` expects Qari Ahmed, `screens_test` "Log in with the mock email: Qari Ahmed, strength 90%"). `flutter test` 101/101 passed. Ayesha (student) is reachable in tests through `TestApp.startSignedIn`, not through log-in.
  - `lib/features/onboarding/presentation/splash_screen.dart`: an empty `Row()`, `crossAxisAlignment: CrossAxisAlignment.center` and a trailing-space doc line — not formatted.
- Known limitations:
  - Mock data only: changes reset on restart; photo, chat photo and certificate actions attach samples; chat links copy instead of opening; Share profile copies text; change password is not stored; account deletion lasts until restart.
  - Fees in US dollars per month (owner decision; canvas shows PKR).
  - Policy texts from the design tool need owner / legal review before launch.
  - Design gaps kept: 18 px verified badge on large avatars (design 26 px); student initials use the avatar tint (design grey); 24 px detail chip private in 4 screens; no blocked users in the seed; My profile shows the latest 3 posts without "See all".
- Follow-up phases (suggested, not created): resolve the `MockAccounts` / splash edits; promote the detail chip to a shared widget (needs approval); Supabase backend (auth, profiles, discover with RLS, connections, chat with Realtime, notifications with FCM, storage for photos / certificates); launcher icons; image / file pickers; URL launcher for chat links.
- Rollback guidance: nothing is committed for this phase — restore the modified files listed in the Change Log and delete the new ones (or, after a commit, revert that commit) and run `flutter pub get`; PHASE_002 behaviour returns. No native, dependency, data or remote effects.
- Commit: not requested at closure. All phase changes are uncommitted.
- Final status: CLOSED / CLOSURE / COMPLETED
- Completion date: 2026-11-23
