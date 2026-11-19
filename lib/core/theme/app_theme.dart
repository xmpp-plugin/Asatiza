import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

/// Builds the light and dark Material 3 themes from the design tokens.
abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light, AppColors.light);

  static ThemeData dark() => _build(Brightness.dark, AppColors.dark);

  static ThemeData _build(Brightness brightness, AppColors colors) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: colors.brand600,
      onPrimary: colors.onBrand,
      primaryContainer: colors.brand100,
      onPrimaryContainer: colors.brand700,
      secondary: colors.gold500,
      onSecondary: colors.onGold,
      secondaryContainer: colors.gold100,
      onSecondaryContainer: colors.gold700,
      error: colors.danger,
      onError: colors.onDanger,
      errorContainer: colors.danger100,
      onErrorContainer: colors.danger,
      surface: colors.surface100,
      onSurface: colors.ink,
      onSurfaceVariant: colors.inkMuted,
      surfaceContainerLowest: colors.surface000,
      surfaceContainerLow: colors.surface000,
      surfaceContainer: colors.surface000,
      surfaceContainerHigh: colors.surface200,
      surfaceContainerHighest: colors.surface200,
      outline: colors.line,
      outlineVariant: colors.line,
      scrim: colors.scrim,
    );

    final textTheme = const TextTheme(
      displayLarge: AppTextStyles.displayLg,
      displayMedium: AppTextStyles.displayMd,
      headlineSmall: AppTextStyles.screenTitle,
      titleLarge: AppTextStyles.titleLg,
      titleMedium: AppTextStyles.titleMd,
      bodyLarge: AppTextStyles.bodyLg,
      bodyMedium: AppTextStyles.body,
      bodySmall: AppTextStyles.caption,
      labelLarge: AppTextStyles.label,
      labelSmall: AppTextStyles.caption,
    ).apply(bodyColor: colors.ink, displayColor: colors.ink);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      fontFamily: AppTextStyles.sansFamily,
      textTheme: textTheme,
      scaffoldBackgroundColor: colors.surface100,
      dividerColor: colors.line,
      extensions: <ThemeExtension<dynamic>>[colors],
    );
  }
}
