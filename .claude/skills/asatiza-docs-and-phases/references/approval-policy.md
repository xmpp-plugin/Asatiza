# Approval Policy

Require approval for:

- Medium-risk phases unless the developer has explicitly asked for direct execution.
- All high-risk phases.
- Creating new production files or classes unless they were explicitly listed and approved in the phase plan.
- Refactoring, moving files, renaming classes, renaming public methods, replacing state management, replacing repositories, replacing navigation, splitting/combining controllers, creating new architecture layers, changing shared model design, converting patterns, rewriting working logic, or broad cleanup.
- Dependency, Flutter, Dart, CocoaPods, Gradle, Android Gradle Plugin, Kotlin, Swift, Xcode, deployment target, package ID, signing, CI/CD, or environment changes.
- Auth, authorization, payments, subscriptions, database schemas/migrations, encryption, token storage, API contracts, Firebase initialization, notifications, background services, deep links, WebSockets, realtime listeners, Supabase Row Level Security policies, Storage bucket policies, Edge Functions, Supabase Auth/SMTP/OTP settings, the 18+ age gate, report/block/moderation and visibility rules, teacher approval, user/account deletion, shared core widgets, shared models, and native Android/iOS code.

Before approved refactoring, explain why the existing code cannot safely support the fix, what would change, affected flows, behavior changes, and rollback.

For each proposed new production file or class, document name, path, responsibility, why it is required, why existing code cannot be extended safely, whether it is module-specific or shared, architecture impact, expected callers, and testing requirements.
