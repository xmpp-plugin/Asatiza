# PHASE_001_FOUNDATION_ADD_PROJECT_FOUNDATION — Foundation: Project Foundation

## Identity

- Phase ID: PHASE_001_FOUNDATION_ADD_PROJECT_FOUNDATION
- Phase title: Project Foundation
- File name: PHASE_001_FOUNDATION_ADD_PROJECT_FOUNDATION.md
- Module: FOUNDATION
- Priority: High
- Risk level: High (production dependency, native app identifier, shared core theme/router)
- Current status: CLOSED
- Current step: CLOSURE
- Approval: APPROVED
- Outcome: COMPLETED
- Version: 1.0
- Created date: 2026-11-18
- Last updated date: 2026-11-19 (closed)
- Started date: 2026-11-19
- Completed date: 2026-11-19
- Developer owner: Repository owner (developer) — owner and manual tester
- Dependency phases: None

## Requirement

- Original developer request: "Create phase for foundation" (2026-11-18).
- Business objective: Replace the `flutter create` starter app with the decided Asatiza app skeleton so every later feature phase plugs into one structure, theme and navigation shell. Plan section 17, weeks 1–2: "Flutter structure, theme, 5-tab shell". DECIDED
- Design source (owner-provided 2026-11-18): Claude Design canvas "Asatiza App Design" — https://claude.ai/artifact/LUxhadrsA4EUF74spHVLLc — 27 phone artboards (390×844) covering all 22 plan screens, plus the "Asatiza" design system (`project/ds/asatiza/tokens.json`, source system https://claude.ai/artifact/5pS9UdhVVZfY71j8S81Cnv). Read-only reference; the canvas is not changed by this phase. VERIFIED (read 2026-11-18, version 1795006248-45c1)
- Expected outcome: The app launches as "Asatiza" into the designed bottom-navigation shell (Home · Teachers · centre + Post button · Chats · Alerts) with placeholder screens, using the Asatiza design-system theme, go_router and the decided directory layout, with the final app identifier and passing tests.
- Acceptance criteria (proposed; confirm at approval):
  1. App label is "Asatiza" on the device home screen on Android and iOS.
  2. Launch shows the Home tab inside the shell. The bottom bar matches the Home artboard: Home · Teachers · raised round centre "+" button (56 px, `brand-600`) · Chats · Alerts; the active tab shows a `brand-100` pill behind its icon and a `brand-700` bold label.
  3. Tapping each of the 4 tabs shows its placeholder screen; switching tabs keeps each tab's own navigation stack (go_router `StatefulShellRoute`). Tapping the centre "+" opens the Create post placeholder as a full-screen route over the current tab, with a close action.
  4. Android system back on a non-Home tab returns to Home; on Home it exits the app; on Create post it closes Create post.
  5. All colors, text styles, spacing, radii and shadows come from `lib/core/theme/`, mapped 1:1 from the design-system tokens; no hard-coded values in feature screens.
  5a. The app follows the phone's light/dark setting and both match the design tokens; fonts render offline (Fraunces, Plus Jakarta Sans, Amiri) and their OFL licenses appear on the licenses page.
  5b. Every visible string comes from `app_en.arb`; placeholder titles match the artboards (Teachers, Chats, Notifications, New post).
  6. Android `applicationId`/`namespace` and iOS bundle ID equal `com.asatiza.app`; the app builds and starts on Android, and on iOS when a Mac is available (missing info 13).
  7. `flutter analyze` reports no new issues; `flutter test` passes with the new app/router tests; the starter counter app and test are gone.
  8. No Supabase, Firebase, Dio, auth or feature logic is added.

## Analysis

- Current behavior: `lib/main.dart` is the unmodified `flutter create` counter app (`MyApp` → `MaterialApp(theme: ColorScheme.fromSeed(Colors.deepPurple))` → `MyHomePage` with `setState`). `test/widget_test.dart` is the counter smoke test. VERIFIED
- Expected behavior: See acceptance criteria. DECIDED by plan sections 5 (navigation), 11 (folder structure) and 17 (timeline), owner decisions in `docs/KNOWN_ISSUES.md` (BLoC, Dio, SOLID), and the owner's design canvas.
- Design tokens to implement (VERIFIED from `tokens.json`):
  - Colors (light / dark): `surface-000` #ffffff / #1a2220 · `surface-100` #f7f4ec / #121816 (page background) · `surface-200` #efe9dc / #232d2a · `line` #e2dac8 / #2f3a36 · `ink` #1c2421 / #eef2ef · `ink-muted` #5b6661 / #a3b0aa · `brand-700` #0b4a3c / #6cc9a8 · `brand-600` #0f5e4c / #3fae8c (primary, centre Post button) · `brand-100` #dcefe8 / #173a31 · `on-brand` #ffffff / #0b1a15 · `gold-500` #c8962e / #e0b354 · `gold-700` #8a6212 / #e6c27a · `gold-100` #f6ecd4 / #3a2f17 · `on-gold` #2a1d03 · `danger` #b42318 / #f07167 · `danger-100` #fde8e6 / #3d1c1a · `on-danger` #ffffff / #1a0605 · `success` = `brand-600` · `scrim` rgba(16,24,21,0.45) / rgba(0,0,0,0.6).
  - Fonts: display "Fraunces" (600), interface "Plus Jakarta Sans" (400/500/600/700), Arabic "Amiri" (400, always RTL, never italic).
  - Text styles: `display-lg` 32/38 w600 · `display-md` 26/32 w600 · `title-lg` 20/26 w700 · `title-md` 17/24 w600 · `body-lg` 16/24 w400 · `body` 14/20 w400 · `label` 14/20 w600 · `caption` 12/16 w500 · `quran` 24/44 w400 (Amiri).
  - Spacing: 4 · 8 · 12 · 16 (screen margin) · 20 · 24 · 32 · 48 (min touch target). Radius: sm 8 · md 12 · lg 16 · xl 24 · pill 999. Shadows: `shadow-card` 0 1 2 rgba(28,36,33,0.06) (none in dark) · `shadow-raised` 0 8 24 rgba(28,36,33,0.12) / rgba(0,0,0,0.5).
