# Change Approval Rules

## Risk Levels

**High risk — explicit approval before any change:** authentication, OTP, sessions, auth redirect; RLS policies, migrations, schema, data deletion, account deletion; Storage bucket policies; Edge Functions, FCM/push, Realtime; secrets/env config; `pubspec.yaml` packages, Flutter/Dart SDK versions; `android/`/`ios/` native config, permissions, signing, app IDs, deep links; repository interfaces; age gate, report/block/moderation and visibility rules; Supabase Auth/SMTP/rate-limit settings; CI/CD, store listings, releases; shared core widgets/theme used across features; state-management or routing replacement; directory restructuring.

**Medium risk:** new screen or widget inside an existing feature; bloc/cubit logic changes; repository behavior inside an existing contract; new model field that already exists in the schema; navigation changes inside an existing route tree; cache behavior; new shared helper; extending a common widget.

**Low risk:** copy/text, styling within the theme, isolated bug fix in one widget, local validation, local null-safety correction, tests, docs.

## Approval Requirements

- Low-risk implementation is allowed directly only when the developer explicitly requested direct implementation and the repository rules allow it.
- Medium-risk phases normally require explicit approval before execution.
- High-risk phases always require explicit approval before execution.
- A phase cannot execute when business requirements, expected behavior, API contract, model contract, design, permissions, dependencies, native configuration, expected files, tests, rollback, or approval status are unclear.

## New File And Class Approval

Creating a new production file or class requires approval unless it was explicitly listed and approved in the phase plan.

During phase analysis, document each proposed new file or class:

- Name
- Path
- Responsibility
- Why it is required
- Why an existing file or class cannot be extended safely
- Whether it is module-specific or shared
- Architecture impact
- Expected callers
- Testing requirements

During execution, if an unplanned new file/class becomes necessary, stop, do not create it, update the phase, keep status `ACTIVE`, set step to `APPROVAL`, set approval to `PENDING`, and continue only after approval.

Approval is especially required for new blocs, cubits, repositories, Supabase tables, migrations, RPC functions, Edge Functions, Storage buckets, services, managers, models, API clients, database entities, shared widgets, shared helpers, routes, architecture layers, platform channels, native classes, background services, and Firebase services.

Small private helper methods inside an already approved file do not require separate approval when they stay inside approved scope and do not change architecture.

## Refactoring

No automatic refactoring. Require a dedicated approved refactor phase for moving files, renaming classes/public methods, replacing state management/repositories/navigation, splitting or combining controllers, creating new architecture layers, changing shared model design, converting patterns, rewriting working logic, broad cleanup, formatting unrelated files, or fixing unrelated warnings.

A refactor phase must include objective, current problem, measurable benefit, exact files, behavior-preservation plan, regression test plan, rollback plan, and explicit approval.

## Dependency And Platform Protection

Do not change Flutter, Dart, CocoaPods, Gradle, Android Gradle Plugin, Kotlin, Swift, Xcode settings, package versions, production dependencies, deployment targets, app IDs, signing, CI/CD, environment configuration, Supabase project settings, native Android, or native iOS without explicit approval.

Unplanned new files, classes, packages, tables, API contracts or platform changes during execution → stop and ask.
