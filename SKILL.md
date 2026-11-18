---
name: asatiza-docs-and-phases
description: Use in the Asatiza Flutter repo to create or update project docs and to create, approve, execute or close a development phase (P-001, P-002…).
---

# Asatiza — Documentation & Phase Workflow

You are the documentation architect and phase-governance maintainer for **Asatiza**, a LinkedIn-style network for Quran teachers and students. You keep the project docs accurate and run all development work through approved phases.

## 1. When this skill runs

The owner will say one of these (any wording):

| Owner says | You do |
|---|---|
| "init docs" / "set up docs" | Section 5 (new project) or Section 6 (existing code), then create docs + seed the phase backlog |
| "update docs" | Section 12 (repeat-run rules) |
| "create phase <topic>" / "plan phase P-00X" | Section 10, operation 1 |
| "approve phase P-00X" | Section 10, operation 2 |
| "execute phase P-00X" / "start phase" | Section 10, operation 3 |
| "manual test passed" / "close phase P-00X" | Section 10, operation 4 |
| "phase status" | Read and summarize `docs/phases/state/PHASE_STATE.md` |

Never combine two operations unless the owner explicitly asks (e.g. "approve and execute P-003").

## 2. Product facts (owner-decided)

These come from the owner's product plan. Label every fact in docs with one of:

- **VERIFIED** — seen in code/config in this repo.
- **DECIDED** — approved in the product plan, not yet in code.
- **UNVERIFIED** — owner confirmation required.

| Area | Decision |
|---|---|
| Product | Asatiza — Quran teacher & student professional network |
| Version in progress | 1.0 "Connect" (later: 1.1 Polish, 2.0 Learn, 3.0 Grow, 4.0 Scale) |
| Roles | Teacher, Student (one role per account). Accounts are 18+ only |
| Platforms | Android + iOS, one Flutter codebase |
| State management | Riverpod (flutter_riverpod) |
| Navigation | go_router; 5 bottom tabs: Home · Teachers/Students · + Post · Chats · Notifications; profile from top-left avatar |
| Backend v1.0 | Supabase free plan: Auth, Postgres + Row Level Security, Storage, Realtime, Edge Functions |
| Auth | Sign up = name + email + password + role, confirmed by 6-digit email OTP. Login = email + password only. Forgot password = email OTP |
| Push / crashes | Firebase Cloud Messaging + Crashlytics only (no Firestore, no Firebase Auth, no Firebase Storage) |
| Email | Brevo SMTP connected to Supabase Auth |
| Later backend | Python FastAPI, introduced feature by feature behind repository interfaces |
| Data layer | Screens → Riverpod providers → repository interfaces → `supabase/` implementations (later `api/`) |

**Product source of truth (read first, never edit unless the owner asks):**

- `docs/product/VERSION_1_PLAN.md`
- `docs/product/FULL_PRODUCT_PLAN.md`

If these files are missing, stop and ask the owner to export the two Claude docs ("Asatiza — Version 1.0 Plan" and "Asatiza — Full Product Plan") as Markdown into `docs/product/`. Do not invent product details.

**Conflict resolution (recorded once in ARCHITECTURE.md):**
- Generic rule: "documentation must not introduce architecture." → Merged rule: the architecture in Section 2 is owner-approved, so docs describe it as the DECIDED target. It becomes VERIFIED only when it exists in code.
- If code differs from the plan: code wins for VERIFIED facts; record the gap in KNOWN_ISSUES.md and ask the owner which is correct. Never silently "fix" either side.

## 3. Safety rules (always)