- Shell layout from the Home artboard: bottom bar 80 px on `surface-000` with a 1 px `line` top border; tabs 68 px wide, 22 px stroke icons, `caption` labels; active tab = 52×30 `brand-100` pill + `brand-700` bold label, inactive = `ink-muted`; centre "+" = 56 px `brand-600` circle raised 22 px above the bar with `shadow-raised` and a 4 px `surface-000` ring; unread badges (`danger`, 18 px) on Chats and Alerts — badges are shown only when a count exists (none in this phase). Home (only) has a 64 px top bar: 40 px avatar (→ My profile) + pill search field — part of the Home screen, not the shell. Teachers/Chats/Notifications headers: 24 px / 700 title (+ search field on Teachers and Chats, "Mark all read" on Notifications — later phases). Create post: 56 px header, Close (44 px) + "New post" 18 px / 700 + Post button (later), no bottom bar.
- Root cause or implementation gap: None of the decided structure exists: no `lib/core`, `lib/data`, `lib/features`, no router, no theme, placeholder app ID `com.example.asatiza`. VERIFIED
- End-to-end flow (target): `main()` → `WidgetsFlutterBinding.ensureInitialized()` → `runApp(const AsatizaApp())` → `MaterialApp.router(theme: AppTheme.light(), darkTheme: AppTheme.dark(), themeMode: ThemeMode.system, localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, routerConfig: appRouter)` → `StatefulShellRoute.indexedStack` with 4 branches (Home, Teachers, Chats, Alerts) → `MainShell` (custom bottom bar per the design + centre "+" button) → branch placeholder screens; centre "+" → `context.push(AppRoutes.createPost)` → full-screen `CreatePostScreen` route outside the shell. No bloc/cubit, repository or backend call exists in this phase (nothing to manage yet; tab state is owned by go_router).
- Relevant files: `lib/main.dart`, `test/widget_test.dart`, `pubspec.yaml`, `pubspec.lock`, `analysis_options.yaml`, `android/app/build.gradle.kts`, `android/app/src/main/AndroidManifest.xml`, `android/app/src/main/kotlin/com/example/asatiza/MainActivity.kt`, `ios/Runner.xcodeproj/project.pbxproj`, `ios/Runner/Info.plist`. VERIFIED (all exist)
- Existing reusable components: None. No `lib/core/` exists; only Material widgets are used. VERIFIED
- Existing API details: None. Not applicable to this phase.
- Existing models: None. Not applicable to this phase.
- Existing state-management flow: `setState` in the starter `MyHomePage` only. No package. VERIFIED
- Existing navigation flow: `MaterialApp(home: MyHomePage)`, no routes. VERIFIED
- Android behavior: `namespace` and `applicationId` = `com.example.asatiza`; `android:label="asatiza"`; `MainActivity.kt` in `kotlin/com/example/asatiza/`; Java/Kotlin 17; min/target SDK from Flutter defaults; release build signs with debug keys. VERIFIED
- iOS behavior: `PRODUCT_BUNDLE_IDENTIFIER = com.example.asatiza` (Runner) and `com.example.asatiza.RunnerTests`; `CFBundleDisplayName = Asatiza`, `CFBundleName = asatiza`; deployment target 13.0; no `Podfile` yet. VERIFIED
- Lifecycle behavior: No subscriptions, controllers or timers are introduced. `StatefulShellRoute.indexedStack` keeps branch widgets alive while switching tabs.
- Permission behavior: No permissions are added or changed.
- Database and cache behavior: None.
- Supabase tables, columns and migrations: None. Supabase setup belongs to a later backend phase.
- Row Level Security and Storage policies: None.
- Realtime, Edge Functions and push: None.
- Both roles (Teacher / Student) and signed-out behavior: Role is unknown until auth exists. The second tab is shown as "Teachers" (student view) for now; making it role-aware ("Students" for teachers) and adding the signed-out redirect belong to the auth/profile phases. No auth gate exists in this phase, so the shell is reachable without login — acceptable only because there is no data.
- Security considerations: No secrets, keys or env files are touched. The app ID becomes permanent after the first Play Store upload (`docs/KNOWN_ISSUES.md`). The two product-plan PDFs sit in `assets/` but are not declared in `pubspec.yaml`, so they are not bundled; this phase must not declare `assets/` as a folder.

### Design Against The SOLID Checklist

