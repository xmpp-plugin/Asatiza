# Phase Workflow

Use `asatiza-docs-and-phases` for all phase work and for normal scoped Flutter changes that must preserve the Asatiza architecture. Do not create a phase for an ordinary bug fix, small improvement, or maintenance task unless the developer explicitly asks to create/start a phase or the request is clearly phase-based.

## Phase Path

All phase documents live under `docs/phases/items/`. Phase state snapshots and handoff notes live under `docs/phases/state/`. Do not use status folders or a second root-level `phases/` directory.

## Operations

Keep these operations separate unless the developer explicitly requests a combined action. These operations apply only when phase work is explicitly requested or already active:

1. Create Phase: read-only analysis, create/update a phase document, update index/state, and stop.
2. Approve Phase: verify readiness, record explicit approval, update index/state, and stop.
3. Execute Phase: set one approved ready phase to `ACTIVE`, implement only approved scope, run only relevant technical checks, log every changed file, fix newly introduced in-scope issues, set step to `MANUAL_TEST`, and stop for developer manual testing.
4. Close Phase: require developer manual-test results or an unambiguous successful manual-test confirmation for the current phase, reuse still-valid Execute technical evidence when no relevant implementation code changed afterward, set terminal status, update index/state, optionally commit only with explicit approval, and stop.

## Lifecycle

```text
Requirement
-> Create planned phase
-> Analyze phase
-> Resolve missing information
-> Get approval
-> Set phase active
-> Execute
-> Manual test
-> Close
```

Allowed status path:

```text
PLANNED
-> APPROVED
-> ACTIVE
-> CLOSED
```

Detailed progress is recorded separately:

- `Current step`: `ANALYSIS`, `APPROVAL`, `EXECUTION`, `MANUAL_TEST`, `CLOSURE`, or `NONE`.
- `Approval`: `PENDING`, `APPROVED`, `NOT_REQUIRED`, or `CHANGES_REQUESTED`.
- `Outcome`: `NONE`, `COMPLETED`, `BLOCKED`, or `CANCELLED`.

## Storage Responsibilities

- `docs/phases/items/`: all phase documents for every status.
- `docs/phases/state/PHASE_STATE.md`: active phase snapshot, closed phase snapshot, interruption notes, closure approval notes, optional commit approval notes, and handoff notes.
- `docs/phases/templates/`: canonical phase templates.

By default, only one phase may have status `ACTIVE`. A second active phase requires explicit developer approval. If a requested minor fix belongs to the active phase, keep it inside that phase instead of creating another phase.

### Temporary Pause Of An Active Phase

A temporary pause is a documented work disposition, not a lifecycle status. There is no `PAUSED` status.

- Keep the phase status, current step, approval, and outcome unchanged.
- Record the pause date, developer request, current handoff point, pending operation, and resume prompt in the phase file, `docs/phases/PHASE_INDEX.md`, and `docs/phases/state/PHASE_STATE.md`.
- Do not use `CLOSED`, `BLOCKED`, or `CANCELLED` as a temporary pause.
- A temporarily paused phase whose status is `ACTIVE` still counts as the active phase. Starting or executing unrelated work still requires the normal phase workflow and explicit approval for an interruption or second active phase.
- Resuming clears only the temporary-pause disposition note. By default, preserve the phase's lifecycle fields and continue from the operation recorded in its handoff.
- Keep pause, resume, execute, and close requests separate unless the developer explicitly requests a combined operation.

## Normal Scoped Changes

- If there is no active phase and the developer asks for a normal bug fix, small improvement, or maintenance task, implement it directly as a scoped change. Do not create phase files, phase directories, or increment phase numbering.
- Use the same app-protection, approval, reuse-first, and minimum-change rules that apply to phase execution.
- If the task is broad, high-risk, unclear, or explicitly phase-based, ask for or create a phase only when the developer requested that workflow.
- If a phase is active and the fix is related to it, continue inside the active phase. If it is unrelated, do not implement it until the active phase is completed, blocked, cancelled, or explicitly paused/interrupted.

## Required Change Reporting

After any implementation that changes code, tests, configuration, documentation, scripts, templates, or phase-related files, report files modified, files created, files deleted, a short per-file change description, compact checks performed, and whether any active phase remains open, moved to manual testing, or was closed. This report is required after every implementation step, not only at phase closure.

## Readiness Gate

A phase cannot move to `ACTIVE` while any required readiness checkbox remains incomplete. Before execution, verify business requirement, expected behavior, current behavior, scope, non-scope, root cause/gap, relevant code flow, API existence, endpoint, method, auth, request fields, response fields, error behavior, required models, UI/design, assets, platform behavior, permissions, dependencies, native configuration, expected files, test conditions, rollback plan, phase dependencies, and approval.

