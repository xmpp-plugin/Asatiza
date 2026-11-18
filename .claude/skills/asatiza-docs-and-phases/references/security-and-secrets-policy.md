# Security And Secrets Policy

Applies to every normal scoped change, documentation task and phase operation.

## Secrets

- Secrets never appear in code, docs, phase files or chat: Supabase `service_role` key, database password, Brevo SMTP credentials, FCM service-account JSON, signing keystores and passwords, `.env` contents.
- Only the Supabase URL and anon/publishable key may be used by the app, supplied through `--dart-define` / `--dart-define-from-file` or env config. Never hard-code them in source or docs.
- For `google-services.json`, `GoogleService-Info.plist`, keystores, `key.properties` and `.env*` files: record only whether they exist and where, never their contents.
- Never record test-account passwords; record only the account role/label.

## Protected Product Rules

Never weaken, bypass or "temporarily disable":

- The 18+ age gate at sign-up.
- Row Level Security on any table, or Storage bucket policies.
- Report, block, auto-hide-at-3-reports and moderation rules.
- Teacher approval before visibility, and student visibility rules.
- In-app account deletion and the deletion web page.
- Admin-only columns: the app never writes `profiles.role`, `is_verified` or `is_hidden`.

## Destructive And Remote Actions

- No `rm -rf` of project folders, `git reset --hard`, `git clean`, `supabase db reset` against a linked remote project, or dropping tables/buckets.
- Never commit, push, merge, tag, build a release, upload to Play Console/App Store, or deploy Supabase migrations/functions/settings to the remote project unless the developer explicitly asks for that specific action.
- Do not discard or overwrite the developer's uncommitted changes.
