import 'package:asatiza/core/theme/app_colors.dart';
import 'package:asatiza/core/theme/app_radius.dart';
import 'package:asatiza/core/theme/app_spacing.dart';
import 'package:asatiza/core/theme/app_text_styles.dart';
import 'package:asatiza/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pins the theme to the Asatiza design-system tokens (tokens.json), so a
/// drift between design and code shows up as a failing test.
void main() {
  group('light theme', () {
    final theme = AppTheme.light();
    final colors = theme.extension<AppColors>()!;

    test('maps the light color tokens', () {
      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme.primary, const Color(0xFF0F5E4C));
      expect(theme.colorScheme.onPrimary, const Color(0xFFFFFFFF));
      expect(theme.colorScheme.error, const Color(0xFFB42318));
      expect(theme.scaffoldBackgroundColor, const Color(0xFFF7F4EC));
      expect(colors.surface000, const Color(0xFFFFFFFF));
      expect(colors.line, const Color(0xFFE2DAC8));
      expect(colors.ink, const Color(0xFF1C2421));
      expect(colors.inkMuted, const Color(0xFF5B6661));
      expect(colors.brand700, const Color(0xFF0B4A3C));
      expect(colors.brand100, const Color(0xFFDCEFE8));
      expect(colors.gold500, const Color(0xFFC8962E));
      expect(colors.success, colors.brand600);
    });

    test('uses Plus Jakarta Sans and ink for body text', () {
      expect(theme.textTheme.bodyMedium!.fontFamily, 'PlusJakartaSans');
      expect(theme.textTheme.bodyMedium!.color, const Color(0xFF1C2421));
    });
  });

  group('dark theme', () {
    final theme = AppTheme.dark();
    final colors = theme.extension<AppColors>()!;

    test('maps the dark color tokens', () {
      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.primary, const Color(0xFF3FAE8C));
      expect(theme.colorScheme.onPrimary, const Color(0xFF0B1A15));
      expect(theme.colorScheme.error, const Color(0xFFF07167));
      expect(theme.scaffoldBackgroundColor, const Color(0xFF121816));
      expect(colors.surface000, const Color(0xFF1A2220));
      expect(colors.ink, const Color(0xFFEEF2EF));
      expect(colors.brand700, const Color(0xFF6CC9A8));
      expect(colors.brand100, const Color(0xFF173A31));
      expect(colors.gold500, const Color(0xFFE0B354));
    });
  });

  test('text styles match the design type scale', () {
    void expectStyle(
      TextStyle style, {
      required String family,
      required double size,
      required double lineHeight,
      required FontWeight weight,
    }) {
      expect(style.fontFamily, family);
      expect(style.fontSize, size);
      expect(style.height! * size, closeTo(lineHeight, 0.001));
      expect(style.fontWeight, weight);
    }

    expectStyle(
      AppTextStyles.displayLg,
      family: 'Fraunces',
      size: 32,
      lineHeight: 38,
      weight: FontWeight.w600,
    );
    expectStyle(
      AppTextStyles.displayMd,
      family: 'Fraunces',
      size: 26,
      lineHeight: 32,
      weight: FontWeight.w600,
    );
    expectStyle(
      AppTextStyles.titleLg,
      family: 'PlusJakartaSans',
      size: 20,
      lineHeight: 26,
      weight: FontWeight.w700,
    );
    expectStyle(
      AppTextStyles.titleMd,
      family: 'PlusJakartaSans',
      size: 17,
      lineHeight: 24,
      weight: FontWeight.w600,
    );
    expectStyle(
      AppTextStyles.bodyLg,
      family: 'PlusJakartaSans',
      size: 16,
      lineHeight: 24,
      weight: FontWeight.w400,
    );
    expectStyle(
      AppTextStyles.body,
      family: 'PlusJakartaSans',
      size: 14,
      lineHeight: 20,
      weight: FontWeight.w400,
    );
    expectStyle(
      AppTextStyles.label,
      family: 'PlusJakartaSans',
      size: 14,
      lineHeight: 20,
      weight: FontWeight.w600,
    );
    expectStyle(
      AppTextStyles.caption,
      family: 'PlusJakartaSans',
      size: 12,
      lineHeight: 16,
      weight: FontWeight.w500,
    );
    expectStyle(
      AppTextStyles.quran,
      family: 'Amiri',
      size: 24,
      lineHeight: 44,
      weight: FontWeight.w400,
    );
    // Artboard values outside the type scale (PHASE_002).
    expectStyle(
      AppTextStyles.splashWordmark,
      family: 'Fraunces',
      size: 44,
      lineHeight: 48,
      weight: FontWeight.w600,
    );
    expectStyle(
      AppTextStyles.authTitle,
      family: 'Fraunces',
      size: 28,
      lineHeight: 34,
      weight: FontWeight.w600,
    );
    expectStyle(
      AppTextStyles.bodyMd,
      family: 'PlusJakartaSans',
      size: 15,
      lineHeight: 22,
      weight: FontWeight.w400,
    );
    expectStyle(
      AppTextStyles.helper,
      family: 'PlusJakartaSans',
      size: 13,
      lineHeight: 18,
      weight: FontWeight.w400,
    );
    expectStyle(
      AppTextStyles.composer,
      family: 'PlusJakartaSans',
      size: 17,
      lineHeight: 26,
      weight: FontWeight.w400,
    );
  });

  test('artboard spacing and radius values', () {
    expect(
      <double>[
        AppSpacing.gap2,
        AppSpacing.gap6,
        AppSpacing.gap10,
        AppSpacing.gap14,
        AppSpacing.gap18,
        AppSpacing.gap22,
      ],
      <double>[2, 6, 10, 14, 18, 22],
    );
    expect(
      <double>[
        AppRadius.commentTail,
        AppRadius.checkbox,
        AppRadius.segment,
        AppRadius.otpBox,
        AppRadius.optionCard,
        AppRadius.strengthCard,
      ],
      <double>[4, 6, 9, 10, 14, 20],
    );
  });
}
