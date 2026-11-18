# Phase Prompt Templates

## Normal Scoped Change

```text
Use the `asatiza-docs-and-phases` skill.

NORMAL SCOPED CHANGE:

[BUG FIX / SMALL IMPROVEMENT / MAINTENANCE TASK]

Do not create a phase unless explicitly requested or clearly required.

Preserve existing architecture, module boundaries, state management, API/repository/model patterns, shared widgets, theme, assets, business logic, and native implementation.

Implement the smallest complete safe change.

After implementation, report files modified, files created, files deleted, a short per-file change description, compact checks performed, and whether any active phase remains open or was closed.
```

## Create Phase

```text
Use the `asatiza-docs-and-phases` skill.

CREATE PHASE:

[TASK REQUIREMENT]

Perform read-only analysis.

Do not modify production code.

Create the phase under `docs/phases/items/`.

Trace the current flow end-to-end and verify requirements, APIs, models, UI, reusable components, platform behavior, permissions, dependencies, risks, test cases, and rollback strategy.

List every expected changed file.

List every proposed new file or class and request approval for it.

When any required information is unclear, keep status `PLANNED`, set step to `ANALYSIS`, set approval to `PENDING`, and record the missing information.

When an external dependency is unavailable, set status to `CLOSED`, set outcome to `BLOCKED`, and update the state snapshot.

Do not approve or execute the phase automatically.
```

## Approve Phase

```text
Use the `asatiza-docs-and-phases` skill.

APPROVE PHASE:

[PHASE_ID]

Review the complete phase.

Do not modify production code.

Verify that all readiness checks are complete.

Confirm that required APIs, models, designs, permissions, dependencies, expected files, proposed new files, proposed new classes, risks, tests, and rollback plan are clear.

When anything remains unclear, keep status `PLANNED`, set step to `ANALYSIS` or `APPROVAL`, and set approval to `PENDING`.

When everything is ready and the developer approval is explicit:

- Set the status to `APPROVED`
- Set the step to `APPROVAL`
- Set approval to `APPROVED`
- Set outcome to `NONE`
- Record the approval
- Keep it under `docs/phases/items/`
- Update `docs/phases/PHASE_INDEX.md` and `docs/phases/state/PHASE_STATE.md`
- Report that it is ready for execution

Do not execute it.
```

## Execute Phase

```text
Use the `asatiza-docs-and-phases` skill.

EXECUTE PHASE:

[PHASE_ID]

Execute only when the phase status is `APPROVED`.

Confirm there is no other `ACTIVE` phase unless explicitly approved.

Keep the approved phase under `docs/phases/items/`.

Set status to `ACTIVE` and step to `EXECUTION`.

Work only within the approved phase.

Do not perform out-of-scope work.

Do not automatically refactor.

Do not create an unapproved file or class.

Do not change an unapproved API, dependency, architecture, model, shared component, Android configuration, or iOS configuration.

Implement the smallest complete and safe change.

When any required information becomes unclear, stop, keep status `ACTIVE`, set step to `ANALYSIS`, and record the missing information.

When an unplanned new file, class, API change, dependency, or architectural change becomes necessary, stop, keep status `ACTIVE`, set step to `APPROVAL`, and set approval to `PENDING`.

After implementation:

- Update the implementation log
- Report files modified, files created, files deleted, and a short description of each changed file
- Run Git commands only for a clear purpose; `git diff --check` is not mandatory
- Format only relevant changed Dart files when needed
- Run lightweight scoped analysis, relevant targeted tests, or repository-owned verification scripts that fit the changed files
- Use broad `flutter analyze`, full `flutter test`, build commands, or repository-wide checks only when scope/risk justifies them
- Do not launch the app or run build/flavor commands unless the developer explicitly requested that command for the phase
- Fix newly introduced in-scope issues
- Record pre-existing unrelated issues separately
- Keep status `ACTIVE` and set step to `MANUAL_TEST`
- Update `docs/phases/PHASE_INDEX.md` and `docs/phases/state/PHASE_STATE.md`
- Do not close the phase before developer manual-test confirmation
```

## Close Phase

```text
Use the `asatiza-docs-and-phases` skill.

CLOSE PHASE:

[PHASE_ID]

Developer manual-test results:

[PASTE RESULTS]

Close the phase when required manual tests passed and the developer explicitly requests closure, or when the developer gives an unambiguous successful manual-test confirmation for the current phase.

Treat a clear developer report that manual tests passed and the phase is working as manual-test confirmation.

Do not rerun expensive technical checks during closure when Execute evidence is still valid and no relevant implementation file changed afterward.

Record:

- Manual-test confirmation
- Tested platforms
- Tested devices
- Failed and retested cases
- Final changed files
- Execute technical check results
- Reused technical evidence
- Known limitations
- Follow-up phases
- Rollback guidance

Set status to `CLOSED`.

Set step to `CLOSURE`.

Set outcome to `COMPLETED`.

Add the completion date.

Keep the phase under `docs/phases/items/`.

Update `docs/phases/PHASE_INDEX.md` and `docs/phases/state/PHASE_STATE.md`.

If the developer explicitly approves a local commit, stage only approved phase files and required phase documentation, review the staged diff, commit with the phase ID in the message, and do not push.

When testing failed:

- Do not close the phase
- Keep status `ACTIVE`
- Set step to `MANUAL_TEST`
- Keep it under `docs/phases/items/`
- Record the failed test
- Prepare only an in-scope correction
```

## Create Planned Phase While Another Is Active

```text
Use the `asatiza-docs-and-phases` skill.

CREATE PLANNED PHASE WHILE ANOTHER PHASE IS ACTIVE:

[TASK REQUIREMENT]

Do not modify production code.

Create and analyze the new phase under `docs/phases/items/`.

Do not set it to an active status.

Do not execute it.

Report the currently active phase and any dependency between the phases.
```

## Pause Active Phase

```text
Use the `asatiza-docs-and-phases` skill.

PAUSE ACTIVE PHASE:

[PHASE_ID]

Do not modify production code. Verify that the phase is currently `ACTIVE` and record a temporary pause requested by the developer.

Keep the current status, current step, approval, and outcome unchanged. Record the pause date, reason, current handoff point, pending operation, and exact resume prompt in the phase file, `docs/phases/PHASE_INDEX.md`, and `docs/phases/state/PHASE_STATE.md`.

Do not set status to `CLOSED`, outcome to `BLOCKED` or `CANCELLED`, and do not execute or close the phase.
```

## Resume Paused Active Phase

```text
Use the `asatiza-docs-and-phases` skill.

RESUME PAUSED ACTIVE PHASE:

[PHASE_ID]

Do not modify production code. Review the recorded pause handoff, phase file, index and state. Resume only when the phase is still `ACTIVE` and there is no conflicting active phase. Preserve the current step, approval, and outcome. Record the resume date, keep the pause history, and report the next allowed operation. Do not execute or close automatically.
```

## Init Or Update Docs

```text
Use the `asatiza-docs-and-phases` skill.

UPDATE DOCS:

Follow `references/documentation-policy.md`. Re-audit the repository, update only stale, missing or wrong docs, promote DECIDED to VERIFIED only when seen in code, and do not change production code, tests, packages, native config, migrations or CI. Report docs changed, gaps, UNVERIFIED items and commands run.
```
