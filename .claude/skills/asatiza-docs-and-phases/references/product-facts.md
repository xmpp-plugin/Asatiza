# Product Facts (Owner-Decided)

These come from the owner's product plan. Label every fact in docs with one of:

- **VERIFIED** — seen in code/config in this repo.
- **DECIDED** — approved in the product plan, not yet in code.
- **UNVERIFIED** — owner confirmation required. Write `UNVERIFIED — developer confirmation required`.

| Area | Decision |
|---|---|
| Product | Asatiza — Quran teacher & student professional network |
| Version in progress | 1.0 "Connect" (later: 1.1 Polish, 2.0 Learn, 3.0 Grow, 4.0 Scale) |
| Roles | Teacher, Student (one role per account). Sign-up is for adults 18+; a parent may open a Student account for their child (exact flow is an open decision in `docs/KNOWN_ISSUES.md`). Separate parent/child accounts are v2.0 |
| Platforms | Android + iOS, one Flutter codebase |
| State management | BLoC (`flutter_bloc`): Cubit by default, Bloc for event-heavy flows (auth, chat, feed paging). Repositories injected with `RepositoryProvider`. Owner decision 2026-11-18; replaces `flutter_riverpod` listed in the PDF plan |
| HTTP / API | `supabase_flutter` for Auth, database, Storage, Realtime. Dio for Edge Function HTTP calls and the later Python FastAPI. Owner decision 2026-11-18 |
| Navigation | go_router; 5 bottom tabs: Home · Teachers/Students · + Post · Chats · Notifications; profile from top-left avatar |
| Backend v1.0 | Supabase free plan: Auth, Postgres + Row Level Security, Storage, Realtime, Edge Functions |
| Auth | Sign up = name + email + password + role, confirmed by 6-digit email OTP. Login = email + password only. Forgot password = email OTP |
| Push / crashes | Firebase Cloud Messaging + Crashlytics only (no Firestore, no Firebase Auth, no Firebase Storage) |
| Email | Brevo SMTP connected to Supabase Auth |
| Later backend | Python FastAPI, introduced feature by feature behind repository interfaces |
| Data layer | Screens → blocs/cubits → repository interfaces → `supabase/` implementations (later `api/`) |

## Product Source Of Truth

Read first; never edit unless the owner asks:

- `docs/product/VERSION_1_PLAN.md`
- `docs/product/FULL_PRODUCT_PLAN.md`

These are exports of the owner's Claude docs "Asatiza — Version 1.0 Plan (Release 1)" and "Asatiza — Full Product Plan (All Versions)". If they are missing, stop and ask the owner to export them as Markdown into `docs/product/`. Do not invent product details.

## Conflict Resolution (recorded once in `docs/ARCHITECTURE.md`)

- Generic rule: "documentation must not introduce architecture." → Merged rule: the architecture above is owner-approved, so docs describe it as the DECIDED target. It becomes VERIFIED only when it exists in code.
- If code differs from the plan: code wins for VERIFIED facts; record the gap in `docs/KNOWN_ISSUES.md` and ask the owner which is correct. Never silently "fix" either side.
