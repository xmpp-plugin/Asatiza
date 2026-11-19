# Navigation

## Verified

VERIFIED 2026-11-19 (`PHASE_001`):

- `lib/core/router/app_router.dart`: top-level `appRouter` (`GoRouter`, initial `/home`) with `StatefulShellRoute.indexedStack` → 4 branches `/home` (`HomeScreen`), `/teachers` (`DiscoverScreen`), `/chats` (`ChatsScreen`), `/alerts` (`NotificationsScreen`); each branch keeps its own stack.
- `/create-post` (`CreatePostScreen`) is a full-screen route above the shell, opened by the centre "+" (`context.push`), closed with Close or system back.
- `MainShell` (`lib/core/widgets/main_shell.dart`): designed bottom bar Home · Teachers · "+" · Chats · Alerts; system back on a non-Home tab goes to Home, on Home leaves the app.
- Paths live in `AppRoutes`; no auth redirect yet.

## Decided: go_router

- Config in `lib/core/router/`.
- Auth redirect: signed-out → Welcome/Login; signed up but OTP pending → Email code; signed in → Home (profile setup is shown after sign-up and is skip-able).
- `StatefulShellRoute` with 4 branches (Home · Teachers for students / Students for teachers · Chats · Alerts) plus the centre "+" opening Create post full-screen (design is the source of truth: tab label "Alerts", screen title "Notifications").
- The top-left avatar (on the Home screen only, per design) opens My Profile, Settings, Log out.
- Detail routes: post detail, public profile, chat conversation, my connections, edit profile, settings.
- Push-notification taps route by payload `type` + `target_id` to the matching screen; handle foreground, background and terminated states.
- Deep links (share profile/post) are Version 1.1. DECIDED

## Rules

- Add routes only in the go_router config.
- Confirm route parameters and `extra` types before editing.
- Navigation touching auth, notifications or chat is medium or high risk.
