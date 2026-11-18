---
name: asatiza-docs-and-phases
description: Protect the Asatiza Flutter app (Quran teacher & student network) during scoped changes, documentation work and phase work. Use for Flutter features, fixes, Supabase/Firebase work, UI, BLoC state, platform work, creating or updating project docs, and phase lifecycle operations (create, approve, execute, close, pause, resume).
---

# Asatiza Docs And Phases

Use this skill to protect the Asatiza Flutter app during normal scoped changes, documentation tasks and explicit phase work. Asatiza is a LinkedIn-style network for Quran teachers and students (Flutter + BLoC (`flutter_bloc`) + go_router + Dio + Supabase + Firebase FCM/Crashlytics + Brevo SMTP).

Follow explicit developer instructions first. When a skill rule requires a pause, approval, or a narrower scope, state the exact rule and why it applies.

Normal scoped fixes do not require a phase by default. Phase work uses separate, traceable operations:

1. Create Phase
2. Approve Phase
3. Execute Phase
4. Close Phase

Never combine operations unless the developer explicitly requests that combination.

## Required Start and Routing

1. Always read root `CLAUDE.md` and the relevant phase document, if one exists.
2. Read `references/product-facts.md` and `references/security-and-secrets-policy.md` before any product, Supabase, Firebase, auth or safety decision. `docs/product/VERSION_1_PLAN.md` and `docs/product/FULL_PRODUCT_PLAN.md` are the product source of truth; never edit them unless the owner asks.
3. Read only the project documentation that changes the current decision:
   - Architecture, module boundary, naming, reusable UI, or state work: `docs/ARCHITECTURE.md`, `docs/DIRECTORY_STRUCTURE.md`, `docs/NAMING_CONVENTIONS.md`, `docs/CLASS_AND_COMPONENT_RULES.md`, and the applicable component/state documents.
   - Supabase, persistence, navigation, error, test, or platform work: the matching project document and policy reference.
   - Explicit phase work: `docs/PHASE_WORKFLOW.md`, `docs/CHANGE_APPROVAL_RULES.md`, `docs/phases/README.md`, index/state, and the matching operation reference.
4. For explicit phase work, read the operation reference that matches the request:
   - Create phase: `references/create-phase.md`
   - Approve phase: `references/approve-phase.md`
   - Execute phase: `references/execute-phase.md`
   - Close phase: `references/close-phase.md`
   - Pause/resume an active phase: `docs/PHASE_WORKFLOW.md` (Temporary Pause section)
5. For "init docs", "set up docs", "update docs" or "audit docs", read `references/documentation-policy.md` and `docs/phases/templates/NEW_DOCUMENTATION_GENERATE_PROMPT.md`.
6. For "phase status", report from `docs/phases/PHASE_INDEX.md` and `docs/phases/state/PHASE_STATE.md` only. Do not modify code.
7. For a normal scoped change, use the routing, app-protection, development-efficiency, and required-change-report rules in this file. Do not load unrelated workflow documents.
8. For Supabase/API, reusable UI, approval, testing, architecture-risk, readiness, active-phase or index work, read the matching policy reference before acting.

`SKILL.md` is the routing and safety entry point. The operation references are canonical for detailed procedures; phase documents are canonical for phase history. `PHASE_INDEX.md` is generated summary data. `PHASE_STATE.md` is a manually maintained operational record for approvals, handoffs, manual testing, and interruptions.

## Backend Source Resolution

For any Supabase, Firebase or email issue, audit, or requested change, inspect the repository before assuming behavior:

- Supabase schema and RLS: `supabase/migrations/*.sql` is authoritative for what the app expects; the remote project may differ. Record differences as findings; never "fix" the remote project without explicit approval.
- Edge Functions: `supabase/functions/<name>/`. Deploying is a remote action that needs explicit approval.
- Supabase client usage: only `lib/data/repositories/supabase/`. A screen, widget, bloc, cubit or logic class importing `supabase_flutter`, `dio` or a platform plugin, or any class outside `lib/main.dart` reading `Supabase.instance`, is a finding.
- Firebase: FCM and Crashlytics only. Never add Firestore, Firebase Auth or Firebase Storage.
- Config: Supabase URL and anon key come from `--dart-define`/env config. Never read or record secret file contents.

Before claiming a backend fix is used by the app, verify that the migration/function exists in the repo and say whether it has been applied to the remote project (normally `UNVERIFIED — developer confirmation required`).

## Phase Storage

Use only `docs/phases/`.

- Phase documents: `docs/phases/items/`
- Phase state snapshots and handoff notes: `docs/phases/state/`
- Templates: `docs/phases/templates/`
- Index: `docs/phases/PHASE_INDEX.md`

