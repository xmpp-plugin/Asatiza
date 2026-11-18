# Claude Code Rules For Asatiza

Asatiza is a LinkedIn-style professional network for Quran teachers and students: Flutter (Android + iOS), BLoC (`flutter_bloc`), go_router, Dio, Supabase (Auth, Postgres + RLS, Storage, Realtime, Edge Functions), Firebase Cloud Messaging + Crashlytics, Brevo SMTP. Product source of truth: `docs/product/VERSION_1_PLAN.md` and `docs/product/FULL_PRODUCT_PLAN.md` (read-only unless the owner asks).

At the time of the first audit (2026-11-18) the repository is the unmodified `flutter create` starter app. The architecture below is the owner-approved (DECIDED) target; docs label facts VERIFIED, DECIDED or UNVERIFIED.

## Application Protection

- Preserve the decided directory architecture (`lib/core`, `lib/data/models`, `lib/data/repositories` + `supabase/` + `api/`, `lib/core/logic` + `lib/core/services`, `lib/features/<feature>/presentation|bloc|logic`).
- Use BLoC only (`flutter_bloc`: Cubit by default, Bloc for event-heavy flows). Do not introduce a second state-management library (no Riverpod, GetX, MobX or direct `provider`).
- Inject dependencies through constructors. Register repositories and services by their interface type with `RepositoryProvider`/`MultiRepositoryProvider` in `lib/main.dart` (the only place concrete classes are created); do not add `get_it` or another DI package.
- `supabase_flutter` handles Auth, database, Storage and Realtime; Dio handles Edge Function HTTP calls and the later Python API. Both are used only inside repository implementations, received through constructors; `Supabase.instance` is read only in `lib/main.dart` (Dio client setup lives in `lib/core/network/`).
- Screens and widgets never import `supabase_flutter`; only `lib/data/repositories/supabase/` talks to Supabase.
- Follow SOLID as defined in `docs/CLASS_AND_COMPONENT_RULES.md`: business rules in pure-Dart `logic/` classes (not in widgets or blocs); platform plugins (`firebase_*`, `flutter_local_notifications`, `flutter_image_compress`, `image_picker`) only behind `lib/core/services/` interfaces; small repository interfaces (`ProfileRepository`, `DiscoverRepository`, `MediaRepository` are separate); every implementation and fake honours the documented method contract and throws only `*Failure` types; one public class per file.
- Preserve models, repositories, common widgets, theme, assets, business rules, and native Android/iOS configuration.
- Do not introduce a second architecture, parallel blocs/cubits, repositories or API layers.
- Do not replace working code only because another approach appears cleaner.
- Do not rewrite complete features for a small issue.

## Skill And Workflow

Use the `asatiza-docs-and-phases` skill (`.claude/skills/asatiza-docs-and-phases/`) for Flutter feature development, bug fixes, Supabase/Firebase work, UI, BLoC state, repositories, platform work, notifications, realtime chat, documentation tasks, all phase operations, and normal scoped fixes. Do not automatically create a phase for ordinary bug fixes, small improvements, or maintenance tasks unless the developer explicitly asks to create/start a phase or the request is clearly phase-based.

Keep operations separate unless the developer explicitly requests a combined action:

1. Create Phase: read-only analysis and create/update a phase document under `docs/phases/items/`.
2. Approve Phase: verify readiness and explicit approval, then update the phase status/index/state.
3. Execute Phase: set exactly one approved ready phase to `ACTIVE`, implement only approved scope, run only relevant technical checks, log every changed file, fix newly introduced in-scope issues, set step to `MANUAL_TEST`, and stop for developer manual testing.
4. Close Phase: close after explicit developer manual-test confirmation or an unambiguous successful manual-test confirmation for the current phase, reuse still-valid Execute technical evidence when no relevant implementation code changed afterward, update status/index/state, and commit only with explicit approval.

Do not use a root-level `phases/` directory or status folders under `docs/phases/`. All phase documents stay in `docs/phases/items/`; current state lives in `docs/phases/state/`.

## One Active Phase

Only one phase may have status `ACTIVE` by default. A second active phase or urgent interruption requires explicit developer approval and must be recorded in the affected phase files, `docs/phases/PHASE_INDEX.md`, and `docs/phases/state/PHASE_STATE.md`.

Do not start another feature or bug fix while a phase is active. If the developer requests a minor fix related to the active phase, keep it inside that phase and report the changed files. Record unrelated out-of-scope discoveries in the active phase; do not fix them in that phase.