Keep status `PLANNED`, step `ANALYSIS`, and approval `PENDING` when information is expected from the developer. Use status `CLOSED` with outcome `BLOCKED` when execution depends on unavailable external dependency.

Do not invent temporary APIs, response fields, business rules, models, routes, or platform behavior unless the phase explicitly requests a mock implementation.

## Phase Index

Maintain `docs/phases/PHASE_INDEX.md` with phase ID, title, module, priority, risk, dependency phases, current status, current step, approval, outcome, file path, created date, started date, and completed date. Maintain `docs/phases/state/PHASE_STATE.md` with active/closed state and handoff notes.

Phases with dependencies must not execute before dependency phases are completed.

## Phase Naming

Use:

```text
PHASE_<SEQUENCE>_<MODULE>_<ACTION>_<SHORT_DESCRIPTION>.md
```

Examples:

```text
PHASE_001_FOUNDATION_ADD_PROJECT_FOUNDATION.md
PHASE_003_AUTH_ADD_EMAIL_OTP_AUTHENTICATION.md
PHASE_011_CHAT_FIX_UNREAD_BADGE_COUNT.md
PHASE_012_PROFILE_UPDATE_STRENGTH_METER_WEIGHTS.md
```

Rules:

- Use uppercase letters and underscores.
- Use a three-digit sequence.
- Use a clear module.
- Use an action such as `ADD`, `FIX`, `UPDATE`, `REMOVE`, `INTEGRATE`, `MIGRATE`, `REFACTOR`, or `TEST`.
- Keep the short description meaningful.
- Do not reuse a phase number.
- Do not rename after implementation begins unless explicitly approved.
- Preserve the same phase ID in documentation, reports, commits, and phase output.

## Creating Phases

There is no pre-seeded backlog. The developer creates phases one at a time and executes them one by one; Create Phase takes scope from `docs/product/VERSION_1_PLAN.md`. Use `.claude/skills/asatiza-docs-and-phases/scripts/create_phase.sh` for new phases; it numbers from the highest existing phase file (the first phase is `PHASE_001`).

## Documentation Operations

"Init docs", "update docs" and "audit docs" follow `.claude/skills/asatiza-docs-and-phases/references/documentation-policy.md`. Documentation work never changes production code, tests, packages, native configuration, Supabase migrations/functions or CI.

## Prompt Templates

### Normal Scoped Change

```text
Use the `asatiza-docs-and-phases` skill.

NORMAL SCOPED CHANGE:

[BUG FIX / SMALL IMPROVEMENT / MAINTENANCE TASK]

Do not create a phase unless explicitly requested or clearly required.

Implement the smallest complete safe change within existing architecture.

After implementation, report files modified, files created, files deleted, short per-file 
change descriptions, compact checks performed, and active phase status if any.
```

### Create Phase

```text
Use the `asatiza-docs-and-phases` skill.

CREATE PHASE:

[TASK REQUIREMENT]

Perform read-only analysis. Do not modify production code. Create the phase under `docs/phases/items/`.

Trace the current flow end-to-end and verify requirements, APIs, models, UI, reusable components, platform behavior, permissions, dependencies, risks, test cases, and rollback strategy.

List every expected changed file. List every proposed new file or class and request approval for it.

When any required information is unclear, keep status `PLANNED`, set step to `ANALYSIS`, set approval to `PENDING`, and record the missing information.

When an external dependency is unavailable, set status to `CLOSED`, set outcome to `BLOCKED`, and update state.

Do not approve or execute the phase automatically.
```

### Approve Phase

```text
Use the `asatiza-docs-and-phases` skill.

APPROVE PHASE:

[PHASE_ID]

Review the complete planned phase. Do not modify production code. Verify that all readiness checks are complete.

When everything is ready and developer approval is explicit, set status to `APPROVED`, set step to `APPROVAL`, set approval to `APPROVED`, set outcome to `NONE`, record the approval, update `docs/phases/PHASE_INDEX.md` and `docs/phases/state/PHASE_STATE.md`, and report that it is ready for execution.

Do not execute it.
```

### Execute Phase

