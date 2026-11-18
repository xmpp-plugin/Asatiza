# Execute Phase

Use Execute Phase for requests like `EXECUTE PHASE: PHASE_ID`.

Execute only phases under `docs/phases/items/` with status `APPROVED`, approval `APPROVED`, and outcome `NONE`.

## Workflow

1. Read `CLAUDE.md`.
2. Read `docs/PHASE_WORKFLOW.md`, `docs/CHANGE_APPROVAL_RULES.md`, `docs/phases/README.md`, `references/phase-readiness.md`, `references/one-active-phase-policy.md`, and the complete approved phase document.
3. Confirm no other phase has status `ACTIVE` unless the developer explicitly approved the additional active phase.
4. Run or perform the readiness checks from `scripts/validate_phase_readiness.sh <phase-file>`.
5. Confirm scope, non-scope, dependencies, expected files, files that must not change, proposed new files/classes, API/model/platform/dependency changes, tests, rollback, and approval.
6. Reinspect all relevant files before editing.
7. Protect existing work before editing: inspect current branch or Git status only when needed to establish a baseline, detect pre-existing unrelated changes, or confirm the file list is not already known.
8. Set status to `ACTIVE` and step to `EXECUTION`.
9. Update `docs/phases/PHASE_INDEX.md` and `docs/phases/state/PHASE_STATE.md`.
10. Implement the smallest complete, safe, and maintainable change.
11. Preserve architecture, state management, repositories, API style, model style, widgets, theme, assets, and platform patterns.
12. Avoid unrelated cleanup, dependency changes, automatic refactoring, broad rewrites, unapproved files, and unapproved classes.
13. Review the changed code against the SOLID checklist in `references/architecture-review.md`; fix in-scope violations, record others as findings. Review changed-file evidence after implementation. Reuse the most recent `git status` or `git diff --name-status` result when no files changed since it was recorded; rerun only when the file list may be stale.
14. Record a file-by-file change log in the phase document:
    - File path
    - Change type
    - Whether the file was approved
    - What changed
    - Why it changed
    - Existing behavior preserved
    - Possible side effects
    - Commands that checked this file
15. Run only technical checks that provide real value for the changed code:
    - Git commands only when needed to protect existing work, identify an unknown changed-file set, investigate suspicious/out-of-scope changes, check merge/conflict issues, or prepare an explicitly approved commit
    - `git diff --check` only when patch/whitespace integrity is relevant, for larger changes, merge work, commit preparation, or a justified concern
    - `dart format <changed-dart-files>` only when formatting is needed; avoid repeatedly formatting unchanged files
    - lightweight scoped analysis, source assertions, relevant targeted tests, or repository-owned checks that fit the changed files
    - broad `flutter analyze`, full `flutter test`, build commands, or repository-wide checks only when scope/risk justifies them
    - no app launch or build/flavor command unless the developer explicitly requested it for this phase
16. Fix newly introduced issues that are inside the approved phase scope.
17. Record pre-existing unrelated issues separately and do not fix them.
18. If a newly introduced issue requires unapproved files, classes, APIs, dependencies, native/platform changes, or architecture changes, stop, keep status `ACTIVE`, set step to `APPROVAL`, and set approval to `PENDING`.
19. If required project checks cannot run, record the exact command, result, and environmental reason.
20. Update implementation log, keep status `ACTIVE`, and set step to `MANUAL_TEST`.
21. Update `docs/phases/PHASE_INDEX.md`.

## Stop Conditions

Stop implementation when execution reveals required architecture change, API contract change, dependency change, database migration, native platform change not already approved, high-risk shared-code change, unplanned new file/class, mismatch with phase analysis, unclear requirement, unavailable external dependency, or risk of breaking a completed business flow.

Keep status `ACTIVE` and set step `ANALYSIS` when developer information is needed. Keep status `ACTIVE`, set step `APPROVAL`, and set approval `PENDING` when approval is needed. Set status `CLOSED` and outcome `BLOCKED` when an external dependency prevents progress, then update the state snapshot.

## Response

Report phase ID, status, current step, approval, outcome, implementation summary, files modified, files created, files deleted, short per-file change descriptions, file-by-file change log, compact technical check results, newly introduced issues fixed, pre-existing issues not fixed, existing components reused, approved new components, API/model/platform/dependency changes, out-of-scope findings, active phase state, index/state update, and that the phase is ready for developer manual testing. Do not close the phase before developer manual-test confirmation.