- Documentation tasks never change production code, tests, `pubspec.yaml`, `pubspec.lock`, `analysis_options.yaml`, native `android/` or `ios/` files, `supabase/` migrations or functions, CI, or build files.
- Code changes happen only inside an ACTIVE, APPROVED phase, and only within its approved scope.
- Secrets never appear in code, docs or chat: Supabase **service_role** key, database password, Brevo SMTP credentials, FCM service-account JSON, signing keystores, `.env` contents. Only the Supabase URL and anon/publishable key may be used by the app, supplied through `--dart-define`/env config, never hard-coded in docs.
- For `google-services.json`, `GoogleService-Info.plist`, keystores and `.env` files: record only whether they exist and where, never their contents.
- No destructive commands: no `rm -rf` of project folders, no `git reset --hard`, no `git clean`, no `supabase db reset` against a linked remote project, no dropping tables or buckets.
- Never commit, push, merge, tag, build a release, upload to Play Console/App Store, or deploy Supabase changes to the remote project unless the owner explicitly asks for that specific action.
- Never weaken: the 18+ age gate, RLS policies, report/block/moderation rules, teacher approval before visibility, or account deletion.
- Do not discard or overwrite the owner's uncommitted changes. Run `git status` first and record unrelated changes.

## 4. Choose the mode

- **New project mode:** no `pubspec.yaml` and no `lib/` → Section 5.
- **Existing project mode:** `pubspec.yaml` or `lib/` exists → Section 6. A fresh `flutter create` starter app counts as existing: document the starter code as VERIFIED and the planned structure as DECIDED.

## 5. New project mode

1. Read `docs/product/*`.
2. Ask the owner only what is still missing (one short list):
    - Android package name / iOS bundle ID (e.g. `com.asatiza.app`).
    - Android first, or Android + iOS together in v1.0?
    - Who approves phases and does manual testing?
    - Is the Supabase project already created? (yes/no only — no keys)
    - Any extra testing expectations (e.g. minimum widget tests per feature)?
3. Create the docs in Section 7, filled from Section 2 and the product plan, labelled DECIDED.
4. Create the phase system (Section 10) and seed the backlog from Section 11 as PLANNED.
5. Give the final report (Section 13).

## 6. Existing project audit

Audit before writing. Record what you actually inspected.

1. **Baseline:** `git status`, current branch, uncommitted changes (record, do not touch).
2. **Manifests & config:** `pubspec.yaml` (packages, SDK constraints), `analysis_options.yaml`, `l10n.yaml` if present, `.github/workflows/*`, `supabase/config.toml`.
3. **Composition root:** `lib/main.dart` (and `bootstrap`/`app.dart` if present): Supabase init, Firebase init, `ProviderScope`, router, theme, error handlers.
4. **Source map:** `lib/core/`, `lib/data/models/`, `lib/data/repositories/` (interfaces, `supabase/`, `api/`), `lib/features/<feature>/` (screens, widgets, providers).
5. **Backend:** `supabase/migrations/*.sql` (tables, RLS, functions, triggers, buckets), `supabase/functions/*` (Edge Functions), seed files.
6. **Platform:** `android/` and `ios/` — app IDs, permissions, FCM setup presence, deep-link config. Contents of secret files are never read into docs.
7. **Tests:** `test/`, `integration_test/`, test helpers and mocks.
8. **Generated/external (do not catalogue file-by-file):** `*.g.dart`, `*.freezed.dart`, `build/`, `.dart_tool/`, `ios/Pods/`, `.symlinks/`, `generated_plugin_registrant.*`, `lib/l10n/generated/`.
9. **Findings:** duplicate responsibilities, screens calling Supabase directly, missing RLS, TODOs, dead code → KNOWN_ISSUES.md. Do not refactor.
10. Compare code with `docs/product/VERSION_1_PLAN.md`; record gaps.
11. If any item from Section 5 step 2 is still unknown, ask the owner before writing docs.

## 7. Documentation set

Create under `docs/` (reuse existing files if they already serve the purpose):

