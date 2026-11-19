# Coding Standards

## Verified Local Standards

- `analysis_options.yaml` includes `package:flutter_lints/flutter.yaml` with no custom rules. VERIFIED

## Rules For New Work

- Every user-facing string comes from `lib/l10n/app_en.arb` via `AppLocalizations.of(context)`; never hard-code UI text. Never hand-edit the generated `app_localizations*.dart`.
- Direction-neutral layout for v1.1 Urdu/Arabic: `EdgeInsetsDirectional`, `AlignmentDirectional`, `start`/`end` instead of left/right.
- Colors only from `AppColors` / `ColorScheme`; text from `AppTextStyles`; spacing, radii and shadows from their token classes.
- Sound null safety; avoid `!` unless the invariant is proven nearby.
- Immutable models and state; `const` constructors where possible.
- `async`/`await` with explicit error handling; never ignore a `Future` that can fail; check `mounted` (widgets) / `isClosed` (blocs/cubits) after awaits before using context or state.
- Follow the SOLID rules in `CLASS_AND_COMPONENT_RULES.md`: constructor injection, depend on interfaces, business rules in `logic/` classes, plugins behind `lib/core/services/`, one public class per file.
- No Supabase, Dio, plugins or SQL in UI; no business rules in widgets or blocs.
- No secrets in source; Supabase URL and anon key only via `--dart-define`/env config.
- Dispose controllers, subscriptions, timers and Realtime channels.
- Use the theme for colors and text styles; no hard-coded colors in features.
- Use the smallest complete safe change; match the affected feature's existing pattern.
- Format only changed Dart files during validation.
- Avoid unrelated lint cleanup, rename churn or large rewrites.
