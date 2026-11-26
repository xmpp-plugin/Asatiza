# Known Issues And Risks

## Verified From Repository (audit 2026-11-18)

- 2026-11-24 (`PHASE_005`): one certificate per teacher is enforced in the app only (a direct Storage API call could add more PDFs to the user's own folder; still PDF, 3 MB). Uploads happen when picked: a file uploaded while the app is killed before Save stays as an orphan; failed best-effort deletions too (clean in the dashboard). Account deletion removes files first; if that fails the account stays and the error shows. Avatars are public by URL (plan). `image_picker` lost-data recovery (Android killing the app during the camera) is not handled: the user picks again. Picker permission denial shows "Upload failed". Certificates can be opened only by their owner (admin view comes with the admin phase); not from My profile. Post and chat photos are still sample attachments. Remote migration and policies: UNVERIFIED until the developer applies them.
- 2026-11-24 (`PHASE_004` fix): a fresh clone must create `env/supabase.json` from `env/supabase.example.json` before building (declared asset). The app needs that file and a connection for every run (no offline full-mock mode). Build the remaining features in dependency order (discover → safety → connections → chat → feed → notifications): a real feature talking to a still-mock one only knows the sample people. Release only when every repository is real.
- 2026-11-23 (`PHASE_004`): backend mode makes only accounts and profiles real; feed, teachers / students, connections, chat, notifications and blocking stay mock and know only the seeded people (connect, chat, post or block may fail or show empty for a real user until their phases). Network / unexpected errors are shown on the auth, change-password and My profile screens; other screens (setup, edit profile, posts, connections) still only re-enable the button. After a verified reset code the user is signed in on Supabase; leaving before saving a new password keeps that session for the next launch. Photos and certificates were sample paths until `PHASE_005`. Migrations applied to the remote project: UNVERIFIED.
- 2026-11-23: both mock login emails (`MockAccounts`) are the same address by developer decision — logging in always opens Qari Ahmed (teacher); the student account Ayesha cannot be reached through the log-in screen.
- 2026-11-23 (`PHASE_003`): every artboard is built on mock data. Still mock-only: changes reset on restart; "Change photo", chat photos and certificate uploads attach samples (no picker); chat links copy instead of opening (no URL-launcher package); "Share profile" copies text; changing the password does not store it; deleting an account clears it from memory until restart. Fees are US dollars per month (owner decision; the canvas shows PKR). Content / Privacy / Terms texts came from the design tool — owner / legal review needed before launch. Seed has no blocked users (the canvas shows three). Design gaps kept: 18 px verified badge on large avatars (design 26 px), student initials use the avatar tint (design grey).

- 2026-11-19 (`PHASE_002`): the app runs on mock data only — every launch starts signed out and all changes reset on restart; any valid email + 8-character password signs in; any 6 digits pass the code step. Teachers, Chats and Alerts tabs are still placeholders (part 2). Home avatar opens profile setup and Home search opens the Teachers tab until My profile and search results exist (part 2). "Photo", "Add a profile photo" and "Upload certificates" attach sample files (no camera/gallery).

- Updated 2026-11-19 (`PHASE_001`): Git repository on branch `main`. App foundation exists (theme, router, shell, placeholder screens). App ID `com.asatiza.app` on Android and iOS — permanent after the first store upload.
- `README.md` is still the Flutter starter README.
- No Supabase, Firebase, flutter_bloc or Dio dependencies yet (added by the phases that use them).
- iOS: developer reports `PHASE_001` tested on iOS (2026-11-19).
- `assets/logos/` (app icons, logos) exists but is not wired into the Android/iOS launcher icons yet.

## Plan-vs-Code Gaps

- ~~2026-11-25 (`PHASE_006`, decision 1A, temporary): lists did not filter blocked users~~ — closed 2026-11-26 by `PHASE_007` (real blocks, RLS, list filter); manual test pending.
- 2026-11-25 (`PHASE_006`, out-of-scope): `profiles` has no `is_hidden` column (plan section 12, admin hide); profiles RLS lets any signed-in user read any profile by id. Revisit with moderation.

Everything in `docs/product/VERSION_1_PLAN.md` is not yet implemented. Phases are created one at a time by the developer in `docs/phases/items/`.

## Owner Decisions That Differ From The PDF Plan

- 2026-11-18: State management is BLoC (`flutter_bloc`, Cubit by default, Bloc for event-heavy flows, `RepositoryProvider` with constructor injection) instead of `flutter_riverpod` (plan section 11). Dio is added for Edge Function calls and the later Python API; `supabase_flutter` stays for Auth, database, Storage and Realtime.
- 2026-11-18: SOLID rules adopted (`docs/CLASS_AND_COMPONENT_RULES.md`). Repositories differ from plan section 11: profile access is split into `ProfileRepository`, `DiscoverRepository` and `MediaRepository`, plus `SafetyRepository`; business rules live in pure-Dart `logic/` classes; platform plugins sit behind `lib/core/services/` interfaces.
- `docs/product/` is left unchanged.

- 2026-11-26 (`PHASE_008`, temporary): "Message" on a real connection shows "Chat is coming soon" (chat still mock); the Notifications tab's sample request items cannot act on real requests (Notifications phase).

### Plan update 2026-11-26 — code not yet changed

Owner updated `docs/product/VERSION_1_PLAN.md` and `FULL_PRODUCT_PLAN.md` (roles, required setup, status, visibility, connections, Verified badge). The code still follows the old rules until approved phases change it:

| # | New plan rule | Current code (VERIFIED) | Suggested place |
|---|---|---|---|
| A | Teachers **and students** listed when **active** (required fields filled); no admin approval; "Looking" is a label only; random order stable per user per day; no sort menu | `is_visible` needs `is_verified` and ≥ 80 % (teacher) / looking and ≥ 60 % (student); sort menu | Implemented in PHASE_006 (2026-11-26), manual test pending |
| B | `profiles.status` (incomplete / active) from required fields; percentage removed from app and database | `completion_pct` + `is_visible`; `ProfileStrengthCalculator`; Home / My profile show % | Implemented in PHASE_006 (2026-11-26), manual test pending |
| C | Profile setup has no Skip; unfinished setup resumes at log-in; Edit profile cannot empty required fields | "Skip for now" on setup steps; router sends users to Home | Implemented in PHASE_006 (2026-11-26), manual test pending |
| D | Learner type wording: "Who will be learning? Myself / My child / My teenager"; filter "Learner type" | Labels say age group (child / teen / adult); values unchanged | Small copy step (no migration) |
| E | Connect needs both active; 10 requests per rolling 24 h; checked in a database function | `DiscoverVisibilityRules.canSendRequest` (≥ 60 %), mock connections | Implemented in PHASE_008 (2026-11-26), manual test pending |
| F | No status card on Home / My profile; Connect-button messages | Percentage strength card | Card removal implemented in PHASE_006 (2026-11-26); Connect-button messages: Connections phase |
| G | Verified badge only from certificate review; "Certificate under review" to the teacher | `is_verified` set by admin; no "under review" state | Profile-status phase |

## Open Decisions (settle during the matching phase)

| # | Decision needed | Why | Decide in |
|---|---|---|---|
| 1 | How an admin bans a user: add `profiles.is_banned`, use `profiles.is_visible`, or disable the user in Supabase Auth | Plan section 15 says "ban user" but the schema has no ban column; RLS text mentions `is_hidden` for profiles, which exists only on `posts` | Safety / admin phase |
| 2 | ~~Android-only or Android + iOS~~ — DECIDED 2026-11-18: Android **and** iOS in v1.0 | — | Closed in `PHASE_001` |
| 3 | ~~Localization from the start~~ — DECIDED 2026-11-18: English-only `gen-l10n` now, RTL-ready layout | — | Closed in `PHASE_001` |
| 4 | ~~Parent-for-child flow~~ — DECIDED 2026-11-26: adults-only accounts in every version; a parent uses their own Student account; learner type is information only | — | Closed (plan update) |

## Architecture Risks

- Supabase free-plan project pauses after 7 days idle (keep-alive ping required).
- Built-in Supabase email is limited to 2/hour; Brevo SMTP must be connected before real users.
- RLS mistakes can expose messages, certificates or hidden profiles — every RLS change needs the 4-account test.
- Realtime subscriptions leaking if not disposed.
- FCM token lifecycle across sign-out, account deletion and multiple devices.
- Google Play closed test requires 12+ testers for 14 continuous days for new personal developer accounts.

## Unverified

- Final package name / bundle ID: DECIDED `com.asatiza.app` (2026-11-18).
- Platforms: DECIDED Android + iOS (2026-11-18).
- Phase approver and manual tester: UNVERIFIED — developer confirmation required.
- Supabase project created: UNVERIFIED — developer confirmation required.
- Firebase project created: UNVERIFIED — developer confirmation required.
- Bash runtime on Windows for the skill scripts: VERIFIED — Git Bash runs them (2026-11-19).
- Account-deletion implementation (Edge Function vs SQL function): UNVERIFIED — developer confirmation required.