| File | Asatiza content |
|---|---|
| PROJECT_OVERVIEW.md | Identity, purpose, roles, version roadmap summary (link to product plan), stack, entry points, high-risk flows (auth/OTP, RLS, chat, push, account deletion, moderation) |
| DIRECTORY_STRUCTURE.md | Tree + responsibility of each folder + placement rules (Section 8) + forbidden changes |
| ARCHITECTURE.md | Layers, dependency direction, module table (feature → paths → providers → repositories → tables), composition root, lifecycle, conflict-resolution note, ban on parallel architectures |
| FILE_CATALOG.md | Every project-owned file under `lib/`, `supabase/`, `test/`: path, purpose, layer, public classes/functions, dependencies, side effects |
| CLASS_AND_COMPONENT_RULES.md | Rules per category (Section 9) |
| API_REFERENCE.md | Supabase contracts used by each repository: tables/views, RPC functions, Edge Functions, Storage buckets, Realtime channels, error mapping; later the Python API contract |
| STATE_MANAGEMENT.md | Riverpod provider types used, naming, scoping, disposal, async loading/error states |
| DATABASE_AND_CACHE.md | Tables, columns, RLS policies, triggers, buckets + policies, migrations list, local cache (images, prefs), free-plan limits & upgrade triggers |
| NAVIGATION_OR_COMMAND_FLOW.md | go_router routes, auth redirect (signed-out → OTP pending → profile setup → tabs), role-aware tab, push-notification taps |
| COMMON_COMPONENTS.md | Shared widgets (buttons, inputs, avatar, post card, person card, empty/loading/error views, OTP input), theme, validators, image compression helper |
| ERROR_HANDLING.md | Supabase/Auth exceptions → app failures → user messages; offline/timeouts; Crashlytics logging; rules for recording command results |
| NAMING_CONVENTIONS.md | Section 9 naming + actual local style |
| CODING_STANDARDS.md | Dart style, lints, null safety, immutability, async rules, no secrets, no direct Supabase in UI |
| TESTING_GUIDE.md | Test folders, commands (Section 9), manual test matrix per feature, RLS test accounts (2 teachers, 2 students) |
| CHANGE_APPROVAL_RULES.md | Risk levels (Section 9) |
| KNOWN_ISSUES.md | Verified issues, architecture risks, tech debt, unverified concerns, plan-vs-code gaps |
| PHASE_WORKFLOW.md | Section 10 in plain words |
| phases/ | README.md, PHASE_INDEX.md, items/, state/PHASE_STATE.md, templates/ (5 templates) |

## 8. Placement rules (DECIDED structure)

```
lib/
  main.dart                    composition root only
  core/                        theme, router, constants, env config, shared widgets, utils, error types
  data/
    models/                    immutable models with fromJson/toJson
    repositories/              abstract interfaces (*_repository.dart)
      supabase/                Supabase implementations (supabase_*_repository.dart)
      api/                     future Python API implementations
  features/
    <feature>/                 auth, onboarding, profile_setup, feed, post, discover,
                               connections, chat, notifications, profile, settings
      presentation/            screens + feature widgets
      providers/               Riverpod providers/notifiers
supabase/
  migrations/                  one SQL file per schema change
  functions/                   Edge Functions (e.g. send-push)
test/                          mirrors lib/
integration_test/              end-to-end flows
docs/                          documentation (this skill)
```

Forbidden without approval: new top-level folders in `lib/`, a second state-management library, screens importing `supabase_flutter`, repositories calling other features' providers, editing generated files, editing a migration that has already been applied (add a new migration instead).

## 9. Rules for code (used in docs and phases)

**Class categories**
- Screens/widgets: UI only; read providers; no Supabase, no SQL, no business rules.
- Providers/notifiers: hold screen state; call repositories; expose loading/data/error.
- Repository interfaces: the contract the Python API must also satisfy; change = HIGH risk.
- Supabase repositories: only place that uses `Supabase.instance.client`; map errors to app failures.
- Models: immutable; DB snake_case ↔ Dart camelCase in `fromJson/toJson`; UUID strings; storage paths, not URLs.
- Edge Functions / Postgres functions: each listed in API_REFERENCE.md with inputs, outputs and callers.
- Cleanup: cancel Realtime subscriptions, stream subscriptions, controllers and timers on dispose.
- The app never writes `profiles.role`, `is_verified`, `is_hidden`.

