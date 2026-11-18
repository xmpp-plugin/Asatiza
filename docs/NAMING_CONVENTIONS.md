# Naming Conventions

## Verified Local Style

Starter code only: `snake_case.dart` files, `PascalCase` classes, `camelCase` members, `_private` state class. VERIFIED

## Rules

- Files `snake_case.dart`; classes `PascalCase`; members and constants `camelCase` (Dart style).
- Screens `*Screen`; widgets descriptive (`PostCard`, `PersonCard`, `OtpInput`).
- Cubits `*Cubit`; blocs `*Bloc`; events `*Event` (subclasses past-tense, e.g. `LoginSubmitted`); states `*State`. Files `<name>_cubit.dart`, `<name>_bloc.dart`, `<name>_event.dart`, `<name>_state.dart`.
- Repositories `*Repository` (interface) + `Supabase*Repository` (implementation) + later `Api*Repository`; test doubles `Fake*Repository`.
- Services: interface by role (`PushNotificationService`, `ErrorReporter`, `ImageCompressor`, `ImagePickerService`); implementation prefixed by technology (`FirebasePushNotificationService`, `CrashlyticsErrorReporter`).
- Logic classes named for the rule they own (`ProfileStrengthCalculator`, `DiscoverVisibilityRules`, `PostLimits`).
- Failures `*Failure`; models are singular nouns (`Profile`, `Post`, `Message`).
- Booleans `is/has/can/should`.
- Tests `*_test.dart` mirroring the file under test.
- DB tables plural snake_case; columns snake_case; migrations `YYYYMMDDHHMMSS_short_description.sql`.
- Storage buckets kebab-case (`post-images`); Edge Functions kebab-case (`send-push`).
- Phase files `PHASE_<SEQ>_<MODULE>_<ACTION>_<SHORT_DESCRIPTION>.md`.