Do not create or use status folders such as `planned/`, `active/`, `blocked/`, `completed/`, or `cancelled/` for phase documents. Status lives inside the phase document, `docs/phases/PHASE_INDEX.md`, and `docs/phases/state/PHASE_STATE.md`.

Do not create or use a second root-level `phases/` directory.

Phase file names: `PHASE_<SEQUENCE>_<MODULE>_<ACTION>_<SHORT_DESCRIPTION>.md` (see `docs/PHASE_WORKFLOW.md`). Phases are created one at a time on developer request; do not pre-seed a backlog. Create Phase reads scope from `docs/product/VERSION_1_PLAN.md`.

## Project Posture

Treat the app as a production-bound business application built against an owner-approved plan. Preserve the decided architecture (BLoC/Cubit with constructor injection and RepositoryProvider, go_router, logic classes, repository and service interfaces, Supabase + Dio implementations) and the SOLID rules in `docs/CLASS_AND_COMPONENT_RULES.md` (checklist in `references/architecture-review.md`), directory structure, module boundaries, models, repositories, common widgets, theme, assets, business rules, and native Android/iOS configuration.

Label documentation facts `VERIFIED`, `DECIDED` or `UNVERIFIED`. Docs describe the plan as the `DECIDED` target until the code exists.

Use the smallest complete, safe, and maintainable change for approved work. Solve the approved scenario fully, including required null safety, error handling, lifecycle handling, cleanup (Realtime/stream subscriptions, controllers, timers), platform handling, RLS, and tests, while avoiding unrelated cleanup, broad refactors, speculative abstractions inside features (boundary interfaces for repositories and services are required), dependency changes, and working-code rewrites.

Do not automatically refactor. Before any required refactor, explain why the existing code cannot safely support the fix, what files/classes would change, affected flows, behavior changes, rollback, and wait for approval unless the phase already approved that refactor.

## Phase States

Use only these states:

`PLANNED`, `APPROVED`, `ACTIVE`, `CLOSED`.

Track detailed progress with separate fields in each phase document:

- `Current step`: `ANALYSIS`, `APPROVAL`, `EXECUTION`, `MANUAL_TEST`, `CLOSURE`, or `NONE`.
- `Approval`: `PENDING`, `APPROVED`, `NOT_REQUIRED`, or `CHANGES_REQUESTED`.
- `Outcome`: `NONE`, `COMPLETED`, `BLOCKED`, or `CANCELLED`.

Default lifecycle:

`PLANNED -> APPROVED -> ACTIVE -> CLOSED`

Examples:

- Waiting for information: `Current status: PLANNED`, `Current step: ANALYSIS`, `Approval: PENDING`, `Outcome: NONE`.
- Ready to execute: `Current status: APPROVED`, `Current step: APPROVAL`, `Approval: APPROVED`, `Outcome: NONE`.
- Implemented and waiting for developer manual testing: `Current status: ACTIVE`, `Current step: MANUAL_TEST`, `Approval: APPROVED`, `Outcome: NONE`.
- Manual test failed: `Current status: ACTIVE`, `Current step: MANUAL_TEST`, `Outcome: NONE`, with failed cases recorded.
- Completed: `Current status: CLOSED`, `Current step: CLOSURE`, `Outcome: COMPLETED`.
- Blocked or cancelled: `Current status: CLOSED`, `Outcome: BLOCKED` or `CANCELLED`.

Every phase document remains in `docs/phases/items/` for its entire lifecycle. Update the status field, generated index, and manual state record instead of moving the file between status directories.

## Operation Routing

- A normal scoped bug fix, small improvement, or maintenance request with no active phase must be handled directly. Do not create a phase file, phase directory, or increment phase numbering unless the developer explicitly asks to create/start a phase or the request is clearly phase-based.
- "Create phase" means analyze only, create or update a phase under `docs/phases/items/`, set status `PLANNED`, update the phase index and state snapshot, and stop.
- "Approve phase" means verify readiness and explicit developer approval, set status `APPROVED`, set approval `APPROVED`, update the index and state snapshot, and stop.
- "Execute phase" means execute only an `APPROVED` phase whose readiness checklist is complete, set status `ACTIVE` and step `EXECUTION`, implement approved scope, run only relevant technical checks, fix newly introduced in-scope issues, log every changed file, update `docs/FILE_CATALOG.md` and affected docs, keep status `ACTIVE`, set step `MANUAL_TEST`, update the index and state snapshot, and stop for developer manual testing.
- "Close phase" means use explicit developer manual-test results or a clear successful manual-test confirmation for the current phase, set status `CLOSED`, set step `CLOSURE`, set outcome `COMPLETED`, `BLOCKED`, or `CANCELLED`, update the index and state snapshot, optionally commit only when explicitly approved, and stop.
- "Pause phase" / "Resume phase" means record or clear a temporary-pause handoff without changing lifecycle fields (see `docs/PHASE_WORKFLOW.md`).
- "Resume failed phase" means update the same active phase for an in-scope manual-test failure; create a new planned phase only for unrelated issues.
- "Check phase status" means report status only. Do not modify code.
- "Init docs" / "Update docs" means follow `references/documentation-policy.md`; documentation tasks never change production code, tests, packages, native config, migrations or CI.

