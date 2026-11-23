# Project Overview

Labels: **VERIFIED** = seen in this repo · **DECIDED** = owner-approved in `docs/product/*`, not yet in code · **UNVERIFIED** = owner confirmation required.

## Verified Facts (updated 2026-11-19, `PHASE_001`)

- 2026-11-19 (`PHASE_002`, part 1): UI for onboarding, sign-in, profile setup, home feed, post detail, create post and report built from the design canvas with in-memory mock data; dependencies `flutter_bloc ^9.1.1`, `flutter_svg ^2.3.4`, `equatable ^3.0.0` added. VERIFIED

- 2026-11-23 (`PHASE_003`, part 2): the rest of the design — Teachers / Students lists with search and filters, public profiles, connect requests, My connections, search results, chats, notifications with unread badges, My profile, Edit profile, Settings (change password, blocked users, policies, log out, delete account) — on in-memory mock data; no new dependencies. VERIFIED

- Package name: `asatiza` (`pubspec.yaml`), version `1.0.0+1`, description "Asatiza — Quran teacher & student network". VERIFIED
- Dart SDK constraint: `^3.11.0`. VERIFIED
- Dependencies: `flutter`, `cupertino_icons ^1.0.8`, `go_router ^17.5.0`, `flutter_localizations` (SDK), `intl` (SDK-pinned); dev: `flutter_test`, `flutter_lints ^6.0.0`. Fonts bundled: Fraunces, Plus Jakarta Sans, Amiri (OFL). VERIFIED
- Entry point: `lib/main.dart` (boot) → `lib/app.dart` (`AsatizaApp`: light/dark theme, English localization, go_router shell). VERIFIED
- Tests: `test/app_test.dart`, `test/core/router/app_router_test.dart`, `test/core/theme/app_theme_test.dart`. VERIFIED
- Android: `android/app/build.gradle.kts`, namespace/applicationId `com.asatiza.app`, label "Asatiza", Java/Kotlin 17. VERIFIED
- iOS: `ios/Runner.xcodeproj`, bundle ID `com.asatiza.app`, `CFBundleName` "Asatiza", `CFBundleLocalizations` en, no `Podfile` yet. Tested by the developer (2026-11-19). VERIFIED
- Not present: `supabase/`, `integration_test/`, `.github/`. Git repository on branch `main`. VERIFIED
- Design source: owner's Claude Design canvas "Asatiza App Design" (https://claude.ai/artifact/LUxhadrsA4EUF74spHVLLc) with the "Asatiza" design system. The design is the source of truth for UI. DECIDED

## Product

- Asatiza — "Find Quran Teachers": a LinkedIn-style professional network for the Quran-learning world. DECIDED
- Roles: Teacher and Student, one role per account, chosen at sign-up; sign-up is for adults 18+, and a parent may open a Student account for their child (separate parent/child accounts are v2.0). DECIDED
- Version in progress: 1.0 "Connect" (later 1.1 Polish, 2.0 Learn, 3.0 Grow, 4.0 Scale). DECIDED
- Full details: [VERSION_1_PLAN.md](product/VERSION_1_PLAN.md) · [FULL_PRODUCT_PLAN.md](product/FULL_PRODUCT_PLAN.md).

## Version 1.0 Scope (DECIDED)

Sign up with name/email/password/role + 6-digit email OTP · email + password login · forgot password by OTP · skip-able profile setup with strength meter · home feed · create post (text + 1 photo + tag) · like/comment/report · Teachers/Students tab with search and filters · connections · 1-to-1 chat after connecting · notifications tab + push · report/block/delete account · admin approval of teachers · settings.

## Stack (DECIDED)

Flutter (Android + iOS) · BLoC (`flutter_bloc`, Cubit by default) · go_router · Dio (Edge Functions, later Python API) · Supabase free plan (Auth, Postgres + RLS, Storage, Realtime, Edge Functions) · Firebase Cloud Messaging + Crashlytics only · Brevo SMTP · later Python FastAPI behind repository interfaces.

## High-Risk Flows

- Sign-up, 6-digit email OTP, login, forgot password, session restore, auth redirect, 18+ consent.
- Row Level Security on every table; Storage bucket policies (`avatars`, `post-images`, `certificates`, `chat-images`).
- Realtime chat, unread counts, read ticks.
- FCM push via the `send-push` Edge Function and device tokens.
- Account deletion (in-app + web page), report/block, auto-hide at 3 reports, teacher approval and visibility rules.
- Native Android/iOS configuration, app IDs, signing, permissions.

## Development Posture

Build against the owner-approved plan through approved phases (`docs/phases/`). Do not create alternate architecture layers, parallel data clients or a second state-management system.

## Unverified Items

- Final Android package name / iOS bundle ID: DECIDED `com.asatiza.app`
- Platforms: DECIDED Android + iOS in v1.0
- Phase approver and manual tester: DECIDED — the developer (repository owner)
- Supabase project created (yes/no): UNVERIFIED — developer confirmation required
- Extra testing expectations (e.g. minimum widget tests per feature): UNVERIFIED — developer confirmation required
- Git remote and branching strategy: UNVERIFIED — developer confirmation required (local branch `main` exists)