- S: `main.dart` only boots; `AsatizaApp` only wires theme + router; `AppTheme` only builds `ThemeData`; `appRouter` only declares routes; `MainShell` only renders the bottom bar; each placeholder screen only renders. One public class per file.
- O: New tabs/routes are added as new branches in `app_router.dart`; features replace their own placeholder screen without touching the shell.
- L / I: No interfaces are introduced — no repositories or services exist yet.
- D: No dependencies to inject yet. `MultiRepositoryProvider`/`MultiBlocProvider` are added by the first phase that creates a repository or bloc (avoids unused code).
- Balance: no speculative abstractions; no empty base classes or interfaces.

### Proposed Dependency Decision

- Add `go_router` only (latest version compatible with Flutter 3.41.0 / Dart `^3.11.0`, resolved with `flutter pub add go_router` at execution). VERIFIED local SDK: Flutter 3.41.0 stable.
- Do **not** add `flutter_bloc`, `dio`, `supabase_flutter` or Firebase here: nothing uses them yet. Each is added by the first phase that needs it (backend/auth). This follows the "no future-only code" rule.

## Scope

- In scope:
  - Decided folder structure for this phase's files only (`lib/core/theme`, `lib/core/router`, `lib/core/widgets`, `lib/l10n`, `lib/features/<tab feature>/presentation`). Empty folders are not created.
  - `lib/main.dart` composition root (boot + OFL font-license registration) and `lib/app.dart` (`AsatizaApp`).
  - Theme mapped 1:1 from the Asatiza design-system tokens: colors, text styles, spacing, radii, shadows — **light and dark** (`ThemeMode.system`, follows the phone setting).
  - Fonts bundled in `assets/fonts/`: Fraunces SemiBold (600), Plus Jakarta Sans Regular/Medium/SemiBold/Bold (400–700), Amiri Regular (400), plus their OFL license texts, each declared one by one in `pubspec.yaml`.
  - Localization with **English only** via Flutter `gen-l10n`: every user-facing string in this phase (tab labels, screen titles, button and semantics labels) comes from `app_en.arb`; layouts use direction-neutral padding/alignment (`EdgeInsetsDirectional`, `AlignmentDirectional`) so Urdu/Arabic RTL in v1.1 needs no layout rewrite.
  - go_router config with `StatefulShellRoute.indexedStack` and 4 branches (Home, Teachers, Chats, Alerts) plus a full-screen Create post route; route path constants.
  - `MainShell` custom bottom bar matching the artboards (active pill, raised centre "+" button, badge slot without counts).
  - 5 placeholder screens matching their artboard headers: Home (empty body; its top bar belongs to the feed phase), Teachers (title "Teachers"), Chats (title "Chats"), Notifications (title "Notifications"), Create post (56 px header: Close button + title "New post"; no bottom bar).
  - App identifier `com.asatiza.app` and display name "Asatiza" on **Android and iOS**.
  - `pubspec.yaml`: description "Asatiza — Quran teacher & student network", `go_router`, `flutter_localizations`, `intl`, `generate: true`, fonts.
  - Replace the starter test with app, router and theme tests.
  - Docs: mark created structure VERIFIED in `ARCHITECTURE.md`, `DIRECTORY_STRUCTURE.md` (add `lib/app.dart` and `lib/l10n/`), `NAVIGATION.md`, `COMMON_COMPONENTS.md`, `PROJECT_OVERVIEW.md`, `KNOWN_ISSUES.md` (close open decisions 2 and 3; fix the stale "not a Git repository" lines), `FILE_CATALOG.md`, `TESTING_GUIDE.md`, `CODING_STANDARDS.md` (strings from ARB, direction-neutral layout).
