# Create Phase

Use Create Phase for requests like `CREATE PHASE: [task]`.

Perform read-only analysis. Do not modify production source code.

## Workflow

1. Read `CLAUDE.md`.
2. Read relevant project docs, especially `docs/PROJECT_OVERVIEW.md`, `docs/ARCHITECTURE.md`, `docs/DIRECTORY_STRUCTURE.md`, `docs/NAMING_CONVENTIONS.md`, `docs/CHANGE_APPROVAL_RULES.md`, `docs/PHASE_WORKFLOW.md`, and `docs/phases/README.md`.
3. Inspect `docs/phases/PHASE_INDEX.md` and `docs/phases/state/PHASE_STATE.md`.
4. Inspect repository structure and relevant implementation files.
5. Trace the affected flow end-to-end through UI, state, repository, API/model, storage/cache, navigation, permissions, lifecycle, and platform integrations.
6. Search for reusable widgets, dialogs, loaders, validators, themes, assets, blocs/cubits, repository interfaces, Supabase repositories, models, Edge Functions, SQL functions, helpers, and native code.
7. Identify missing information and external blockers.
8. Identify proposed new files/classes and whether each requires approval. Design them against the SOLID checklist in `references/architecture-review.md`: name the logic classes, repository/service interfaces (with method contracts) and constructor dependencies each new class needs.
9. Determine risk, dependencies, and approval requirement.
10. Create a phase document under `docs/phases/items/`.
11. Set status to `PLANNED`, step to `ANALYSIS` or `APPROVAL`, approval to `PENDING` or `NOT_REQUIRED`, and outcome to `NONE`. If an external blocker prevents progress, set status to `CLOSED` and outcome to `BLOCKED`.
12. Update `docs/phases/PHASE_INDEX.md` and `docs/phases/state/PHASE_STATE.md`.

Use `scripts/create_phase.sh <MODULE> <ACTION> "<short description>"` to create a skeleton, then fill it from verified repository evidence.

## Required Content

Use `docs/phases/templates/PHASE_TEMPLATE.md`. Complete identity, requirement, analysis, scope, readiness checklist, implementation, manual testing, and closure sections. Write `UNVERIFIED — developer confirmation required` for information that cannot be confirmed from repo evidence.

## Response

Report phase ID, phase path, status, current step, approval, outcome, active phase conflicts, current behavior, root cause or gap, proposed solution, reusable components, proposed new files/classes, expected files, risk level, blocking information, approval requirement, test plan, and next allowed operation. Do not implement code.
