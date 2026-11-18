# Architecture Review

Use this reference before Create or Execute work that touches feature structure, state, repositories, Supabase, storage, navigation, shared widgets, or platform code.

Label every fact `VERIFIED` (seen in this repo), `DECIDED` (owner-approved in `docs/product/*`, not yet in code) or `UNVERIFIED — developer confirmation required`. Promote `DECIDED` to `VERIFIED` only when the code exists.

## Verified App Shape (2026-11-18 audit)

- Package: `asatiza` (`pubspec.yaml`), version `1.0.0+1`, Dart SDK `^3.11.0`. VERIFIED
- Dependencies: `flutter`, `cupertino_icons` only; dev: `flutter_test`, `flutter_lints ^6.0.0`. VERIFIED
- Entry point: `lib/main.dart` is the unmodified `flutter create` counter app (`MyApp`, `MyHomePage`). VERIFIED
- Tests: `test/widget_test.dart` (starter counter test). VERIFIED
- Native Android: `android/app/build.gradle.kts`, namespace/applicationId `com.example.asatiza` (placeholder), Java/Kotlin 17, Flutter-default min/target SDK. VERIFIED
- Native iOS: `ios/Runner.xcodeproj`; no `Podfile` yet. VERIFIED
- No `supabase/`, no `integration_test/`, no CI, no Git repository at audit time. VERIFIED

## Decided Target Shape

- State: BLoC (`flutter_bloc`) — Cubit by default, Bloc for event-heavy flows; repositories injected with `MultiRepositoryProvider` and app-wide blocs (auth) with `MultiBlocProvider` in `lib/main.dart`. DECIDED
- HTTP: `supabase_flutter` for Auth, database, Storage, Realtime; Dio (configured in `lib/core/network/`) for Edge Function calls and the later Python API. DECIDED
- Navigation: `go_router`, 5 bottom tabs (Home · Teachers/Students · + Post · Chats · Notifications), profile from top-left avatar. DECIDED
- Data flow: Screens → blocs/cubits (`lib/features/<feature>/bloc/`) → repository interfaces (`lib/data/repositories/*_repository.dart`) → `lib/data/repositories/supabase/` implementations (later `api/` for the Python FastAPI). DECIDED
- Backend v1.0: Supabase free plan — Auth (email + password, 6-digit email OTP), Postgres + RLS, Storage (`avatars`, `post-images`, `certificates`, `chat-images`), Realtime, Edge Functions. DECIDED
- Push/crashes: Firebase Cloud Messaging + Crashlytics only (no Firestore/Firebase Auth/Firebase Storage). DECIDED
- Email: Brevo SMTP connected to Supabase Auth. DECIDED
- Models: immutable, UUID string IDs, storage paths (not URLs), snake_case DB ↔ camelCase Dart. DECIDED

See `docs/ARCHITECTURE.md` and `docs/DIRECTORY_STRUCTURE.md` for the full layout.

## Review Checklist

- Keep changes inside the affected feature folder under `lib/features/<feature>/`.
- Use BLoC only (`flutter_bloc`); never add Riverpod, GetX, MobX, `get_it` or direct `provider` usage.
- Screens, widgets, blocs, cubits and logic classes never import `supabase_flutter`, `dio` or platform plugins; only repository implementations use `SupabaseClient`/Dio, received through constructors. `Supabase.instance` is read only in `lib/main.dart`.
- Repository interfaces are the contract the future Python API must satisfy — changing one is HIGH risk.
- Extend models only when the Supabase table/column exists or is approved in the phase migration.
- Add routes only in the go_router configuration under `lib/core/router/`.
- Every schema change is a new file in `supabase/migrations/`; never edit an applied migration.
- Every table has RLS enabled with explicit policies; the app never writes `profiles.role`, `is_verified` or `is_hidden`.
- Treat auth/OTP, RLS, Storage policies, Realtime, Edge Functions, FCM, account deletion, moderation and native config as high risk.
- Record duplicate or inconsistent implementations as out-of-scope findings unless the phase approved consolidation.

## SOLID Checklist (Create Phase design + Execute Phase review)

Rules: `docs/CLASS_AND_COMPONENT_RULES.md`. Record each failed item as a finding in the phase file.

- **S:** each new class has one reason to change; business rules and calculations sit in `logic/` classes, not widgets or blocs; one public class per file; large screens split into `presentation/widgets/`.
- **O:** new behaviour is added as a new implementation, handler or logic class, not by editing working code paths; implementation choice stays in `lib/main.dart`; notification taps use one handler per `type`.
- **L:** every repository/service implementation and fake honours the documented method contract (returns, nullability, paging/order, side effects) and throws only the declared `*Failure` types; no raw `PostgrestException`/`DioException` escapes.
- **I:** interfaces are small and caller-shaped; a bloc depends only on interfaces it calls; profile, discover and media access stay in separate repositories.
- **D:** dependencies arrive through constructors; repositories/services registered by interface type; no `Supabase.instance`, `FirebaseMessaging.instance` or other globals outside `lib/main.dart`; plugins only inside `lib/core/services/` implementations.
- **Balance:** no speculative interface for a class with a single implementation inside a feature.
- **Tests:** new logic classes, blocs/cubits and repository implementations have the tests listed in `docs/TESTING_GUIDE.md`.
- Treat new shared components, new layers, new repositories, new models, new tables and new platform channels as approval-required production additions.
