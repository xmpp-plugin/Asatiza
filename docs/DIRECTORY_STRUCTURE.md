# Directory Structure

## Verified Tree (audit 2026-11-18)

```
asatiza/
  .claude/skills/asatiza-docs-and-phases/   project skill (this workflow)
  CLAUDE.md                                 rules Claude Code reads first
  android/                                  Flutter-generated Android project (build.gradle.kts)
  ios/                                      Flutter-generated iOS project (Runner.xcodeproj)
  lib/main.dart                             starter counter app
  test/widget_test.dart                     starter widget test
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