```text
Use the `asatiza-docs-and-phases` skill.

EXECUTE PHASE:

[PHASE_ID]

Execute only when the phase status is `APPROVED` and approval is `APPROVED`. Confirm there is no other `ACTIVE` phase unless explicitly approved. Keep the phase under `docs/phases/items/`. Set status to `ACTIVE` and step to `EXECUTION`.

Work only within approved scope. Do not automatically refactor. Do not create an unapproved file or class. Do not change an unapproved API, dependency, architecture, model, shared component, Android configuration, or iOS configuration.

When required information becomes unclear, stop, keep status `ACTIVE`, set step to `ANALYSIS`, and record the missing information.

When an unplanned new file, class, API change, dependency, or architecture change becomes necessary, stop, keep status `ACTIVE`, set step to `APPROVAL`, and set approval to `PENDING`.

After implementation:

- Review changed-file evidence; rerun `git status` or `git diff --name-status` only when the recorded file list may be stale
- Log every changed file and the reason for each change
- Run Git commands only for a clear purpose; `git diff --check` is not mandatory and should be used only when patch/whitespace integrity is relevant
- Format only relevant changed Dart files when required for review or technical checks; avoid repeated formatting during small edits
- Run lightweight scoped analysis, source assertions, relevant targeted tests, or repository-owned verification scripts when they fit the changed files
- Use broad `flutter analyze`, full `flutter test`, build commands, or repository-wide checks only when scope/risk justifies them
- Do not launch the app or run build/flavor commands unless the developer explicitly requested that command for the phase
- Fix newly introduced in-scope issues before moving to developer manual testing
- Record pre-existing unrelated issues separately
- Record exact commands, results, and reasons for commands that could not run
- Keep status `ACTIVE` and set step to `MANUAL_TEST`
- Do not close the phase before developer manual-test confirmation
```

### Close Phase

```text
Use the `asatiza-docs-and-phases` skill.

CLOSE PHASE:

[PHASE_ID]

Developer manual-test results:

[PASTE RESULTS]

Close when required manual tests passed and the developer explicitly requests closure, or when the developer gives an unambiguous successful manual-test confirmation for the current phase such as "tested and working". Record manual-test confirmation, tested platforms/devices when provided, failed and retested cases, final changed files, Execute technical check results, reused technical evidence, known limitations, follow-up phases, and rollback guidance. Do not rerun expensive checks during closure when Execute evidence is still valid and no relevant implementation file changed afterward.

Set status to `CLOSED`, set step to `CLOSURE`, set outcome to `COMPLETED`, add completion date, keep the phase under `docs/phases/items/`, and update `docs/phases/PHASE_INDEX.md` and `docs/phases/state/PHASE_STATE.md`.

If the developer explicitly approves a local commit, stage only approved phase files and required phase documentation, review the staged diff, commit with the phase ID in the message, and do not push.

When testing failed, do not close. Keep status `ACTIVE`, set step to `MANUAL_TEST`, 
record the failed test, and prepare only an in-scope correction.
```


### Create Planned Phase While Another Is Active

```text
Use the `asatiza-docs-and-phases` skill.

CREATE PLANNED PHASE WHILE ANOTHER PHASE IS ACTIVE:

[TASK REQUIREMENT]

Do not modify production code. Create and analyze the new phase under `docs/phases/items/`. Do not set it to an active status. Do not execute it. Report the currently active phase and any dependency between phases.
```

### Pause Active Phase

```text
Use the `asatiza-docs-and-phases` skill.

PAUSE ACTIVE PHASE:

[PHASE_ID]

Do not modify production code. Verify that the phase is currently `ACTIVE` and record a temporary pause requested by the developer.

Keep the current status, current step, approval, and outcome unchanged. Record the pause date, reason, current handoff point, pending operation, and exact resume prompt in the phase file, `docs/phases/PHASE_INDEX.md`, and `docs/phases/state/PHASE_STATE.md`.

Treat the pause as a handoff disposition only. Do not set status to `CLOSED`, outcome to `BLOCKED` or `CANCELLED`, and do not execute or close the phase.
```

### Resume Paused Active Phase

```text
Use the `asatiza-docs-and-phases` skill.

RESUME PAUSED ACTIVE PHASE:

[PHASE_ID]

Do not modify production code. Review the recorded pause handoff, phase file, `docs/phases/PHASE_INDEX.md`, and `docs/phases/state/PHASE_STATE.md`. Check Git state only when needed to verify the handoff or protect existing work.

Resume only when the phase is still `ACTIVE` and there is no conflicting active phase unless the developer explicitly approved the conflict. Preserve the current step, approval, and outcome unless a separate valid phase operation explicitly changes them.

Record the resume date and remove the temporary-pause disposition from the current handoff while
 preserving its history. Report the next allowed phase operation. Do not execute or close automatically.
```