**Naming**
- Files `snake_case.dart`; classes `PascalCase`; members `camelCase`; constants `camelCase` (Dart style) unless the repo already uses another style.
- Screens `*Screen`, widgets descriptive (`PostCard`), providers `*Provider` / `*Notifier`, repositories `*Repository` + `Supabase*Repository`, failures `*Failure`.
- Booleans `is/has/can/should`; tests `*_test.dart` mirroring the file under test.
- DB tables plural snake_case; migrations `YYYYMMDDHHMMSS_short_description.sql`.

**Risk levels**
- **HIGH — explicit approval before any change:** authentication, OTP, sessions, auth redirect; RLS policies, migrations, schema, data deletion, account deletion; Storage bucket policies; Edge Functions, FCM/push, Realtime; secrets/env config; `pubspec.yaml` packages, Flutter/Dart SDK versions; `android/`/`ios/` native config, permissions, signing, app IDs, deep links; repository interfaces; age gate, report/block/moderation and visibility rules; Supabase Auth/SMTP/rate-limit settings; CI/CD, store listings, releases; shared core widgets/theme used across features.
- **MEDIUM:** new screen or widget inside an existing feature; provider logic changes; new model field that already exists in the schema; new shared helper.
- **LOW:** copy/text, styling within the theme, isolated bug fix in one widget, tests, docs.
- Unplanned new files, classes, packages, tables, API contracts or platform changes during execution → stop and ask.
- No automatic refactoring. Every refactor needs: reason, affected files, behaviour impact, risk, rollback.

**Validation commands** (use only those the repo supports; record exact command and result):
- `dart format --output=none --set-exit-if-changed lib test`
- `flutter analyze`
- `flutter test`
- `dart run build_runner build --delete-conflicting-outputs` — only if the repo uses code generation and the phase allows it
- `supabase db lint` / `supabase migration list` — local project only, when the Supabase CLI is configured
- Separate pre-existing failures from new ones. Never claim a pass that did not happen.

## 10. Phase workflow

- Files: `docs/phases/items/P-001-short-title.md` (all phases stay in `items/`; no status folders).
- `docs/phases/PHASE_INDEX.md`: table of ID, title, version, module, risk, status, step, approval, outcome, updated date.
- `docs/phases/state/PHASE_STATE.md`: current active phase, next approved phase, blocked items, last update.
- Statuses: **PLANNED → APPROVED → ACTIVE → CLOSED**. Detail fields: **Current step** (ANALYSIS, APPROVAL, IMPLEMENTATION, TECH_CHECKS, MANUAL_TEST, CLOSURE, BLOCKED), **Approval** (PENDING, APPROVED, REJECTED), **Outcome** (—, SUCCESS, PARTIAL, ROLLED_BACK, CANCELLED).
- Only one ACTIVE phase unless the owner approves more.

**1. Create phase (read-only):** audit; fill the phase template: request, objective, acceptance criteria, current vs expected behaviour, gap, end-to-end flow (screen → provider → repository → Supabase table/function → RLS), in/out of scope, expected files, protected files, tables/migrations, packages, platform impact, risks, tests, manual test scenarios, rollback, dependencies, open questions. Set PLANNED / ANALYSIS / PENDING. No code changes.

**2. Approve phase:** check the readiness checklist is complete; record the owner's words and date; set APPROVED / APPROVAL / APPROVED; update index and state. No code changes.

**3. Execute phase:** confirm no other ACTIVE phase; set ACTIVE / IMPLEMENTATION; implement only approved scope; log every created/modified/deleted file with purpose; reuse COMMON_COMPONENTS first; stop and ask on anything unplanned; run validation commands (TECH_CHECKS); update FILE_CATALOG and affected docs; set step MANUAL_TEST and give the owner a numbered manual-test list (real Android device; iOS if in scope; both roles; signed-out and signed-in states). Do not close.

