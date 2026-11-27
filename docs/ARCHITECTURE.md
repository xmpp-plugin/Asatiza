# Architecture

## Verified Architecture (updated 2026-11-19, `PHASE_001`)

VERIFIED 2026-11-27 (`PHASE_010`): the feed and reports are real (`SupabaseFeedRepository`, `SupabaseSafetyRepository`). `MockFeedRepository` and `MockSafetyRepository` moved to `test/fakes/`; only `MockNotificationRepository` remains in `lib/data/repositories/mock/`. `FeedOrdering` (connections first) is mirrored by `list_feed` and used by the test fake. Home pages 20 posts at a time (`FeedCubit.loadMore` / `refresh`).

VERIFIED 2026-11-27 (`PHASE_009`): chat is real (`SupabaseChatRepository`, the app's first Supabase Realtime use; each stream owns its channel and removes it on cancel). `MockChatRepository`, `MockConnectionRepository` and `MockProfileRepository` moved to `test/fakes/` (PHASE_007 rule); `lib/data/repositories/mock/` now holds only the feed, notifications and reports mocks. Chat photos use the existing avatar compression (see `KNOWN_ISSUES`).

VERIFIED 2026-11-26 (`PHASE_008`): connections are real (`SupabaseConnectionRepository`). `MockConnectionRepository` is no longer registered as `ConnectionRepository`; it stays in `lib/` only as `sampleConnections` behind the still-mock chat (moves to `test/fakes/` in the Chat phase). "Message" on real connections shows "Chat is coming soon" until then.

VERIFIED 2026-11-26 (`PHASE_007`): blocks are real (`BlockRepository` → `SupabaseBlockRepository`); post reports stay on `MockSafetyRepository`. DECIDED rule (developer, PHASE_007): `lib/` keeps only the implementation the app runs — when a feature becomes real, its mock repository moves from `lib/data/repositories/mock/` to `test/fakes/` as a test-only fake. Moved so far: `MockAuthRepository`, `MockDiscoverRepository`, `MockMediaRepository`, block code (`FakeBlockRepository`). `MockProfileRepository` stays in `lib/` while it is the sample-people source for the remaining mocks.

VERIFIED 2026-11-26 (`PHASE_006` scope change): no profile percentage anywhere. `ProfileCompletenessRules` (core logic) replaces `ProfileStrengthCalculator`; `SessionState.needsSetup` is derived from `Profile.isActive`, so the router sends every incomplete user to setup (no Skip; setup opens at the first incomplete step). `DailyShuffle` (discover logic) orders lists. `ProfileStrengthCard` and `DiscoverSort` removed.

VERIFIED 2026-11-25 (`PHASE_006`): `DiscoverRepository` is real (`SupabaseDiscoverRepository`) in `lib/main.dart`; `MockDiscoverRepository` stays for tests. `DiscoverCubit` has `DiscoverStatus.error` and `refresh()` (pull-to-refresh, "Try again"). Still mock: feed, connections, chat, notifications, safety.

VERIFIED 2026-11-24 (`PHASE_005`): `MediaRepository` is real (Supabase Storage) and registered by interface in `lib/main.dart`, with the first platform services in `lib/core/services/` (`ImagePickerService`, `ImageCompressor`, `DocumentPickerService`; each plugin imported only by its implementation). `pdfrx` (PDF viewer widget) is imported only by `CertificateViewerScreen`. Profile setup and Edit profile cubits receive `MediaRepository` and the services by constructor.

VERIFIED 2026-11-24 (`PHASE_004` fix): one run mode. Each repository is either real or mock, never both: Auth + Profile are always Supabase; feed, discover, connections, chat, notifications and safety are mock until their phases (each phase replaces only its own line in `lib/main.dart`). Settings come from defines when given, else from the bundled git-ignored `env/supabase.json` (public URL + key only; `AppConfig.fromJson` refuses any other key). Without them `main` throws a clear `StateError`; the full-mock app mode was removed. Mock classes stay for tests and as the source of the sample people.

VERIFIED 2026-11-23 (`PHASE_004`, superseded 2026-11-24): two run modes chosen in `lib/main.dart` by `AppConfig` (`lib/core/config/`): mock (no settings; tests) and backend (Auth + Profile on Supabase, other repositories still mock). `Supabase.initialize` and the only `Supabase.instance` read are in `lib/main.dart`; the `SupabaseClient` is passed by constructor to `lib/data/repositories/supabase/`. Pure helpers `ProfileRowMapper` and `SupabaseFailureMapper`. `SessionCubit.restore()` runs from Splash.

VERIFIED 2026-11-19 (`PHASE_002`, part 1):

VERIFIED 2026-11-23 (`PHASE_003`, part 2): features `discover`, `connections`, `chat`, `notifications`, `profile`, `settings` (each `bloc/`, `logic/` where needed, `presentation/` + `widgets/`); 4 new repository interfaces with mocks; `ShellBadgesCubit` in `lib/core/session/`. Mock repositories reference each other only inside `lib/data/repositories/mock/` and are wired in `lib/main.dart` (account deletion clears every mock store).
- Data layer exists: 5 models + 12 enums (`lib/data/models/`), 4 provisional repository interfaces (`AuthRepository`, `ProfileRepository`, `FeedRepository`, `SafetyRepository`) and their in-memory mock implementations in `lib/data/repositories/mock/` with seed data in `lib/data/mock/`. Mocks are created and registered by interface type only in `lib/main.dart` (`MultiRepositoryProvider`).
- State: `flutter_bloc` — app-wide `SessionCubit` (`lib/core/session/`) plus 11 screen cubits; cubits receive repositories through constructors.
- Logic classes: `ProfileStrengthCalculator` (core; removed in `PHASE_006`, replaced by `ProfileCompletenessRules`), `FeedOrdering`, `PostRules`, `PasswordRules`, `OtpRules`; `RelativeTimeFormatter` (core/utils). Mock repositories reuse these rules (as the backend will enforce them server-side).
- Router: `createAppRouter(SessionCubit)` with a session redirect (signed out → sign-in screens; right after sign-up → that role's setup; signed in → never back to sign-in).

- `lib/main.dart` boots and registers font licenses; `lib/app.dart` (`AsatizaApp`) wires `AppTheme.light()`/`dark()` (`ThemeMode.system`), `AppLocalizations` (English) and `appRouter`. VERIFIED
- `lib/core/theme/` (tokens + theme), `lib/core/router/` (go_router shell), `lib/core/widgets/main_shell.dart`, and placeholder screens in `lib/features/{feed,discover,chat,notifications,post}/presentation/`. VERIFIED
- No state-management package, backend client, repositories, services or models yet; no `MultiRepositoryProvider` until the first repository exists. VERIFIED

## Decided Target Architecture

```
Screens / widgets (lib/features/<feature>/presentation)
        │ BlocBuilder / BlocListener / context.read
Blocs / cubits (lib/features/<feature>/bloc) ──uses──▶ Logic classes (lib/features/<feature>/logic, shared: lib/core/logic)
        │ call (constructor-injected abstractions)
Repository interfaces (lib/data/repositories/*_repository.dart)      Service interfaces (lib/core/services)
        │ implemented by                                               │ implemented by
Supabase implementations (lib/data/repositories/supabase/)            Firebase / plugin implementations
  SupabaseClient + Dio injected        → later api/ (Dio → Python FastAPI)   (FCM, local notifications, Crashlytics,
        │                                                                     image compress, image picker)
Supabase Auth · Postgres + RLS · Storage · Realtime · Edge Functions (send-push → FCM)
```

Dependency direction is strictly top-down. Repositories and services never import blocs/cubits or Flutter UI. Logic classes import only models and other logic. SOLID rules: `CLASS_AND_COMPONENT_RULES.md`.

## Module Table (DECIDED)

| Feature | Path | Blocs / cubits | Repositories / services | Tables / services |
|---|---|---|---|---|
| auth | `lib/features/auth/` | auth state, sign-up, OTP, login, reset | `AuthRepository` | Supabase Auth, `profiles` |
| onboarding | `lib/features/onboarding/` | splash/welcome | — | — |
| profile_setup | `lib/features/profile_setup/` | setup steps, strength | `ProfileRepository`, `MediaRepository`, `ImagePickerService`, `ImageCompressor` | `profiles`, `teacher_details`, `student_details`, `avatars`, `certificates` |
| feed / post | `lib/features/feed/`, `lib/features/post/` | feed, create post, likes, comments | `FeedRepository`, `MediaRepository`, `ImagePickerService`, `ImageCompressor` | `posts`, `post_likes`, `post_comments`, `post-images` |
| discover | `lib/features/discover/` | search, filters | `DiscoverRepository` | `profiles`, detail tables |
| connections | `lib/features/connections/` | requests, list | `ConnectionRepository` | `connections` |
| chat | `lib/features/chat/` | conversations, messages | `ChatRepository`, `MediaRepository`, `ImagePickerService`, `ImageCompressor` | `conversations`, `messages`, `chat-images`, Realtime |
| notifications | `lib/features/notifications/` | list, unread, push | `NotificationRepository`, `PushNotificationService` | `notifications`, `device_tokens`, FCM, `send-push` |
| profile | `lib/features/profile/` | my/other profile, edit | `ProfileRepository`, `MediaRepository` | `profiles` + details |
| settings | `lib/features/settings/` | password, toggles, delete | `AuthRepository`, `SafetyRepository` | `reports`, `blocks`, deletion |

Logic classes (examples, created only through approved phases): `ProfileStrengthCalculator` (shared: profile_setup, profile, Home card → `lib/core/logic/`), `DiscoverVisibilityRules` (discover, connections → `lib/core/logic/`), `PostLimits`, `FeedOrdering` (feed).

## Composition Root (DECIDED)

`lib/main.dart` only — the single place where concrete classes are created:

1. `WidgetsFlutterBinding.ensureInitialized()`, Firebase init (FCM + Crashlytics), `Supabase.initialize` with URL/anon key from `--dart-define`, error handlers wired to `ErrorReporter`.
2. Create `SupabaseClient` (from `Supabase.instance.client`, read once here), `Dio` (configured by `lib/core/network/`) and service implementations.
3. Create repository implementations with constructor injection and register them by interface type: `MultiRepositoryProvider(providers: [RepositoryProvider<ProfileRepository>(create: (_) => SupabaseProfileRepository(client)), ...])`.
4. App-wide blocs (e.g. `AuthBloc`) in `MultiBlocProvider`, then `AsatizaApp()` wiring the go_router config and theme from `lib/core/`.

Choosing Supabase vs later Python API implementations happens only here.

## Lifecycle

- Auth state stream drives the go_router redirect (signed-out → OTP pending → profile setup (skip-able) → tabs).
- Realtime channels and stream subscriptions are opened in blocs/cubits and cancelled in `close()`.
- FCM token is registered (through `PushNotificationService` + `NotificationRepository`) after sign-in and removed on sign-out/account deletion.

## Conflict-Resolution Note

Generic rule "documentation must not introduce architecture" is merged with the owner's plan: the architecture above is owner-approved, so docs describe it as the DECIDED target. It becomes VERIFIED only when it exists in code. If code differs from the plan, code wins for VERIFIED facts; the gap is recorded in `KNOWN_ISSUES.md` and the owner decides. Never silently "fix" either side.

## Architecture Rules

- One state-management library: BLoC (`flutter_bloc`), Cubit by default. No Riverpod, GetX, MobX, `get_it` or direct `provider`.
- Dependency injection by constructor; repositories and services registered by interface type with `RepositoryProvider`/`MultiRepositoryProvider`.
- HTTP: `supabase_flutter` for Auth, database, Storage, Realtime; Dio for Edge Function calls and the later Python API. Dio instance configured in `lib/core/network/` (base URL, timeouts, auth-token interceptor, logging in debug only).
- One router (go_router). No `Navigator.push` route tables outside it except dialogs/sheets.
- One data path per feature: bloc/cubit → repository interface → implementation.
- `SupabaseClient` and `Dio` are used only inside repository implementations (`lib/data/repositories/supabase/`, later `api/`), received through constructors; `Supabase.instance` is read only in `lib/main.dart`.
- Platform plugins (`firebase_*`, `flutter_local_notifications`, `flutter_image_compress`, `image_picker`) are imported only by their service implementation in `lib/core/services/`.
- Repository interfaces are the contract the Python API must also satisfy; changes are HIGH risk.
- No parallel architectures, duplicate repositories, or feature-local Supabase clients.

## Development Rule

All 1.0 structure is created through approved phases, created one at a time by the developer. Update this file's VERIFIED sections whenever a phase closes.
