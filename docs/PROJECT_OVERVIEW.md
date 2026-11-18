# Project Overview

Labels: **VERIFIED** = seen in this repo · **DECIDED** = owner-approved in `docs/product/*`, not yet in code · **UNVERIFIED** = owner confirmation required.

## Verified Facts (audit 2026-11-18)

- Package name: `asatiza` (`pubspec.yaml`), version `1.0.0+1`, description "A new Flutter project.". VERIFIED
- Dart SDK constraint: `^3.11.0`. VERIFIED
- Dependencies: `flutter`, `cupertino_icons ^1.0.8`; dev: `flutter_test`, `flutter_lints ^6.0.0`. VERIFIED
- Entry point: `lib/main.dart` — unmodified `flutter create` counter app (`MyApp`, `MyHomePage`, title "Flutter Demo"). VERIFIED
- Tests: `test/widget_test.dart` (starter counter smoke test). VERIFIED
- Android: `android/app/build.gradle.kts`, namespace/applicationId `com.example.asatiza` (placeholder), Java/Kotlin 17. VERIFIED
- iOS: `ios/Runner.xcodeproj`, no `Podfile` yet. VERIFIED
- Not present: `supabase/`, `integration_test/`, `.github/`, `.git` (folder is not a Git repository). VERIFIED

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

- Final Android package name / iOS bundle ID (currently `com.example.asatiza`): UNVERIFIED — developer confirmation required
- Android first, or Android + iOS together in v1.0: UNVERIFIED — developer confirmation required
- Who approves phases and performs manual testing: UNVERIFIED — developer confirmation required
- Supabase project created (yes/no): UNVERIFIED — developer confirmation required
- Extra testing expectations (e.g. minimum widget tests per feature): UNVERIFIED — developer confirmation required
- Git repository / remote and branching: UNVERIFIED — developer confirmation required
