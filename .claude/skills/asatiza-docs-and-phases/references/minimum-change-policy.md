# Minimum Complete Change Policy

Default to the smallest complete and safe change.

Do:

- Change only what the approved phase requires.
- Preserve working flows.
- Reuse existing structures and helpers.
- Implement all handling required by the approved scenario.
- Include relevant error, loading, success, failure, lifecycle, cleanup, platform, and test behavior.

Do not:

- Perform unrelated cleanup.
- Rewrite working features.
- Move files or rename public classes/methods without approval.
- Add a new architecture layer when an existing layer can handle the task.
- Add speculative future functionality.
- Add broad abstractions for a small issue. (Boundary interfaces for repositories and platform services are required by the SOLID rules and are not speculative; interfaces for single-implementation classes inside a feature are.)
- Hide issues with incomplete one-line patches.

The policy does not mean fewest lines at any cost. Correctness, lifecycle behavior, null safety, API errors, cleanup, platform differences, and tests remain required when they belong to the approved scenario.
