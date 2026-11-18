# Testing Policy

Use only commands supported by the repository.

Preferred technical checks:

- Format only changed Dart files with `dart format <files>`.
- Run `flutter analyze` when appropriate.
- Run targeted `flutter test` or `flutter test <path>` when relevant.
- Run integration tests only when the phase requires them and environment support exists.
- Reuse recorded passing results when relevant implementation files have not changed since those checks ran.
- For small scoped work, prefer scoped analysis and targeted tests. Do not run both scoped and full analysis/tests without a risk-based reason.
- Record each command and actual result compactly in the phase file.
- Keep manual testing as developer-owned closure evidence.

Do not run `flutter clean`, `pod update`, `pod repo update`, `flutter pub upgrade`, or `dart fix --apply` without explicit approval.

When whole-project analysis has existing issues:

- Report the analyzer command as failed.
- Separate pre-existing issues from newly introduced issues.
- Use targeted analysis when needed.
- Never claim full success if the command did not pass.

Manual testing belongs to the developer. Claude should not automatically generate manual-test checklists. Provide manual test cases only when the developer asks, a risky/non-obvious scenario needs highlighting, or project requirements explicitly require documented cases. Claude cannot mark manual testing passed without explicit or unambiguous developer confirmation.

## Asatiza Additions

- Supabase checks (`supabase db lint`, `supabase migration list`, local `supabase test db`) run only against a local project when the Supabase CLI is configured; never against the linked remote project without explicit approval.
- RLS changes need evidence with the four standard test accounts (2 teachers, 2 students; record labels only, never passwords) covering own-row, other-row, blocked-user and signed-out access.
- Run `dart run build_runner build --delete-conflicting-outputs` only if the repo uses code generation and the phase allows it.
