# Phase Readiness

A phase must not execute unless every required detail is clear and verified.

Before execution, verify:

- Business requirement is clear.
- Expected behavior is clear.
- Current behavior is understood.
- Scope and non-scope are defined.
- Root cause or implementation gap is understood.
- Relevant code flow is traced.
- Required API exists, including endpoint, method, auth, request fields, response fields, and error behavior.
- Required models exist or are approved.
- UI design and assets are available when required.
- Platform behavior and permissions are understood.
- Required dependencies already exist or are approved.
- Required native configuration is known.
- Expected files are identified.
- Proposed new files/classes are approved.
- Test conditions are defined.
- Rollback plan exists.
- Dependency phases are completed.
- Approval status is valid.

`scripts/validate_phase_readiness.sh` is a guard, not a substitute for this review. It must verify the anchored phase fields, checked readiness items, dependency outcomes, and absence of another active phase. A passing script result does not permit execution when repository evidence contradicts the phase.

Keep status `PLANNED`, step `ANALYSIS`, and approval `PENDING` when information is expected from the developer.

Use status `CLOSED` with outcome `BLOCKED` when execution depends on unavailable external dependency such as missing backend support, API documentation, credentials, design, platform certificate, package decision, native capability, test device, business rule, or unfinished dependency phase.

Do not invent temporary APIs, mock response fields, business rules, models, routes, or platform behavior unless the phase explicitly requests a mock implementation.
