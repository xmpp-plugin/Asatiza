# Navigation

## Verified

`MaterialApp(home: MyHomePage)` with no routes (starter code). VERIFIED

## Decided: go_router

- Config in `lib/core/router/`.
- Auth redirect: signed-out → Welcome/Login; signed up but OTP pending → Email code; signed in → Home (profile setup is shown after sign-up and is skip-able).
- `StatefulShellRoute` with 5 bottom tabs: Home · Teachers (for students) / Students (for teachers) · + Post · Chats · Notifications.
- Top-left avatar opens My Profile, Settings, Log out.
- Detail routes: post detail, public profile, chat conversation, my connections, edit profile, settings.
- Push-notification taps route by payload `type` + `target_id` to the matching screen; handle foreground, background and terminated states.
- Deep links (share profile/post) are Version 1.1. DECIDED

## Rules

- Add routes only in the go_router config.
- Confirm route parameters and `extra` types before editing.
- Navigation touching auth, notifications or chat is medium or high risk.
