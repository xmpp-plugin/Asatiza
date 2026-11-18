# One Active Phase Policy

Only one phase may have an active status by default.

Before execution:

1. Inspect `docs/phases/state/PHASE_STATE.md`, `docs/phases/PHASE_INDEX.md`, and phase files under `docs/phases/items/`.
2. If any phase has status `ACTIVE`, report it and do not start another phase.
3. Allow a second active phase only when the developer explicitly approves the interruption or parallel active work.
4. Record the approval and relationship in both phase files, `docs/phases/PHASE_INDEX.md`, and `docs/phases/state/PHASE_STATE.md`.

When a new task arrives during an active phase:

- Report the currently active phase when it affects the request.
- If the request is a minor fix or adjustment related to the active phase, continue inside the existing active phase and report changed files after implementation.
- If the request is unrelated, do not implement it inside the active phase. Do not create a new phase unless the developer explicitly asks for one; otherwise explain that unrelated work must wait until the current phase is completed, blocked, cancelled, or explicitly paused/interrupted.
- Allow a second active phase only when the developer explicitly approves the interruption or parallel active work.

Urgent production work may interrupt only with explicit developer approval. Record the interruption and previous phase status.
