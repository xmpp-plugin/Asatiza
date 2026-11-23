# Directory Structure

## Verified Tree (updated 2026-11-19, `PHASE_001`)

VERIFIED 2026-11-23 (`PHASE_004`): `lib/core/config/` (`AppConfig`), `lib/data/repositories/supabase/` (Supabase implementations + mappers), `supabase/migrations/`, `supabase/tests/` (manual SQL checks), `env/dev.example.json` (key names only; real `env/*.json` are git-ignored), `test/core/config/`, `test/data/supabase/`.

VERIFIED 2026-11-19 (`PHASE_002`): added `assets/icons/` (42), `assets/illustrations/` (6), `assets/images/` (2 logos); `lib/core/{errors,logic,session,utils}/`, 18 new widgets in `lib/core/widgets/`; `lib/data/models/` (+ `enums/`), `lib/data/repositories/` (+ `mock/`), `lib/data/mock/`; features `onboarding`, `auth`, `profile_setup`, `feed`, `post`, `safety` with `bloc/`, `logic/`, `presentation/` (+ `widgets/`). Mock folders hold UI-phase stand-ins only; screens and cubits never import them.

VERIFIED 2026-11-23 (`PHASE_003`): new features `lib/features/{connections,profile,settings}/`; `discover`, `chat`, `notifications` filled in (`bloc/`, `logic/`, `presentation/widgets/`); `lib/data/mock/{mock_connections,mock_chats,mock_notifications}.dart`; 13 new widgets in `lib/core/widgets/`; `lib/core/session/shell_badges_*`.

```
asatiza/
  .claude/skills/asatiza-docs-and-phases/   project skill (this workflow)
  CLAUDE.md                                 rules Claude Code reads first
  android/                                  Flutter-generated Android project (build.gradle.kts)
  ios/                                      Flutter-generated iOS project (Runner.xcodeproj)
  assets/fonts/                             bundled fonts + OFL licenses (declared one by one)
  assets/logos/                             app icons and logos (not yet wired into launchers)
  assets/*.pdf                              product plans (not bundled)
  l10n.yaml                                 gen-l10n config
  lib/main.dart                             composition root (boot)
  lib/app.dart                              AsatizaApp root widget
  lib/core/theme/ lib/core/router/ lib/core/widgets/
  lib/features/{feed,discover,chat,notifications,post}/presentation/
  lib/l10n/                                 app_en.arb + generated AppLocalizations
  test/                                     app, router and theme tests
  docs/                                     documentation + phases + product plans
  analysis_options.yaml                     flutter_lints
  pubspec.yaml / pubspec.lock
  README.md                                 Flutter starter README
  .dart_tool/ .idea/ asatiza.iml .metadata  tool/IDE files (not catalogued)
```

## Decided Structure

```
lib/
  main.dart                    composition root only
  app.dart                     AsatizaApp root widget (theme, localization, router)
  l10n/                        app_<locale>.arb + generated AppLocalizations
  core/                        theme, router, network (Dio setup), constants, env config, shared widgets, utils, error types
    logic/                     shared pure-Dart business rules (2+ features)
    services/                  plugin wrappers: interfaces + one implementation each
  data/
    models/                    immutable models with fromJson/toJson
    repositories/              abstract interfaces (*_repository.dart)
      supabase/                Supabase implementations (supabase_*_repository.dart)
      api/                     future Python API implementations
  features/
    <feature>/                 auth, onboarding, profile_setup, feed, post, discover,
                               connections, chat, notifications, profile, settings
      presentation/            screens; widgets/ for extracted feature widgets
      bloc/                    Blocs/cubits with their events and states
      logic/                   pure-Dart business rules for this feature
supabase/
  migrations/                  one SQL file per schema change
  functions/                   Edge Functions (e.g. send-push)
test/                          mirrors lib/
integration_test/              end-to-end flows
docs/                          documentation
```

## Folder Responsibilities

| Folder | Owns | Must not contain |
|---|---|---|
| `lib/core/` | Cross-feature theme, router, network (Dio client setup and interceptors only), constants, env config, shared widgets, utils, failures | Feature business logic, Supabase calls, endpoint calls |
| `lib/core/logic/` | Pure-Dart rules shared by 2+ features | Flutter, Supabase, Dio or plugin imports |
| `lib/core/services/` | Plugin wrapper interfaces and their implementations | Business rules, Supabase calls |
| `lib/data/models/` | Immutable data classes, JSON mapping | Widgets, Supabase calls |
| `lib/data/repositories/` | Abstract repository contracts | Implementation details |
| `lib/data/repositories/supabase/` | All `SupabaseClient` and Dio usage (constructor-injected), error mapping | Widgets, blocs/cubits, `Supabase.instance` |
| `lib/features/<f>/presentation/` | Screens and feature widgets | Supabase, Dio or plugin imports, SQL, business rules |
| `lib/features/<f>/bloc/` | Blocs/cubits, events and states for the feature | Direct Supabase, Dio or plugin usage, widgets, business calculations |
| `lib/features/<f>/logic/` | Pure-Dart business rules for the feature | Flutter, Supabase, Dio or plugin imports |
| `supabase/migrations/` | Schema, RLS, triggers, functions, buckets | Edits to already-applied files |
| `supabase/functions/` | Edge Functions | Secrets in source |

## Placement Rules

- New screen → `lib/features/<feature>/presentation/<name>_screen.dart`.
- New cubit → `lib/features/<feature>/bloc/<name>_cubit.dart` + `<name>_state.dart`; new bloc → `<name>_bloc.dart` + `<name>_event.dart` + `<name>_state.dart`.
- New business rule → `lib/features/<feature>/logic/<name>.dart` (2+ features → `lib/core/logic/`, approval required).
- New plugin wrapper → `lib/core/services/<name>.dart` (interface) + `<technology>_<name>.dart` implementation beside it.
- Extracted screen part → `lib/features/<feature>/presentation/widgets/<name>.dart`; one public class per file.
- Widget used by 2+ features → `lib/core/widgets/` (approval required: shared component).
- New table/column/policy → new migration file `supabase/migrations/YYYYMMDDHHMMSS_short_description.sql`.
- Tests mirror the file under test: `lib/a/b.dart` → `test/a/b_test.dart`.

## Forbidden Without Approval

New top-level folders in `lib/`; a second state-management library; screens, widgets, blocs or logic importing `supabase_flutter`, `dio` or platform plugins; reading `Supabase.instance` outside `lib/main.dart`; repositories importing blocs/cubits; editing generated files; editing an applied migration; moving or renaming existing files; a root-level `phases/` folder.
