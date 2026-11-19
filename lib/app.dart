import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/router/app_router.dart';
import 'core/session/session_cubit.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';

/// Root widget: light/dark theme from the design tokens (following the
/// phone setting), English localization and the session-aware router.
/// Expects [SessionCubit] and the repositories above it (see `main.dart`).
class AsatizaApp extends StatefulWidget {
  const AsatizaApp({super.key});

  @override
  State<AsatizaApp> createState() => _AsatizaAppState();
}

class _AsatizaAppState extends State<AsatizaApp> {
  late final GoRouter _router = createAppRouter(context.read<SessionCubit>());

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: _router,
    );
  }
}