- Explicitly out of scope: Splash, Welcome, auth screens and redirects; the Home top bar (avatar + search) — the design shows it on Home only, so it is part of the Home screen and belongs to the feed/profile phases; search fields on Teachers/Chats; role-aware second tab ("Students" for teachers); real unread counts; Supabase/Firebase/Dio/BLoC setup; env config (`--dart-define` keys) — backend phase; Urdu/Arabic translations (v1.1); app icon and native splash assets; release signing; CI; changes to the design canvas.
- Files expected to change:
  - `lib/main.dart` (modified: starter replaced by boot code)
  - `pubspec.yaml`, `pubspec.lock` (modified: description, dependencies, `generate: true`, fonts)
  - `android/app/build.gradle.kts` (modified: `namespace` and `applicationId` → `com.asatiza.app`)
  - `android/app/src/main/AndroidManifest.xml` (modified: `android:label="Asatiza"`)
  - `android/app/src/main/kotlin/com/example/asatiza/MainActivity.kt` → moved to `android/app/src/main/kotlin/com/asatiza/app/MainActivity.kt` with `package com.asatiza.app`
  - `ios/Runner.xcodeproj/project.pbxproj` (modified: `PRODUCT_BUNDLE_IDENTIFIER` → `com.asatiza.app` in the 3 Runner configurations and `com.asatiza.app.RunnerTests` in the 3 RunnerTests configurations)
  - `ios/Runner/Info.plist` (modified: `CFBundleName` → `Asatiza`; add `CFBundleLocalizations` = `en`, which iOS needs to use the app's localization)
  - `test/widget_test.dart` (deleted; replaced by the tests below)
  - Docs listed in scope
- Files that must not change: `docs/product/*`, `assets/*.pdf`, `android/build.gradle.kts`, `android/settings.gradle.kts`, `android/gradle/**`, `ios/Flutter/**`, `ios/Runner/AppDelegate.swift`, `analysis_options.yaml`, `.gitignore`, `CLAUDE.md`, skill files.
- Proposed new files (approval requested):

  | Path | Class | Responsibility | Why needed / why existing code is not suitable |
  |---|---|---|---|
  | `lib/app.dart` | `AsatizaApp` | Root widget: `MaterialApp.router` with light/dark theme, localization delegates and router | Keeps `main.dart` boot-only (S) |
  | `lib/core/theme/app_colors.dart` | `AppColors` | Design color tokens, light and dark sets | No theme exists; "no hard-coded colors" rule |
  | `lib/core/theme/app_text_styles.dart` | `AppTextStyles` | The 9 design text styles + screen-title styles + font family names | Design type scale |
  | `lib/core/theme/app_spacing.dart` | `AppSpacing` | Spacing tokens 4–48 | Shared layout tokens |
  | `lib/core/theme/app_radius.dart` | `AppRadius` | Radius tokens sm–pill | Shared shape tokens |
  | `lib/core/theme/app_shadows.dart` | `AppShadows` | `shadow-card`, `shadow-raised` (light/dark) | Shared elevation tokens |
  | `lib/core/theme/app_theme.dart` | `AppTheme` | Builds light and dark `ThemeData` (Material 3) from the tokens | Decided `lib/core/theme/` |
  | `assets/fonts/Fraunces-SemiBold.ttf`, `PlusJakartaSans-Regular.ttf`, `PlusJakartaSans-Medium.ttf`, `PlusJakartaSans-SemiBold.ttf`, `PlusJakartaSans-Bold.ttf`, `Amiri-Regular.ttf` | — | Bundled design fonts | Owner chose bundling (offline, no package) |
  | `assets/fonts/OFL-Fraunces.txt`, `OFL-PlusJakartaSans.txt`, `OFL-Amiri.txt` | — | Font license texts, shown on the app's licenses page | Required by the SIL Open Font License |
  | `l10n.yaml` | — | `gen-l10n` config (ARB dir `lib/l10n`, template `app_en.arb`, class `AppLocalizations`) | Owner chose localization now |
  | `lib/l10n/app_en.arb` | — | English strings for this phase | Source of all UI text |
  | `lib/l10n/app_localizations.dart`, `lib/l10n/app_localizations_en.dart` | `AppLocalizations` (generated) | Generated by `flutter gen-l10n`; never hand-edited | Flutter tooling output |
  | `lib/core/router/app_routes.dart` | `AppRoutes` | Route path/name constants | Avoid string routes across features |
  | `lib/core/router/app_router.dart` | top-level `appRouter` (`GoRouter`) | Route table: `StatefulShellRoute` with 4 branches + Create post route | Decided `lib/core/router/` |
  | `lib/core/widgets/main_shell.dart` | `MainShell` | Designed bottom bar + centre "+" around `StatefulNavigationShell` | Material `NavigationBar` cannot draw the raised centre button |
  | `lib/features/feed/presentation/home_screen.dart` | `HomeScreen` | Home tab placeholder | Owned by feed feature |
  | `lib/features/discover/presentation/discover_screen.dart` | `DiscoverScreen` | Teachers tab placeholder | Owned by discover feature |
  | `lib/features/post/presentation/create_post_screen.dart` | `CreatePostScreen` | "New post" placeholder with Close | Owned by post feature |
  | `lib/features/chat/presentation/chats_screen.dart` | `ChatsScreen` | Chats tab placeholder | Owned by chat feature |
  | `lib/features/notifications/presentation/notifications_screen.dart` | `NotificationsScreen` | Alerts tab placeholder, title "Notifications" | Owned by notifications feature |
  | `test/app_test.dart` | — | Boots `AsatizaApp`; 4 tabs + centre button shown; Home first; light and dark themes build | Replaces counter test |
  | `test/core/router/app_router_test.dart` | — | Tab switching; branch state kept; "+" opens Create post full-screen; Close returns | Router contract |
  | `test/core/theme/app_theme_test.dart` | — | Light and dark colors and text styles equal the design tokens | Guards the token mapping |

- Proposed new classes: `AsatizaApp`, `AppColors`, `AppTextStyles`, `AppSpacing`, `AppRadius`, `AppShadows`, `AppTheme`, `AppRoutes`, `MainShell`, `HomeScreen`, `DiscoverScreen`, `CreatePostScreen`, `ChatsScreen`, `NotificationsScreen` (approval requested). `appRouter` is a top-level `GoRouter` instance; `AppLocalizations` is generated.
- Dependency changes (approval requested): `go_router` (pub.dev, latest compatible with Flutter 3.41.0 / Dart `^3.11.0`, resolved at execution); `flutter_localizations` (Flutter SDK); `intl` (version pinned by the Flutter SDK). No dev dependencies.
- External downloads at execution (explicit permission will be asked first): the 6 font files and 3 OFL texts from Google Fonts (fonts.google.com) — or the developer places them in `assets/fonts/` beforehand.
- API contract changes: None.
- Native changes (approval requested): Android `namespace`/`applicationId`, label, `MainActivity.kt` package move; iOS bundle IDs, `CFBundleName`, `CFBundleLocalizations`.
- Supabase migration/RLS/function changes: None.
- Approval requirements: High risk (production dependencies, native app ID on both platforms, shared core theme/router). Explicit developer approval required for the dependencies, native changes and every new file/class above.

## Developer Answers (2026-11-18)

| # | Question | Answer |
|---|---|---|
| 1 | App identifier | `com.asatiza.app` on Android and iOS (assumes the owner controls the `asatiza` name/domain) |
| 2 | Platforms | Android **and** iOS in v1.0 |
| 3 | Localization | Yes — English-only `gen-l10n` setup now, RTL-ready layout |
| 4 | Brand theme | Asatiza design system on the owner's design canvas |
| 5 | Centre "+" | Raised centre button opening Create post full-screen (design) |
| 6 | Root widget file | Option A: `lib/app.dart` beside `lib/main.dart`; `main.dart` only starts the app |
| 7 | Lint rules | Keep the default `flutter_lints`; `analysis_options.yaml` does not change |
| 8 | Owner / manual tester | The developer (repository owner) |
| 9 | Fonts | Bundle the font files in the app |
| 10 | Dark mode | Light **and** dark in v1.0, following the phone setting |
| 11 | Top bar | Checked in the design: the avatar + search top bar appears on the Home artboard only; Teachers, Chats and Notifications have their own title headers; Create post has Close + "New post". The top bar is part of the Home screen, not the shell → feed/profile phases |
| 12 | Tab label | Design is the source of truth: tab "Alerts", screen title "Notifications" |

Design findings used for the theme:

- Tab screens use a 24 px / 700 title and Create post an 18 px / 700 title; neither is in the design system's type scale. Because the design is the source of truth, `AppTextStyles` adds `screenTitle` (24 px, 700) and `pageTitle` (18 px, 700), Plus Jakarta Sans. The artboards set no line height for them: 32 px and 24 px are assumed. UNVERIFIED — designer confirmation welcome.
- The active tab label is 12 px / 700 (inactive 12 px / 500 = `caption`): a bold variant of `caption`, taken from the artboards.

## Missing Information

No item blocks approval. Remaining (needed before Close Phase):

13. ~~iOS build and test environment~~ — **RESOLVED 2026-11-19:** the developer reports Android and iOS tested. This repository is worked on from Windows, where iOS apps cannot be built or run. The iOS file changes can be made here, but iOS checks and manual tests need a Mac with Xcode (or a cloud Mac build service). Who or what will run the iOS test? Needed before Close Phase, not before approval.

## Readiness Checklist

- [x] Requirement is clear
- [x] Expected behavior is clear
- [x] Existing flow is traced
- [x] API is verified (not applicable — no API)
- [x] Request contract is verified (not applicable)
- [x] Response contract is verified (not applicable)
- [x] Supabase tables, RLS and Storage policies are defined (not applicable)
- [x] Security, 18+ gate and moderation rules are unaffected or approved (unaffected)
- [x] Required UI/design is available (design canvas, read 2026-11-18)
- [x] Existing reusable components are identified (none exist)
- [x] Proposed files are identified
- [x] New files/classes are approved
- [x] Platform behavior is understood
- [x] Permissions are understood (none)
- [x] Dependencies are available (approved: `go_router`, `flutter_localizations`, `intl`; fonts from Google Fonts with download permission asked at execution)
- [x] Risks are documented
- [x] Automated tests are defined
- [x] Manual tests are defined
- [x] Rollback plan is defined
- [x] Phase dependencies are completed (none)
- [x] Developer approval is recorded

## Risks

- App ID is permanent after the first Play Store upload; a wrong choice cannot be fixed later.
- Moving `MainActivity.kt` without matching `package` and `namespace` causes a launch crash (`ClassNotFoundException`). Mitigation: change all three together and launch on a device.
- iOS bundle ID change touches `project.pbxproj` (4 configurations incl. RunnerTests); a partial edit breaks signing/tests.
- `go_router` major-version API changes (e.g. `StatefulShellRoute` signatures); pin to the version resolved at execution and record it.
- Android back-button behavior with `StatefulShellRoute` must match acceptance criterion 4; needs explicit handling if the default differs.
- The design canvas can change after this phase; token values are copied into Dart, so later design edits need a theme update. `app_theme_test.dart` pins the values so a drift is visible.
- Fonts: bundled files add ~1–2 MB to the app. Amiri must render Arabic shaping correctly on Android and iOS — check on a device.
- iOS changes are made from Windows and cannot be built or tested there; a wrong `project.pbxproj` edit only shows up on a Mac. Mitigation: change only the listed keys, keep the diff minimal, and test on a Mac before Close (missing info 13).
- Dark mode doubles the visual checks; every placeholder must be checked in both modes.
- `gen-l10n` output files are generated: never hand-edit them; regenerate with `flutter gen-l10n` (also runs on `flutter pub get`).

## Test Plan

- Automated (execute phase): `flutter gen-l10n`; `dart format` on changed Dart files; `flutter analyze`; `flutter test` running `test/app_test.dart`, `test/core/router/app_router_test.dart` and `test/core/theme/app_theme_test.dart`.
- Manual (developer: Android device; iOS simulator or device on a Mac): app label "Asatiza"; launch shows Home; bottom bar matches the artboards (ivory background, green active pill, raised green "+", label "Alerts"); each of the 4 tabs opens its screen with the design title; "+" opens "New post" full-screen and Close/back returns; switching tabs keeps state; back from a non-Home tab returns to Home, from Home exits (Android); switch the phone to dark mode — colors follow the dark tokens; fonts render offline; Settings → licenses lists the 3 OFL fonts.

## Rollback Plan

All changes are local files with no data or remote effects. Roll back by reverting the phase's files with Git (restore `lib/main.dart`, `test/widget_test.dart`, `pubspec.yaml`/`pubspec.lock`, Android and iOS native files and the `kotlin/com/example/asatiza/` path; delete the new `lib/`, `test/`, `assets/fonts/` and `l10n.yaml` files) and running `flutter pub get`. Do not roll back the app ID after any store upload.

## Implementation

- Approved implementation plan: Approved 2026-11-18 by the developer (repository owner) with the explicit request "APPROVE PHASE: PHASE_001_FOUNDATION_ADD_PROJECT_FOUNDATION". The approval covers the Scope section exactly as written: the 14 proposed classes and every listed new file (`lib/app.dart`, 6 theme files, router files, `lib/core/widgets/main_shell.dart`, 5 placeholder screens, `l10n.yaml`, `lib/l10n/app_en.arb` + generated localization files, 6 font files + 3 OFL texts, 3 test files); the dependencies `go_router`, `flutter_localizations`, `intl`; the native changes (Android `namespace`/`applicationId` `com.asatiza.app`, label, `MainActivity.kt` move; iOS bundle IDs, `CFBundleName`, `CFBundleLocalizations`); deletion of `test/widget_test.dart`; and the listed doc updates. Anything outside this list needs new approval (step `APPROVAL`, approval `PENDING`). Font downloads still need explicit permission at execution. Item 13 (Mac for iOS testing) must be resolved before Close Phase.
- Implementation log (2026-11-19):
  1. Readiness re-checked (`validate_phase_readiness.sh`: OK); no other active phase; Git baseline `main` at `ee9124b`.
  2. Font download permission asked and granted by the developer. Downloaded to the scratchpad, checked (TrueType header `00 01 00 00`, 4 distinct Plus Jakarta Sans files, OFL texts contain "SIL OPEN FONT LICENSE"), then copied to `assets/fonts/`. Sources: Google Fonts static instances from fonts.gstatic.com (Fraunces v38 wght 600, Plus Jakarta Sans v12 wght 400/500/600/700, Amiri v30 400) and OFL texts from github.com/google/fonts (`ofl/<family>/OFL.txt`).
  3. Packages: `flutter pub add go_router` (resolved `^17.5.0`), `flutter_localizations` (SDK), `intl:any` (SDK-pinned). `pubspec.yaml`: description, `generate: true`, the 3 OFL texts as assets (one by one), 3 font families.
  4. Localization: `l10n.yaml` + `lib/l10n/app_en.arb` (11 strings); `flutter gen-l10n` generated `app_localizations.dart` and `app_localizations_en.dart` in `lib/l10n/`.
  5. Theme (light + dark) from the design tokens, router, shell, 5 placeholder screens, `lib/app.dart`, new `lib/main.dart`.
  6. Android: `namespace`/`applicationId` → `com.asatiza.app`, label "Asatiza", `MainActivity.kt` moved to `kotlin/com/asatiza/app/` (`git mv`) with `package com.asatiza.app`; old `com/example` folders removed. iOS: 6 `PRODUCT_BUNDLE_IDENTIFIER` values → `com.asatiza.app` / `com.asatiza.app.RunnerTests`; `Info.plist` `CFBundleName` "Asatiza" + `CFBundleLocalizations` [en] (plist parsed OK).
  7. `test/widget_test.dart` removed (`git rm`); 3 approved test files added.
  8. Docs updated (see Change Log).
- Exact changed files: see Change Log (47 paths; all on the approved list).
- Purpose of every changed file: see Change Log.
- Existing components reused: None existed. Flutter `StatefulShellRoute.indexedStack` provides per-tab stacks; Material `IconButton`/`InkResponse` used inside the custom bar.
- New approved components: `AsatizaApp`, `AppColors`, `AppTextStyles`, `AppSpacing`, `AppRadius`, `AppShadows`, `AppTheme`, `AppRoutes`, `appRouter`, `MainShell`, `HomeScreen`, `DiscoverScreen`, `CreatePostScreen`, `ChatsScreen`, `NotificationsScreen` — all created. Private helper widgets inside `main_shell.dart` (`_BottomBar`, `_TabItem`, `_CreatePostButton`) stay inside the approved file.
- Out-of-scope findings:
  - Tab icons: the design draws custom stroke SVG icons; this phase uses the closest Material outlined icons (`home`, `people`, `chat_bubble`, `notifications`, `add`). Exact icons need SVG assets and an SVG package (new dependency) — a future approved change.
  - Unread badges on Chats/Alerts are not drawn: there are no counts until the chat/notifications phases.
  - Fraunces is bundled as the static 600 instance; the design canvas uses CSS optical sizing (`opsz` follows font size). Small visual difference at display sizes only.
  - `assets/logos/` (developer commit `ee9124b`) is not wired into Android/iOS launcher icons — app icon work is out of scope.
  - Git index: `git mv` (MainActivity) and `git rm` (`test/widget_test.dart`) staged those two changes; nothing is committed.
- Unexpected risks: None. One analyzer error during execution (`Brightness` not imported in `app_shadows.dart`) was introduced and fixed in this phase.
- Known limitation: iOS was not built or run (Windows; item 13).

## Change Log

For every changed file, record:

| File path | Change type | Approved in phase | What changed | Why it changed | Existing behavior preserved | Possible side effects | File-level checks |
|---|---|---|---|---|---|---|---|
| `lib/main.dart` | modified | Yes | Starter counter app replaced: boot, register 3 OFL licenses, `runApp(AsatizaApp)` | Composition root | None (starter removed by design) | License registry loads assets lazily | analyze, app_test |
| `lib/app.dart` | added | Yes | `AsatizaApp`: `MaterialApp.router`, light/dark theme, `ThemeMode.system`, localization delegates, `appRouter` | Root widget (answer 6 = A) | n/a | None | analyze, app_test |
| `lib/core/theme/app_colors.dart` | added | Yes | `AppColors` ThemeExtension, 18 tokens × light/dark, `success` getter, copyWith/lerp | Design color tokens | n/a | None | analyze, app_theme_test |
| `lib/core/theme/app_text_styles.dart` | added | Yes | 9 design styles + `screenTitle`, `pageTitle`, `captionBold`; family names | Design type scale | n/a | Assumed line heights 32/24 px for the 2 non-token titles | analyze, app_theme_test |
| `lib/core/theme/app_spacing.dart` | added | Yes | 8 spacing tokens | Design spacing | n/a | None | analyze |
| `lib/core/theme/app_radius.dart` | added | Yes | 5 radius tokens | Design radii | n/a | None | analyze |
| `lib/core/theme/app_shadows.dart` | added | Yes | `card()` / `raised()` per brightness | Design shadows | n/a | None (import fix applied) | analyze |
| `lib/core/theme/app_theme.dart` | added | Yes | Light and dark `ThemeData`: ColorScheme, TextTheme, scaffold background, `AppColors` extension | Theme from tokens | n/a | Material widgets pick colors from ColorScheme mapping | analyze, app_theme_test, app_test |
| `lib/core/router/app_routes.dart` | added | Yes | Paths `/home`, `/teachers`, `/chats`, `/alerts`, `/create-post` | No string routes in features | n/a | None | analyze |
| `lib/core/router/app_router.dart` | added | Yes | `appRouter`: `StatefulShellRoute.indexedStack` (4 branches) + full-screen `/create-post` | Navigation shell | n/a | Global router keeps location between tests | analyze, app_router_test |
| `lib/core/widgets/main_shell.dart` | added | Yes | Designed bottom bar (80 px, pill, raised 56 px "+" with ring and shadow), PopScope back → Home | Shell UI | n/a | Material icons approximate the design's SVG icons | analyze, app_router_test |
| `lib/features/feed/presentation/home_screen.dart` | added | Yes | Empty Home placeholder | Home tab | n/a | None | app_test |
| `lib/features/discover/presentation/discover_screen.dart` | added | Yes | Title "Teachers" (24/700) | Teachers tab | n/a | None | app_router_test |
| `lib/features/chat/presentation/chats_screen.dart` | added | Yes | Title "Chats" | Chats tab | n/a | None | app_router_test |
| `lib/features/notifications/presentation/notifications_screen.dart` | added | Yes | Title "Notifications" | Alerts tab | n/a | None | app_router_test |
| `lib/features/post/presentation/create_post_screen.dart` | added | Yes | 56 px header: Close (44 px) + "New post" (18/700) | Create post route | n/a | None | app_router_test |
| `lib/l10n/app_en.arb` | added | Yes | 11 English strings | Localization source | n/a | None | gen-l10n |
| `lib/l10n/app_localizations.dart`, `lib/l10n/app_localizations_en.dart` | generated | Yes | `AppLocalizations` from the ARB | gen-l10n output | n/a | Regenerated on `flutter pub get` | gen-l10n, analyze |
| `l10n.yaml` | added | Yes | arb-dir `lib/l10n`, template `app_en.arb`, class `AppLocalizations`, non-null getter | gen-l10n config | n/a | None | gen-l10n |
| `pubspec.yaml` | modified | Yes | Description; `go_router ^17.5.0`, `flutter_localizations`, `intl: any`; `generate: true`; 3 OFL assets; 3 font families | Approved dependencies and fonts | Existing deps unchanged; PDFs still not bundled | None | pub get, analyze, test |
| `pubspec.lock` | modified | Yes | Resolved go_router and transitive packages | Dependency lock | Existing versions unchanged | None | pub get |
| `assets/fonts/*.ttf` (6) | added | Yes | Fraunces-SemiBold, PlusJakartaSans Regular/Medium/SemiBold/Bold, Amiri-Regular | Bundled design fonts (answer 9) | n/a | +~710 KB app size | header check, test (asset bundling) |
| `assets/fonts/OFL-*.txt` (3) | added | Yes | SIL OFL 1.1 texts for the 3 families | License compliance | n/a | None | content check |
| `android/app/build.gradle.kts` | modified | Yes | `namespace`, `applicationId` → `com.asatiza.app` | Final app ID (answer 1) | Build config otherwise unchanged | Permanent after first Play upload | grep |
| `android/app/src/main/AndroidManifest.xml` | modified | Yes | `android:label="Asatiza"` | Display name | Activity and intent filters unchanged | None | grep |
| `android/app/src/main/kotlin/com/asatiza/app/MainActivity.kt` | renamed | Yes | Moved from `com/example/asatiza/`; `package com.asatiza.app` | Matches new namespace | Same `FlutterActivity` subclass | Wrong package would crash at launch — checked | grep |
| `ios/Runner.xcodeproj/project.pbxproj` | modified | Yes | 6 `PRODUCT_BUNDLE_IDENTIFIER` values → `com.asatiza.app` / `.RunnerTests` | Final app ID on iOS | No other build settings changed | Not built on a Mac yet (item 13) | grep |
| `ios/Runner/Info.plist` | modified | Yes | `CFBundleName` "Asatiza"; `CFBundleLocalizations` [en] | Display name, localization | Other keys unchanged | Not built on a Mac yet | plistlib parse |
| `test/widget_test.dart` | deleted | Yes | Starter counter test removed | Replaced by approved tests | n/a | None | test |
| `test/app_test.dart` | added | Yes | 3 tests: boot/tabs, light tokens, dark tokens | Automated checks | n/a | None | flutter test |
| `test/core/router/app_router_test.dart` | added | Yes | 5 tests: tabs, kept branch state, Create post open/close, back on tab, back on Create post | Router contract | n/a | None | flutter test |
| `test/core/theme/app_theme_test.dart` | added | Yes | 4 tests: light tokens, body font, dark tokens, type scale | Token pinning | n/a | None | flutter test |
| `docs/ARCHITECTURE.md`, `docs/DIRECTORY_STRUCTURE.md`, `docs/NAVIGATION.md`, `docs/COMMON_COMPONENTS.md`, `docs/PROJECT_OVERVIEW.md`, `docs/KNOWN_ISSUES.md`, `docs/FILE_CATALOG.md`, `docs/TESTING_GUIDE.md`, `docs/CODING_STANDARDS.md` | modified | Yes | VERIFIED sections for the new structure; open decisions 2 and 3 closed; stale Git/Bash notes fixed; string, RTL and token rules | Approved doc updates | Decided-target sections unchanged | None | validate_phase_structure.sh |
| `docs/phases/items/PHASE_001_…`, `docs/phases/PHASE_INDEX.md`, `docs/phases/state/PHASE_STATE.md` | modified | Yes | Status, implementation log, change log, checks | Phase workflow | n/a | None | update_phase_index.sh |

## Execute Technical Checks

- Changed-file evidence reviewed after changes: Yes — `git status --short --untracked-files=all` (2026-11-19); every path is on the approved list. Pre-existing uncommitted changes before execution: phase docs only.
- Git status/diff rerun reason: once, to build this change log.
- Patch/whitespace check result, when run: Not run (not needed: no merge or commit).
- Relevant Dart formatting: `dart format lib/main.dart lib/app.dart lib/core lib/features test` → 5 files reformatted; re-check `--set-exit-if-changed` → 0 changed.
- Scoped or project analysis commands: `flutter analyze` → first run 4 errors (missing `Brightness` import in `app_shadows.dart`, introduced here); fixed; second run "No issues found!".
- Relevant targeted tests: `flutter test` (all 3 new files; the whole suite is these files) → 12 passed, 0 failed.
- Other checks: `flutter gen-l10n` OK; `Info.plist` parsed with Python `plistlib` OK; font headers and OFL texts checked; `grep` confirms no `com.example` left in Android/iOS sources; no `Color(0x…)`/`Colors.` in `lib/features`.
- Newly introduced issues found: 1 (missing import) — fixed.
- Newly introduced issues fixed: 1.
- Pre-existing unrelated issues: None found.
- Commands that could not run and why: iOS build/run (`flutter build ios`, simulator) — not possible on Windows; needs a Mac (item 13). App not launched on Android by Claude (not requested; developer manual test).

## Manual Testing

- Ready for developer manual testing: Yes (2026-11-19). Run on an Android device: `flutter run`. iOS needs a Mac (item 13). Manual checks: Test Plan → Manual.
- Developer manual-test confirmation: "Tested working fine" (2026-11-19), Android and iOS.
- Manual-test notes requested by developer: None

## Closure

- Developer manual-test confirmation: "Tested working fine" — developer, 2026-11-19 (explicit `CLOSE PHASE` request).
- Tested platforms: Android and iOS (confirmed by the developer when asked).
- Tested devices: Not provided.
- Failed and retested cases: None reported.
- Final changed files: the 40 implementation paths and 9 docs listed in the Change Log, all on the approved list; reconfirmed with `git status --short --untracked-files=all` at closure (40 non-doc paths, same set as Execute). No unapproved dependency or architecture change.
- Reused Execute technical evidence at closure: Yes. No implementation file changed after Execute; only `lib/l10n/app_localizations*.dart` were regenerated by `flutter run` from the unchanged `app_en.arb`. Reused: `flutter analyze` no issues; `flutter test` 12/12 passed; formatting clean. No checks rerun.
- Known limitations:
  - Tab icons are Material approximations of the design's custom SVG icons.
  - No unread badges until the chat/notifications phases.
  - Fraunces bundled as the static 600 instance (no optical sizing).
  - Launcher icons from `assets/logos/` not wired yet.
  - Placeholder screens only; no auth gate (no data exists yet).
- Follow-up phases (suggested, not created): app launcher icons + native splash from `assets/logos/`; exact design icons (SVG assets + package, needs approval); Supabase backend foundation; auth (Splash, Welcome, sign up, OTP, login).
- Rollback guidance: See Rollback Plan. Nothing is committed: revert by restoring the tracked files with Git and deleting the new files listed in the Change Log. The app ID `com.asatiza.app` must not change after any store upload.
- Commit: not requested — nothing committed. `git mv`/`git rm` left 2 paths staged (`MainActivity.kt` move, `test/widget_test.dart` deletion).
- Final status: CLOSED / CLOSURE / COMPLETED
- Completion date: 2026-11-19