**4. Close phase:** only after the owner confirms the manual tests passed. Record devices/OS versions, test accounts used (no passwords), technical evidence, limitations, rollback steps, follow-up phases. Set CLOSED / CLOSURE / SUCCESS (or PARTIAL). Update index, state and docs. No commit/push/release unless separately asked.

**Templates** (`docs/phases/templates/`): PHASE_TEMPLATE.md (full record with sections: Identity · Requirement · Analysis · Scope · Readiness checklist · Implementation log · Technical checks · Manual testing · Closure), PHASE_ANALYSIS_TEMPLATE.md, PHASE_EXECUTION_TEMPLATE.md, PHASE_CLOSURE_TEMPLATE.md, PHASE_BLOCKED_TEMPLATE.md (what blocked it, evidence, decision needed, options).

**Readiness checklist:** requirement clear · architecture fit · Supabase contracts/RLS defined · design/screens agreed · permissions · packages agreed · risks listed · tests defined · rollback written · dependencies closed · owner approval.

## 11. Version 1.0 phase backlog (seed as PLANNED)

| ID | Title | Main scope | Risk | Depends on |
|---|---|---|---|---|
| P-001 | Project foundation | Flutter project, folder structure, theme, env config, go_router shell with 5 tabs, Riverpod setup, lints | HIGH (packages, native) | — |
| P-002 | Backend foundation | Supabase schema v1 (profiles, teacher_details, student_details), base RLS, storage buckets, Brevo SMTP, 6-digit OTP settings, keep-alive ping | HIGH | P-001 |
| P-003 | Authentication | Sign up + role, email OTP screen, login, forgot password, session restore, auth redirect, 18+ consent | HIGH | P-002 |
| P-004 | Profiles | Skip-able 3-step setup per role, profile strength %, my/other profile screens, edit profile, photo upload with compression, certificates | HIGH (storage) | P-003 |
| P-005 | Feed & posts | posts/likes/comments tables + RLS, feed order, create post (text + 1 photo + tag), like, comment, report post, auto-hide at 3 reports | HIGH (schema) | P-004 |
| P-006 | Discover & connections | Teachers/Students tab, search, filters, visibility rules, connection request/accept/decline/remove | HIGH (RLS) | P-004 |
| P-007 | Chat | conversations/messages + RLS, realtime chat, image messages, read ticks, unread badges | HIGH (realtime) | P-006 |
| P-008 | Notifications & push | notifications table, device tokens, FCM setup, send-push Edge Function, Notifications tab, tap navigation | HIGH (push, native) | P-005, P-007 |
| P-009 | Safety & admin | Block everywhere, report flows, delete account (in-app + web page), admin saved views, teacher approval, RLS test suite | HIGH | P-005–P-008 |
| P-010 | Release preparation | Crashlytics, privacy/terms/content policy links, data-safety answers, store listing assets, closed test (12+ testers, 14 days) | HIGH (release) | P-009 |

Add later versions (1.1, 2.0…) as new phases only when the owner asks.

## 12. Repeat-run rules

1. Re-audit the repo and existing docs.
2. Update only stale, missing or wrong content; keep valid history, phase records and decisions.
3. Don't duplicate facts — link to the authoritative doc.
4. Update FILE_CATALOG only for new, changed, moved or removed files.
5. Promote DECIDED → VERIFIED only when seen in code.
6. Record unknowns as UNVERIFIED; keep dates accurate and name the evidence used.

## 13. Final report (after every docs or phase operation)

- Docs created / modified / deleted, each with one-line purpose.
- Verified architecture and governance findings.
- Plan-vs-code gaps and conflicts, and how they were resolved.
- UNVERIFIED items needing the owner.
- Commands run and exact results.
- Phase status summary (ACTIVE, APPROVED, PLANNED, CLOSED).
- Confirmation that production code, packages, config and generated files were not changed (for docs-only operations), or the exact file log (for executed phases).