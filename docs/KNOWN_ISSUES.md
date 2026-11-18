# Known Issues And Risks

## Verified From Repository (audit 2026-11-18)

- The folder `D:\GitHub\asatiza` is not a Git repository (no `.git`). Git-based protections and `collect_change_log.sh` cannot show changes until `git init` is run.
- `lib/main.dart` and `test/widget_test.dart` are unmodified `flutter create` starter code.
- Android `applicationId`/namespace is the placeholder `com.example.asatiza`; it must be replaced before any store upload (cannot change after publishing).
- `pubspec.yaml` description is "A new Flutter project."; `README.md` is the Flutter starter README.
- No Supabase, Firebase, flutter_bloc, Dio or go_router dependencies yet.

## Plan-vs-Code Gaps

Everything in `docs/product/VERSION_1_PLAN.md` is not yet implemented. Phases are created one at a time by the developer in `docs/phases/items/`.

## Owner Decisions That Differ From The PDF Plan

- 2026-11-18: State management is BLoC (`flutter_bloc`, Cubit by default, Bloc for event-heavy flows, `RepositoryProvider` with constructor injection) instead of `flutter_riverpod` (plan section 11). Dio is added for Edge Function calls and the later Python API; `supabase_flutter` stays for Auth, database, Storage and Realtime.
- 2026-11-18: SOLID rules adopted (`docs/CLASS_AND_COMPONENT_RULES.md`). Repositories differ from plan section 11: profile access is split into `ProfileRepository`, `DiscoverRepository` and `MediaRepository`, plus `SafetyRepository`; business rules live in pure-Dart `logic/` classes; platform plugins sit behind `lib/core/services/` interfaces.
- `docs/product/` is left unchanged.

## Open Decisions (settle during the matching phase)

| # | Decision needed | Why | Decide in |
|---|---|---|---|
| 1 | How an admin bans a user: add `profiles.is_banned`, use `profiles.is_visible`, or disable the user in Supabase Auth | Plan section 15 says "ban user" but the schema has no ban column; RLS text mentions `is_hidden` for profiles, which exists only on `posts` | Safety / admin phase |
| 2 | Android-only launch, or Android + iOS together in v1.0 | Plan says both platforms; timeline covers only Play Store, Apple fee "only when iOS launches" | Foundation phase |
| 3 | Prepare localization (`intl`/ARB files, RTL support) from the start | English at launch; Urdu and Arabic (RTL) in v1.1 | Foundation phase |
| 4 | Parent-for-child flow: parent signs up as Student, ticks 18+, sets learner age group "child"? | Plan allows a parent to open a Student account for a child; separate parent/child accounts are v2.0 | Auth / profile phase |

## Architecture Risks

- Supabase free-plan project pauses after 7 days idle (keep-alive ping required).
- Built-in Supabase email is limited to 2/hour; Brevo SMTP must be connected before real users.
- RLS mistakes can expose messages, certificates or hidden profiles — every RLS change needs the 4-account test.
- Realtime subscriptions leaking if not disposed.
- FCM token lifecycle across sign-out, account deletion and multiple devices.
- Google Play closed test requires 12+ testers for 14 continuous days for new personal developer accounts.

## Unverified

- Final package name / bundle ID: UNVERIFIED — developer confirmation required.
- Android-first vs Android + iOS together: UNVERIFIED — developer confirmation required.
- Phase approver and manual tester: UNVERIFIED — developer confirmation required.
- Supabase project created: UNVERIFIED — developer confirmation required.
- Firebase project created: UNVERIFIED — developer confirmation required.
- Bash runtime on Windows (Git Bash or WSL) for the skill scripts: UNVERIFIED — developer confirmation required.
- Account-deletion implementation (Edge Function vs SQL function): UNVERIFIED — developer confirmation required.
