# State Management

## Verified

VERIFIED 2026-11-23 (`PHASE_003`): 15 new cubits — `DiscoverCubit`, `PublicProfileCubit`, `SearchCubit` (discover); `ConnectRequestCubit`, `ConnectionsCubit` (connections); `ChatsCubit`, `ChatCubit` (chat); `NotificationsCubit`; `MyProfileCubit`, `EditProfileCubit` (profile); `SettingsCubit`, `ChangePasswordCubit`, `BlockedUsersCubit`, `DeleteAccountCubit` (settings); `ShellBadgesCubit` (`lib/core/session/`, provided by `MainShell` per signed-in user). Filters, visibility and note limits live in pure-Dart logic classes (`TeacherFilter`, `StudentFilter`, `DiscoverVisibilityRules`, `ConnectNoteRules`).

VERIFIED 2026-11-19 (`PHASE_002`): `flutter_bloc ^9.1.1` and `equatable ^3.0.0` added. `SessionCubit` (signed in/out, `needsSetup`) is provided above `MaterialApp.router`; screen cubits are created per route with `BlocProvider` and get repositories via `context.read<XRepository>()` in `create`. States are immutable `Equatable` classes with an explicit status enum. Stream subscriptions are cancelled in `close()`; the OTP countdown timer is cancelled in `OtpCubit.close()`.

No state-management package; `MyHomePage` uses `setState` (starter code). VERIFIED

## Decided: BLoC (`flutter_bloc`) — owner decision 2026-11-18

The PDF plan lists `flutter_riverpod`; the owner replaced it with BLoC. `docs/product/` is left unchanged.

- **Cubit by default** for simple screen state (forms, profile setup steps, filters, settings toggles).
- **Bloc with events** for event-heavy flows: auth session, chat conversation (Realtime), feed paging, notifications.
- Files live in `lib/features/<feature>/bloc/`: `<name>_cubit.dart` + `<name>_state.dart`, or `<name>_bloc.dart` + `<name>_event.dart` + `<name>_state.dart`.
- **Dependency injection:** repositories are created once in `lib/main.dart` and provided with `MultiRepositoryProvider`; app-wide blocs (e.g. `AuthBloc`) with `MultiBlocProvider` above `MaterialApp.router`. Screen-scoped blocs/cubits are created with `BlocProvider` at the route/screen and receive their repositories, services and logic classes through the **constructor** (`create: (context) => ProfileCubit(context.read<ProfileRepository>(), const ProfileStrengthCalculator())`). Repositories are always registered and read by their **interface** type. Blocs never call `context.read` themselves.
- **No** `get_it`, Riverpod, GetX, MobX or direct `provider` package usage.
- **Async states:** every state that loads data exposes an explicit status (`initial`, `loading`, `success`, `failure`) plus data and a failure object; screens render all of them.
- **UI:** `BlocBuilder` / `BlocSelector` for rendering, `BlocListener` for one-off effects (navigation, snackbars), `BlocConsumer` when both are needed. `context.read` for calling methods/adding events, never inside `build` for rebuilding.
- **Lifecycle:** stream subscriptions and Realtime channels opened in a bloc/cubit are cancelled in `close()`. Never emit after close (check `isClosed` after awaits).
- **Navigation:** go_router redirects listen to `AuthBloc` through a `refreshListenable` wrapper around the bloc stream.
- State equality (`equatable`) and code generation (`freezed`): UNVERIFIED — developer confirmation required; do not add without approval.
- Testing: `bloc_test` (dev dependency) is recommended — requires approval when first added.

## Rules

- Do not add a second state-management library.
- Blocs/cubits never import `supabase_flutter` or `dio`; they call repository interfaces only.
- Do not create parallel blocs/cubits for an existing flow.
- Business rules and calculations live in logic classes (`lib/features/<feature>/logic/`), not inside blocs/cubits (see SOLID rules in `CLASS_AND_COMPONENT_RULES.md`).
- One bloc/cubit per responsibility; blocs do not call other blocs directly — coordinate through the UI (`BlocListener`) or a shared repository stream.
- Naming: `XCubit`, `XBloc`, `XEvent`, `XState` (see `NAMING_CONVENTIONS.md`).
