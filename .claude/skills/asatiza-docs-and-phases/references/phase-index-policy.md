# Phase Index Policy

Maintain `docs/phases/PHASE_INDEX.md`.
Maintain `docs/phases/state/PHASE_STATE.md` manually for approvals, handoffs, manual-test evidence, interruptions, and operational notes. Phase documents remain the authoritative history.

Every row must include:

- Phase ID
- Phase title
- Module
- Priority
- Risk
- Dependency phases
- Current status
- Current step
- Approval
- Outcome
- Phase file path
- Created date
- Started date
- Completed date

Update the index and manual state record after creating, approving, blocking, cancelling, executing, or completing a phase.

Phases with dependencies must not execute before dependency phases are `CLOSED` with outcome `COMPLETED`.

Use `scripts/update_phase_index.sh` when a mechanical rebuild is sufficient. It atomically rebuilds only `PHASE_INDEX.md`; update `PHASE_STATE.md` directly during the phase operation. Manually review both files for correctness.
