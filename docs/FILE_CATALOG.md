# File Catalog

Every project-owned file under `lib/`, `supabase/`, `test/` and `integration_test/`. Generated and tool files are not catalogued. Update only for new, changed, moved or removed files.

Last audit: 2026-11-19 (`PHASE_001_FOUNDATION_ADD_PROJECT_FOUNDATION`).

| Path | Purpose | Layer | Public classes / functions | Dependencies | Side effects |
|---|---|---|---|---|---|
| `lib/main.dart` | Composition root: starts the app, registers the OFL font licenses | App entry | `main()` | `flutter/foundation`, `flutter/services`, `app.dart` | `runApp`, `LicenseRegistry.addLicense` |
| `lib/app.dart` | Root widget: light/dark theme (system), English localization, router | App | `AsatizaApp` | `app_router.dart`, `app_theme.dart`, `AppLocalizations` | None |
| `lib/core/theme/app_colors.dart` | Design color tokens, light and dark sets (`ThemeExtension`) | Core theme | `AppColors` | `flutter/material` | None |
| `lib/core/theme/app_text_styles.dart` | Design type scale + `screenTitle`, `pageTitle`, `captionBold` | Core theme | `AppTextStyles` | `flutter/painting` | None |
| `lib/core/theme/app_spacing.dart` | Spacing tokens 4–48 | Core theme | `AppSpacing` | None | None |
| `lib/core/theme/app_radius.dart` | Radius tokens sm–pill | Core theme | `AppRadius` | None | None |
| `lib/core/theme/app_shadows.dart` | `shadow-card`, `shadow-raised` per brightness | Core theme | `AppShadows` | `flutter/painting` | None |
| `lib/core/theme/app_theme.dart` | Builds light and dark Material 3 `ThemeData` from the tokens | Core theme | `AppTheme` | theme token files | None |
| `lib/core/router/app_routes.dart` | Route path constants | Core router | `AppRoutes` | None | None |
| `lib/core/router/app_router.dart` | `StatefulShellRoute` (Home, Teachers, Chats, Alerts) + full-screen Create post | Core router | `appRouter` | `go_router`, shell, screens | None |
| `lib/core/widgets/main_shell.dart` | Designed bottom bar with raised centre "+"; back on a non-Home tab goes Home | Core widget | `MainShell` | `go_router`, theme, `AppLocalizations` | Navigation |
| `lib/features/feed/presentation/home_screen.dart` | Home tab placeholder | Feature UI | `HomeScreen` | `flutter/material` | None |
| `lib/features/discover/presentation/discover_screen.dart` | Teachers tab placeholder (title) | Feature UI | `DiscoverScreen` | theme, `AppLocalizations` | None |
| `lib/features/chat/presentation/chats_screen.dart` | Chats tab placeholder (title) | Feature UI | `ChatsScreen` | theme, `AppLocalizations` | None |
| `lib/features/notifications/presentation/notifications_screen.dart` | Alerts tab placeholder, title "Notifications" | Feature UI | `NotificationsScreen` | theme, `AppLocalizations` | None |
| `lib/features/post/presentation/create_post_screen.dart` | "New post" full-screen placeholder with Close | Feature UI | `CreatePostScreen` | `go_router`, theme, `AppLocalizations` | Navigation (pop) |
| `lib/l10n/app_en.arb` | English strings (template) | Localization | — | — | None |
| `test/app_test.dart` | App boots on Home; tabs + centre button; light/dark tokens follow the phone | Test | `main()` | `flutter_test` | None |
| `test/core/router/app_router_test.dart` | Tab switching, kept branch state, Create post open/close, system back | Test | `main()` | `flutter_test` | None |
| `test/core/theme/app_theme_test.dart` | Theme pinned to the design tokens (light, dark, type scale) | Test | `main()` | `flutter_test` | None |

Generated, not catalogued: `lib/l10n/app_localizations.dart`, `lib/l10n/app_localizations_en.dart` (`flutter gen-l10n`, configured by `l10n.yaml`).

`supabase/` and `integration_test/` do not exist yet.
