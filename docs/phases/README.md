# Phase Workflow Directory

Use this directory with `asatiza-docs-and-phases` (`.claude/skills/asatiza-docs-and-phases/`).

## Directories

- `items/`: all phase documents for every status.
- `state/`: active/closed state snapshot, interruption notes, closure notes, optional commit approval notes, and handoff notes.
- `templates/`: canonical phase templates.

## Status Model

Status is stored inside each phase document, `PHASE_INDEX.md`, and `state/PHASE_STATE.md`. Do not move phase files between status folders.

Allowed statuses: `PLANNED`, `APPROVED`, `ACTIVE`, `CLOSED`.

Detailed progress is stored in `Current step`, `Approval`, and `Outcome`.

## Rules

- Create a planned phase only when the developer explicitly asks to create/start a phase or the task is clearly phase-based. Ordinary bug fixes, small improvements, and maintenance tasks are normal scoped changes and must not create phase files or increment phase numbering automatically.
- Do not execute a phase until it is `APPROVED` and all required readiness checks are complete.
- Set exactly one approved phase to `ACTIVE` for execution unless the developer explicitly approves a second active phase.
- Keep related minor fixes inside the active phase. Do not fix unrelated out-of-scope findings during an active phase.
- Do not mark manual testing passed without developer-provided results.
- Do not set outcome `COMPLETED` before explicit developer manual-test confirmation.
- Update `PHASE_INDEX.md` and `state/PHASE_STATE.md` after creating, approving, executing, blocking, cancelling, or completing a phase.
