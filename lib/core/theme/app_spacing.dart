/// Spacing tokens of the Asatiza design system, in logical pixels.
abstract final class AppSpacing {
  /// Icon-to-label gap, badge padding.
  static const double space1 = 4;

  /// Gap between chips, between avatar and name.
  static const double space2 = 8;

  /// Gap between stacked feed cards, chip padding.
  static const double space3 = 12;

  /// Screen side margin and card padding (the default).
  static const double space4 = 16;

  /// Padding inside bottom sheets.
  static const double space5 = 20;

  /// Gap between form sections, title to content.
  static const double space6 = 24;

  /// Top/bottom breathing room on auth screens.
  static const double space8 = 32;

  /// Minimum touch target height.
  static const double space12 = 48;

  // ---- Artboard gaps outside the spacing scale (design is the source of
  // truth; token values above are unchanged). ----
  static const double gap2 = 2;
  static const double gap6 = 6;
  static const double gap10 = 10;
  static const double gap14 = 14;
  static const double gap18 = 18;
  static const double gap22 = 22;
}
