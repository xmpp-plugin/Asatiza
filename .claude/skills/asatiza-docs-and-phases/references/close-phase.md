# Close Phase

Use Close Phase for requests like `CLOSE PHASE: PHASE_ID`.

Close only when the phase is under `docs/phases/items/` with status `ACTIVE`, step `MANUAL_TEST` or `CLOSURE`, required scenarios passed, no critical unresolved issue remains, and the developer provides explicit manual-test results or an unambiguous successful manual-test confirmation for the current phase.

## Successful Closure

1. Record developer test confirmation.
2. Record tested devices/platforms when provided.
3. Record failed and retested cases when provided.
4. Keep status `ACTIVE` and set step to `CLOSURE`.
5. Reconfirm final changed files using the latest recorded changed-file evidence; rerun Git status/diff only when that evidence may be stale.
6. Reconfirm no unapproved dependency or architecture changes exist.
7. Record Execute technical checks and results. Reuse still-valid technical evidence when no relevant implementation file changed after Execute.
8. Record known limitations and follow-up phases separately.
9. Keep status `ACTIVE` and step `CLOSURE`.
10. Treat a clear successful manual-test confirmation such as "tested and working", "manual testing passed", or "everything is working" as the closure request for the current phase unless the developer asks to keep it open.
11. Set status to `CLOSED` and outcome to `COMPLETED`.
12. Add completion date.
13. Keep the phase file under `docs/phases/items/`.
14. Update `docs/phases/PHASE_INDEX.md` and `docs/phases/state/PHASE_STATE.md`.
15. If the developer explicitly requested or approved a local commit, stage only approved phase files and required phase documentation, review the staged diff, commit with the phase ID in the message, and do not push.

## Failed Manual Testing

When manual testing fails, do not close. Keep status `ACTIVE`, set step to `MANUAL_TEST`, keep outcome `NONE`, record failed case, actual behavior, expected behavior, and whether the issue is in scope. Apply only an approved in-scope correction, rerun only affected technical checks, and return to manual testing.

When the developer clearly reports that manual testing passed for the current phase, treat that message as developer manual-test confirmation and closure intent unless they ask to keep the phase open. Do not ask the developer to run a separate close command. If Execute technical evidence is still valid and no critical unresolved issue remains, close through the existing workflow without rerunning format, analyze, tests, builds, or Git checks. If relevant implementation code changed after Execute or manual testing, rerun only the affected checks before closure.

## Blocked Closure

Set status to `CLOSED`, set outcome to `BLOCKED`, and update the state snapshot when closure depends on missing backend support, API documentation, credentials, design, platform certificates, dependency decisions, business decisions, or external testing access.

## Response

Report phase ID, final status, current step, approval, outcome, completion date, implementation summary, final changed files, Execute technical checks/results, reused technical evidence, developer manual-test confirmation, tested platforms/devices, known limitations, follow-up work, rollback guidance, phase path, state/index update, and commit result when an approved commit was made.