## One Active Phase

By default, only one phase may have status `ACTIVE`. Do not begin another feature or bug fix during an active phase. A second active phase or urgent interruption requires explicit developer approval and must be recorded in both affected phase files, `docs/phases/PHASE_INDEX.md`, and `docs/phases/state/PHASE_STATE.md`.

When another issue is discovered during an active phase, record it under `Out-of-scope findings`; do not fix it in the current phase.

When the developer requests a minor fix or adjustment related to the active phase, continue inside the existing active phase. Do not create another phase for that fix. Do not work on unrelated future-phase functionality until the active phase is completed, blocked, cancelled, or explicitly paused/interrupted by the developer.

## Execution Gate

Do not execute unclear or incomplete phases. Before execution, verify the business requirement, expected behavior, current behavior, scope, non-scope, root cause/gap, traced code flow (screen → bloc/cubit → repository → Supabase table/function → RLS), Supabase contract, models, design, assets, platform behavior, permissions, dependencies, native configuration, expected files, tests, rollback, dependency phases, and approval.

If information is expected from the developer, keep status `PLANNED`, step `ANALYSIS`, approval `PENDING`, and record the missing information. If execution depends on an unavailable external dependency, set status `CLOSED`, outcome `BLOCKED`, and update the state snapshot.

Do not invent temporary tables, columns, RPC functions, Edge Functions, API fields, business rules, models, routes, or platform behavior unless the phase explicitly requests a mock implementation.

## Execute Technical Checks

Every Execute Phase must complete only the technical checks that are relevant to the approved change before step can become `MANUAL_TEST`.

- Confirm the implementation remains inside approved scope and record every changed file.
- Run Git commands only for a clear purpose, such as protecting pre-existing work, identifying an unknown changed-file set, investigating suspicious/out-of-scope changes, merge/conflict checks, or preparing an explicitly approved commit.
- Do not treat `git diff --check`, `git status`, `git diff`, or `git diff --name-status` as mandatory Execute gates. Use `git diff --check` only when patch/whitespace integrity is relevant, for larger changes, merge work, commit preparation, or a justified concern.
- Format only relevant changed Dart files when formatting is needed; do not repeatedly format unchanged files or unrelated directories.
- Run lightweight safe non-launching checks during implementation, normally scoped analysis, relevant targeted tests, source assertions, or repository-owned verification scripts that fit the changed files.
- Use broad `flutter analyze`, full `flutter test`, build commands, Supabase CLI checks, or repository-wide checks only when scope/risk justifies them.
- Do not launch the app or run build/flavor commands during Execute unless the developer explicitly requests that command for the phase.
- If a command cannot run because the local environment is missing a device, credentials, writable SDK cache, flavor, Supabase CLI/project, or platform tooling, record the exact command, result, and reason.
- Fix newly introduced issues that are inside the approved phase scope.
- Do not fix pre-existing unrelated issues. Record them separately.
- If fixing a new issue requires unapproved files, classes, tables, migrations, functions, dependencies, platform changes, or architecture changes, stop, keep status `ACTIVE`, set step `APPROVAL`, and set approval `PENDING`.

## Development Efficiency

- Use `Small change = small checks`.
- Reuse recorded passing format, diff, analysis, and test results when the relevant implementation files have not changed since those checks ran.
- Do not rerun expensive checks after documentation-only phase updates, index/state updates, or while waiting for developer manual testing unless those updates changed implementation-relevant files.
- Do not run both scoped and full analysis/tests unless risk, shared/core impact, dependency/platform/Supabase changes, or failed/missing scoped evidence makes the broader command necessary.
- During Close Phase, reuse Execute technical check evidence when it is still relevant. Do not rerun format, analyze, tests, builds, or Git checks just because the phase is closing.
- If relevant implementation code changes after Execute or manual testing, rerun only the affected checks before closure.
- Do not automatically generate manual-test checklists after Execute. Provide manual test cases only when the developer asks, risk/non-obvious behavior requires it (for example RLS, OTP, push, account deletion), or project requirements explicitly require documented cases.
- Keep command reporting compact: record command, exit status, changed files, important warnings/errors, skipped reason, and whether any issue is new or pre-existing. Avoid pasting verbose successful output.

## Required Change Report

