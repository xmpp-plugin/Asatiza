# Approve Phase

Use Approve Phase for requests like `APPROVE PHASE: PHASE_ID`.

Do not modify production source code.

## Workflow

1. Read `CLAUDE.md`, `docs/PHASE_WORKFLOW.md`, `docs/CHANGE_APPROVAL_RULES.md`, and the complete phase file.
2. Confirm the phase is under `docs/phases/items/`.
3. Confirm status is `PLANNED` or `APPROVED`.
4. Verify every required readiness checklist item is complete.
5. Verify requirements, APIs, models, designs, permissions, dependencies, expected files, proposed new files/classes, risks, tests, rollback, and phase dependencies are clear.
6. Verify developer approval is explicit.
7. If anything remains unclear, keep status `PLANNED`, set step to `ANALYSIS` or `APPROVAL`, set approval to `PENDING`, and record the missing item.
8. If external dependency is unavailable, set status to `CLOSED`, outcome to `BLOCKED`, and update the state snapshot.
9. If ready, set status to `APPROVED`, set step to `APPROVAL`, set approval to `APPROVED`, set outcome to `NONE`, record approval details, update `docs/phases/PHASE_INDEX.md` and `docs/phases/state/PHASE_STATE.md`, and stop.

Do not execute the phase.

## Response

Report phase ID, status, current step, approval, outcome, readiness result, missing checklist items if any, approval evidence, approved new files/classes, dependencies, blockers, index/state update, and next allowed operation.