## Execution Gate

Do not execute unclear or incomplete phases. Before execution, verify business requirement, expected behavior, current behavior, scope, non-scope, root cause/gap, traced code flow (screen → bloc/cubit → repository → Supabase table/function → RLS), Supabase contract, models, UI/design, assets, permissions, platform behavior, dependencies, native configuration, expected files, tests, rollback plan, dependency phases, and approval status.

Keep status `PLANNED`, step `ANALYSIS`, and approval `PENDING` when developer information is needed. Use status `CLOSED` with outcome `BLOCKED` when an external dependency prevents safe progress.

## Minimum Complete Change Policy

Default implementation strategy: smallest complete, safe, and maintainable change.

- Change only what is required by the approved phase.
- Keep existing working flows unchanged.
- Avoid unrelated cleanup, broad refactoring, large rewrites, unnecessary moves or renames, new layers, speculative abstractions, and future-only code.
- Abstractions are required at boundaries (repository and service interfaces) and avoided inside features (no interface for a bloc, cubit, logic class or widget with a single implementation).
- Reuse existing components when possible.
- Include enough implementation for the task to be complete: null safety, error handling, lifecycle handling, cleanup of Realtime/stream subscriptions and controllers, platform handling, RLS, and tests when relevant.

This does not mean writing the fewest possible lines regardless of correctness.

## New Files And Classes

Creating a new production file or class requires approval unless it was explicitly listed and approved in the phase plan. Phase 1.0 work creates the decided structure only through approved phases.

If an unplanned new file, class, table, migration, RPC/Edge Function, dependency, model change, native change, shared component, or architecture change becomes necessary during execution, stop, keep status `ACTIVE`, set step to `APPROVAL`, and set approval to `PENDING`.

## No Automatic Refactoring

Refactoring is prohibited unless the phase explicitly requests it, it is essential to fix the approved issue safely, or the developer approves it before implementation. Before refactoring, explain why the existing code cannot safely support the fix, what files/classes would change, which flows may be affected, whether behavior changes, and rollback.

## Reuse First

Before creating new code, search `lib/core/` (widgets, theme, constants, utils, errors, router), `lib/data/models/`, `lib/data/repositories/`, and the affected feature folder for existing widgets, dialogs, bottom sheets, loaders, empty/error states, form fields, validators, theme tokens, icons, assets, models, blocs/cubits, repositories, failure types, helpers, and platform channels. When creating something new, document why existing code was not suitable.

## Approval Required

Do not perform these without explicit approval:

- Upgrade or add Flutter, Dart, CocoaPods, Gradle, Android Gradle Plugin, Kotlin, Swift configuration, Xcode settings, package versions, or production dependencies.
- Remove dependencies, replace plugins, change deployment targets, app identifiers, signing, CI/CD, or environment configuration.
- Modify authentication, OTP, sessions, auth redirect, Supabase schema/migrations, RLS policies, Storage bucket policies, Edge Functions, Realtime, FCM/push, Supabase Auth/SMTP/rate-limit settings, repository interfaces, the 18+ age gate, report/block/moderation/visibility rules, teacher approval, account deletion, shared core widgets/theme, shared models, or native Android/iOS code.

## Security

- Never put secrets in code, docs or chat: Supabase `service_role` key, database password, Brevo SMTP credentials, FCM service-account JSON, keystores, `.env` contents. The app uses only the Supabase URL and anon key via `--dart-define`/env config.
- For `google-services.json`, `GoogleService-Info.plist`, keystores and `.env` files record only whether they exist and where.
- The app never writes `profiles.role`, `is_verified` or `is_hidden`.
- Never deploy migrations, functions or settings to the remote Supabase project unless explicitly asked.

## Git Protection

- Inspect branch and git status before implementation when needed to protect existing uncommitted work; reuse that baseline unless relevant files changed or the file list may be stale.
- Record pre-existing unrelated changes.
- Never discard user changes. Never reset files.
- Never commit, push, merge, rebase, release, publish, or deploy unless separately requested.
- During Close Phase, a local commit is allowed only with explicit developer approval after reviewing staged files. Never push automatically.

## Required Change Reporting

After any code, test, configuration, documentation, script, template, or phase-related file modification, report files modified, files created, files deleted, a short per-file change description, compact checks performed, and whether any active phase remains open or was closed. This applies to normal scoped changes and every implementation step inside an active phase.