After any implementation that changes production code, tests, configuration, documentation, scripts, templates, or phase-related files, provide a short task summary, compact check results, and phase status when relevant. When production code changed, list all edited and newly created files in the final response, and record detailed changed-file logs inside phase documents when the phase workflow requires them.

## Skill Maintenance Self-Check

When this skill, its references, scripts, assets, `CLAUDE.md`, or `docs/` workflow files are changed, do not run the Flutter app. Before reporting done, run the skill and documentation checks that fit the change, such as:

- `scripts/validate_phase_structure.sh`
- `scripts/update_phase_index.sh`
- `scripts/collect_change_log.sh`
- Any changed script directly, using Bash, Python, or the script runtime itself

Record commands that cannot run and why.

## Script Runtime

The helper scripts require Git and Bash. `create_phase.sh` also requires Python 3. On Windows, run them from Git Bash or WSL at the repository root; on macOS, install Xcode Command Line Tools and Python 3. If the folder is not a Git repository, scripts fall back to the current directory. Scripts must fail with a clear prerequisite error rather than silently continuing.

## Optional Close Commit Gate

Do not auto-commit by default. During Close Phase, create a local git commit only when the developer explicitly requests or approves it.

Before committing:

- Confirm the phase is ready to close and manual testing passed.
- Review the latest changed-file evidence. Rerun Git inspection only when needed for the approved commit or when the recorded file list may be stale.
- Stage only approved phase files and required phase documentation.
- Review the staged diff before committing.
- Use a commit message containing the phase ID.
- Never push, merge, rebase, tag, release, deploy, or publish.

## Change Logging

After every Execute Phase implementation, record a change log in the phase file before setting step to `MANUAL_TEST`.

For every changed file, record:

- File path
- Change type: added, modified, deleted, renamed, generated, or unchanged/pre-existing
- Whether the file was approved in the phase
- What changed
- Why it changed
- Existing behavior preserved
- Possible side effects or regression risks
- Commands that checked this file, when applicable

Record pre-existing unrelated changes separately and do not claim ownership of them.

## Approval Rules

Medium-risk phases normally require approval. High-risk phases always require approval. Risk levels are defined in `docs/CHANGE_APPROVAL_RULES.md`.

Creating a new production file or class requires approval unless it was explicitly listed and approved in the phase plan. During execution, if an unplanned new file, class, table, migration, RPC/Edge Function, API change, dependency, model change, native change, or architecture change becomes necessary, stop, keep status `ACTIVE`, set step `APPROVAL`, and set approval `PENDING`.

Do not change dependencies, Flutter, Dart, CocoaPods, Gradle, Android Gradle Plugin, Kotlin, Swift configuration, Xcode settings, deployment targets, package names/app IDs, signing, CI/CD, environments, Supabase project settings (Auth, SMTP, OTP, rate limits), RLS or Storage policies without explicit approval.

## Security Rules

Follow `references/security-and-secrets-policy.md` at all times: no secrets in code/docs/chat, never weaken the 18+ age gate, RLS, Storage policies, report/block/moderation, teacher approval, visibility rules or account deletion, and no destructive or remote actions without explicit approval.

## Reuse-First Rule

Before creating new code, search for existing widgets, dialogs, bottom sheets, loaders, empty/error states, validators, theme tokens, assets, models, blocs/cubits, repository interfaces, Supabase repositories, failure types, cache helpers, storage helpers, navigation helpers, notification helpers, Firebase services, logging utilities, platform channels, and native helpers (see `references/reusable-components-policy.md`).

When creating something new, document why the existing implementation was not suitable.

## Useful Scripts

- `scripts/create_phase.sh <MODULE> <ACTION> "<short description>"`: Create a planned phase using the canonical template and next available sequence.
- `scripts/validate_phase_structure.sh`: Check required docs, product plans, phase directories, templates, references, assets, scripts, and root `phases/` absence.
- `scripts/validate_phase_readiness.sh <phase-file>`: Validate status, approval, outcome, checked readiness items, dependencies, and active-phase conflict before execution.
- `scripts/update_phase_index.sh`: Atomically rebuild only `docs/phases/PHASE_INDEX.md`; never write `PHASE_STATE.md`.
- `scripts/collect_change_log.sh [--verbose] [phase-file]`: Print a compact change log skeleton from current git changes; use `--verbose` when raw status/diff sections are needed.
- `scripts/validate_flutter_project.sh [--run-flutter-checks] [--verbose]`: Run compact safe read-only project checks; optionally run `flutter analyze` and `flutter test`, with verbose successful output only when requested.

Scripts must never modify production source code, approve phases, execute phases, close phases, delete project files automatically, upgrade dependencies, commit, push, merge, rebase, deploy, publish builds, or modify remote systems.
