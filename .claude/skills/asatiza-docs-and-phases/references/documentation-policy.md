# Documentation Policy

Use for "init docs", "set up docs", "update docs", "audit docs" and after any change that makes docs stale. `docs/phases/templates/NEW_DOCUMENTATION_GENERATE_PROMPT.md` is the full generic procedure; this file adds the Asatiza rules.

Documentation tasks never change production code, tests, `pubspec.yaml`, `pubspec.lock`, `analysis_options.yaml`, native `android/` or `ios/` files, `supabase/` migrations or functions, CI, or build files.

## Mode

- **New project mode:** no `pubspec.yaml` and no `lib/` → read `docs/product/*`, ask only for missing items (below), create the doc set labelled DECIDED, create the empty phase system. Do not pre-seed phases; the developer creates them one at a time.
- **Existing project mode:** `pubspec.yaml` or `lib/` exists → audit first. A fresh `flutter create` starter app counts as existing: document the starter code as VERIFIED and the planned structure as DECIDED.

Items to ask the owner when unknown (one short list):

- Android package name / iOS bundle ID (e.g. `com.asatiza.app`).
- Android first, or Android + iOS together in v1.0?
- Who approves phases and does manual testing?
- Is the Supabase project already created? (yes/no only — no keys)
- Any extra testing expectations (e.g. minimum widget tests per feature)?

If the owner does not answer, record each as `UNVERIFIED — developer confirmation required` and continue.

## Existing Project Audit

Record what you actually inspected.

1. Baseline: `git status`, current branch, uncommitted changes (record, do not touch). If the folder is not a Git repository, record that.
2. Manifests & config: `pubspec.yaml`, `analysis_options.yaml`, `l10n.yaml`, `.github/workflows/*`, `supabase/config.toml`.
3. Composition root: `lib/main.dart` (and `bootstrap`/`app.dart`): Supabase init, Firebase init, `MultiRepositoryProvider`/`MultiBlocProvider`, router, theme, error handlers.
4. Source map: `lib/core/`, `lib/data/models/`, `lib/data/repositories/` (interfaces, `supabase/`, `api/`), `lib/features/<feature>/`.
5. Backend: `supabase/migrations/*.sql`, `supabase/functions/*`, seed files.
6. Platform: `android/` and `ios/` — app IDs, permissions, FCM setup presence, deep-link config. Never read secret file contents into docs.
7. Tests: `test/`, `integration_test/`, helpers and mocks.
8. Generated/external (do not catalogue file-by-file): `*.g.dart`, `*.freezed.dart`, `build/`, `.dart_tool/`, `ios/Pods/`, `.symlinks/`, `generated_plugin_registrant.*`, `lib/l10n/generated/`.
9. Findings: duplicate responsibilities, screens calling Supabase directly, missing RLS, TODOs, dead code → `docs/KNOWN_ISSUES.md`. Do not refactor.
10. Compare code with `docs/product/VERSION_1_PLAN.md`; record gaps.

## Documentation Set

| File | Content |
|---|---|
| `PROJECT_OVERVIEW.md` | Identity, purpose, roles, roadmap summary, stack, entry points, high-risk flows |
| `DIRECTORY_STRUCTURE.md` | Tree, folder responsibilities, placement rules, forbidden changes |
| `ARCHITECTURE.md` | Layers, dependency direction, module table, composition root, conflict-resolution note, ban on parallel architectures |
| `FILE_CATALOG.md` | Every project-owned file under `lib/`, `supabase/`, `test/`, `integration_test/` |
| `CLASS_AND_COMPONENT_RULES.md` | Rules per class category |
| `API_REFERENCE.md` | Supabase contracts per repository; later the Python API contract |
| `STATE_MANAGEMENT.md` | BLoC/Cubit usage, naming, providing, disposal, async states |
| `DATABASE_AND_CACHE.md` | Tables, columns, RLS, triggers, buckets, migrations, local cache, free-plan limits |
| `NAVIGATION.md` | go_router routes, auth redirect, role-aware tab, push taps |
| `COMMON_COMPONENTS.md` | Shared widgets, theme, validators, helpers |
| `ERROR_HANDLING.md` | Exceptions → failures → user messages; Crashlytics |
| `NAMING_CONVENTIONS.md` | Naming rules + actual local style |
| `CODING_STANDARDS.md` | Dart style, lints, null safety, immutability, async rules |
| `TESTING_GUIDE.md` | Test folders, commands, manual test matrix, RLS test accounts |
| `CHANGE_APPROVAL_RULES.md` | Risk levels and approval rules |
| `KNOWN_ISSUES.md` | Verified issues, risks, tech debt, plan-vs-code gaps |
| `PHASE_WORKFLOW.md` | Phase workflow in plain words |
| `phases/` | `README.md`, `PHASE_INDEX.md`, `items/`, `state/PHASE_STATE.md`, `templates/` |
| `product/` | Owner product plans (read-only) |

## Repeat-Run Rules

1. Re-audit the repo and existing docs.
2. Update only stale, missing or wrong content; keep valid history, phase records and decisions.
3. Don't duplicate facts — link to the authoritative doc.
4. Update `FILE_CATALOG.md` only for new, changed, moved or removed files.
5. Promote DECIDED → VERIFIED only when seen in code.
6. Record unknowns as UNVERIFIED; keep dates accurate and name the evidence used.

## Docs Report

After every documentation operation report: docs created/modified/deleted with one-line purpose; verified findings; plan-vs-code gaps and how they were resolved; UNVERIFIED items; commands run and exact results; phase status summary; and confirmation that production code, packages, config and generated files were not changed.
