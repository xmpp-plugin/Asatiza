import 'package:flutter/material.dart';

/// Color tokens of the Asatiza design system (owner's design canvas,
/// `project/ds/asatiza/tokens.json`), one set per brightness.
///
/// Read in widgets with `Theme.of(context).extension<AppColors>()!`.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.surface000,
    required this.surface100,
    required this.surface200,
    required this.line,
    required this.ink,
    required this.inkMuted,
    required this.brand700,
    required this.brand600,
    required this.brand100,
    required this.onBrand,
    required this.gold500,
    required this.gold700,
    required this.gold100,
    required this.onGold,
    required this.danger,
    required this.danger100,
    required this.onDanger,
    required this.scrim,
  });

  /// Cards, sheets, inputs, bottom bar.
  final Color surface000;

  /// Page background behind every screen.
  final Color surface100;

  /// Quiet fills: search bar, unselected chips, skeletons.
  final Color surface200;

  /// 1 px hairlines: borders and dividers.
  final Color line;

  /// Primary text and icons.
  final Color ink;

  /// Secondary text, inactive tab labels.
  final Color inkMuted;

  /// Brand-coloured text and icons, active tab label.
  final Color brand700;

  /// Primary buttons, the centre Post button.
  final Color brand600;

  /// Brand tint: selected chips, active tab pill.
  final Color brand100;

  /// Text and icons on [brand600].
  final Color onBrand;

  /// Gold accent fill (Verified badge).
  final Color gold500;

  /// Gold as text.
  final Color gold700;

  /// Gold tint.
  final Color gold100;

  /// Icon on [gold500].
  final Color onGold;

  /// Errors, destructive actions, unread badges.
  final Color danger;

  /// Error banner background.
  final Color danger100;

  /// Text on [danger].
  final Color onDanger;

  /// Dim layer behind sheets and dialogs.
  final Color scrim;

  /// Success states use the brand green (`success` token = `brand-600`).
  Color get success => brand600;

  static const AppColors light = AppColors(
    surface000: Color(0xFFFFFFFF),
    surface100: Color(0xFFF7F4EC),
    surface200: Color(0xFFEFE9DC),
    line: Color(0xFFE2DAC8),
    ink: Color(0xFF1C2421),
    inkMuted: Color(0xFF5B6661),
    brand700: Color(0xFF0B4A3C),
    brand600: Color(0xFF0F5E4C),
    brand100: Color(0xFFDCEFE8),
    onBrand: Color(0xFFFFFFFF),
    gold500: Color(0xFFC8962E),
    gold700: Color(0xFF8A6212),
    gold100: Color(0xFFF6ECD4),
    onGold: Color(0xFF2A1D03),
    danger: Color(0xFFB42318),
    danger100: Color(0xFFFDE8E6),
    onDanger: Color(0xFFFFFFFF),
    scrim: Color.fromRGBO(16, 24, 21, 0.45),
  );

  static const AppColors dark = AppColors(
    surface000: Color(0xFF1A2220),
    surface100: Color(0xFF121816),
    surface200: Color(0xFF232D2A),
    line: Color(0xFF2F3A36),
    ink: Color(0xFFEEF2EF),
    inkMuted: Color(0xFFA3B0AA),
    brand700: Color(0xFF6CC9A8),
    brand600: Color(0xFF3FAE8C),
    brand100: Color(0xFF173A31),
    onBrand: Color(0xFF0B1A15),
    gold500: Color(0xFFE0B354),
    gold700: Color(0xFFE6C27A),
    gold100: Color(0xFF3A2F17),
    onGold: Color(0xFF2A1D03),
    danger: Color(0xFFF07167),
    danger100: Color(0xFF3D1C1A),
    onDanger: Color(0xFF1A0605),
    scrim: Color.fromRGBO(0, 0, 0, 0.6),
  );

  @override
  AppColors copyWith({
    Color? surface000,
    Color? surface100,
    Color? surface200,
    Color? line,
    Color? ink,
    Color? inkMuted,
    Color? brand700,
    Color? brand600,
    Color? brand100,
    Color? onBrand,
    Color? gold500,
    Color? gold700,
    Color? gold100,
    Color? onGold,
    Color? danger,
    Color? danger100,
    Color? onDanger,
    Color? scrim,
  }) {
    return AppColors(
      surface000: surface000 ?? this.surface000,
      surface100: surface100 ?? this.surface100,
      surface200: surface200 ?? this.surface200,
      line: line ?? this.line,
      ink: ink ?? this.ink,
      inkMuted: inkMuted ?? this.inkMuted,
      brand700: brand700 ?? this.brand700,
      brand600: brand600 ?? this.brand600,
      brand100: brand100 ?? this.brand100,
      onBrand: onBrand ?? this.onBrand,
      gold500: gold500 ?? this.gold500,
      gold700: gold700 ?? this.gold700,
      gold100: gold100 ?? this.gold100,
      onGold: onGold ?? this.onGold,
      danger: danger ?? this.danger,
      danger100: danger100 ?? this.danger100,
      onDanger: onDanger ?? this.onDanger,
      scrim: scrim ?? this.scrim,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) {
      return this;
    }
    return AppColors(
      surface000: Color.lerp(surface000, other.surface000, t)!,
      surface100: Color.lerp(surface100, other.surface100, t)!,
      surface200: Color.lerp(surface200, other.surface200, t)!,
      line: Color.lerp(line, other.line, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkMuted: Color.lerp(inkMuted, other.inkMuted, t)!,
      brand700: Color.lerp(brand700, other.brand700, t)!,
      brand600: Color.lerp(brand600, other.brand600, t)!,
      brand100: Color.lerp(brand100, other.brand100, t)!,
      onBrand: Color.lerp(onBrand, other.onBrand, t)!,
      gold500: Color.lerp(gold500, other.gold500, t)!,
      gold700: Color.lerp(gold700, other.gold700, t)!,
      gold100: Color.lerp(gold100, other.gold100, t)!,
      onGold: Color.lerp(onGold, other.onGold, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      danger100: Color.lerp(danger100, other.danger100, t)!,
      onDanger: Color.lerp(onDanger, other.onDanger, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
    );
  }
}
