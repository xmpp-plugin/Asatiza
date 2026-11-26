# Class And Component Rules

Status: DECIDED rules for all new code (owner decision 2026-11-18: SOLID, `logic/` classes, split profile repositories). No project classes exist yet beyond the starter app.

## Categories

- **Screens / widgets:** UI only; read state with `BlocBuilder`/`BlocSelector`/`BlocListener` and call `context.read<X>()` for actions; no Supabase, Dio, Firebase or other plugin imports; no SQL, no business rules or calculations; handle loading/success/failure states. One public widget per file; split a screen into widgets under `presentation/widgets/` when its `build` grows beyond ~150 lines or contains independent sections.
- **Blocs / cubits:** hold screen state; receive repository interfaces, services and logic classes through the **constructor**; delegate calculations and rules to logic classes; expose an explicit status (initial/loading/success/failure) with data and failure; cancel subscriptions in `close()`; never navigate, show dialogs or touch `BuildContext`. Split a bloc/cubit that serves more than one concern.
- **Logic classes:** pure Dart business rules and calculations (e.g. `ProfileStrengthCalculator`, `DiscoverVisibilityRules`, `PostLimits`, `FeedOrdering`) in `lib/features/<feature>/logic/`; used by 2+ features → `lib/core/logic/` (shared, approval required). No Flutter, Supabase, Dio or plugin imports; deterministic; always unit-tested. The server enforces the same rules (RLS / Postgres functions); client logic is for display, validation and fast feedback only.
- **Repository interfaces:** abstract classes in `lib/data/repositories/*_repository.dart`; small and shaped around the screens that use them; every public method has a documented contract (see Liskov below); return models, never raw JSON maps, Supabase rows or plugin types; the contract the Python API must also satisfy; any change is HIGH risk.
- **Repository implementations:** `Supabase*Repository` in `lib/data/repositories/supabase/` (later `Api*Repository` in `api/`); receive `SupabaseClient` and, when needed, `Dio` through the **constructor** (never `Supabase.instance.client` or another global); map `PostgrestException`, `AuthException`, `StorageException`, `DioException`, `SocketException` and timeouts to `*Failure` types — no raw exception leaves a repository.
- **Services:** small interfaces in `lib/core/services/` that wrap platform plugins, with one implementation each beside them: `PushNotificationService` (`firebase_messaging` + `flutter_local_notifications`), `ErrorReporter` (`firebase_crashlytics`), `ImageCompressor` (`flutter_image_compress`), `ImagePickerService` (`image_picker`). Only the implementation imports the plugin; it receives plugin instances through its constructor.
- **Models:** immutable; `fromJson`/`toJson` map DB snake_case ↔ Dart camelCase; IDs are UUID strings; store Storage paths, not URLs; use `copyWith` for updates; no business rules beyond simple derived getters.
- **Edge Functions / Postgres functions:** each listed in `API_REFERENCE.md` with inputs, outputs and callers.
- **Failures:** `*Failure` types in `lib/core/errors/`; user messages are mapped in one place.

## SOLID Rules

- **S — Single responsibility:** one reason to change per class. Widgets render, blocs/cubits coordinate state, logic classes decide rules, repositories move data, services wrap plugins, models hold data. One public class per file.
- **O — Open/closed:** extend by adding, not by editing working code. A new backend is a new implementation (`Api*Repository`) of the same interface, never edits to `Supabase*Repository`. The implementation choice lives in one place — the composition root in `lib/main.dart` — so it can later follow the remote per-repository setting (plan section 14). Push-notification tap routing uses one handler per notification `type`, registered in a map, not a growing `switch` spread across screens.
- **L — Liskov substitution:** every implementation of an interface — Supabase, later Python API, and test fakes — honours the same documented contract: same return types, same declared `*Failure` types only, same null semantics, same sort order and paging behaviour, same side effects. A bloc must work unchanged with any of them.
- **I — Interface segregation:** no repository serves unrelated screens. Split an interface when its callers use disjoint groups of methods. Blocs/cubits depend only on the interfaces they actually call. Decided split: `ProfileRepository` (my profile, setup, edit, other user's profile), `DiscoverRepository` (Teachers/Students lists, search, filters), `MediaRepository` (all uploads: avatars, certificates, post images, chat images).
- **D — Dependency inversion:** blocs, cubits and logic classes depend on abstractions. Concrete classes (`SupabaseClient`, `Dio`, `Supabase*Repository`, service implementations) are created only in the composition root and registered **by interface type**, e.g. `RepositoryProvider<ProfileRepository>(create: (_) => SupabaseProfileRepository(client))`. No class reaches a global singleton (`Supabase.instance`, `FirebaseMessaging.instance`, `FirebaseCrashlytics.instance`) from inside its methods.

## Test Doubles

DECIDED (PHASE_007): mock repositories live in `lib/` only while the app still runs them. Once a feature is real, its mock moves to `test/fakes/` (test-only) and honours the same interface contract; production code never imports `test/`.

## Repository Method Contract

Document on every interface method (Dart doc comment) and in `API_REFERENCE.md`:

- What it returns (including empty results) and nullability.
- Which `*Failure` types it can throw.
- Sort order, page size and paging cursor, when it returns a list.
- Side effects (rows written, files uploaded, notifications triggered).

## Abstraction Balance

Abstractions are **required at boundaries** — repositories and platform services — because they enable the Python API move, testing and plugin swaps. Inside a feature, **avoid speculative abstractions**: no interface for a bloc, cubit, logic class or widget that has a single implementation. This is how the SOLID rules and the minimum-change policy fit together.

## Cleanup

Cancel Realtime channels, stream subscriptions, `TextEditingController`s, `ScrollController`s, `AnimationController`s and timers on dispose / `close()`.

## Admin-Only Fields

The app never writes `profiles.role` (after sign-up), `is_verified` or `is_hidden`. RLS must also enforce this.

## Approval

New blocs/cubits, logic classes, repositories, services, models, shared widgets, failures, routes, platform channels and Edge Functions are production additions that require approval unless listed in the approved phase.
