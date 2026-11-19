import 'package:flutter/painting.dart';

/// Type scale of the Asatiza design system. Sizes and line heights are in
/// logical pixels; `height` is line height divided by font size.
///
/// Styles carry no color: the theme applies `ink` / `ink-muted`.
abstract final class AppTextStyles {
  /// Display family: headings on Welcome and auth screens.
  static const String displayFamily = 'Fraunces';

  /// Interface family: everything else.
  static const String sansFamily = 'PlusJakartaSans';

  /// Arabic family: Quranic verses, always right-to-left, never italic.
  static const String arabicFamily = 'Amiri';

  static const TextStyle displayLg = TextStyle(
    fontFamily: displayFamily,
    fontSize: 32,
    height: 38 / 32,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.32,
  );

  static const TextStyle displayMd = TextStyle(
    fontFamily: displayFamily,
    fontSize: 26,
    height: 32 / 26,
    fontWeight: FontWeight.w600,
  );

  /// Tab screen titles (Teachers, Chats, Notifications). Taken from the
  /// artboards (24 px / 700); line height 32 px is assumed.
  static const TextStyle screenTitle = TextStyle(
    fontFamily: sansFamily,
    fontSize: 24,
    height: 32 / 24,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle titleLg = TextStyle(
    fontFamily: sansFamily,
    fontSize: 20,
    height: 26 / 20,
    fontWeight: FontWeight.w700,
  );

  /// Full-screen page titles ("New post"). Taken from the artboard
  /// (18 px / 700); line height 24 px is assumed.
  static const TextStyle pageTitle = TextStyle(
    fontFamily: sansFamily,
    fontSize: 18,
    height: 24 / 18,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle titleMd = TextStyle(
    fontFamily: sansFamily,
    fontSize: 17,
    height: 24 / 17,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bodyLg = TextStyle(
    fontFamily: sansFamily,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle body = TextStyle(
    fontFamily: sansFamily,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle label = TextStyle(
    fontFamily: sansFamily,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: sansFamily,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w500,
  );

  /// Active bottom-bar label: [caption] in bold, as on the artboards.
  static const TextStyle captionBold = TextStyle(
    fontFamily: sansFamily,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle quran = TextStyle(
    fontFamily: arabicFamily,
    fontSize: 24,
    height: 44 / 24,
    fontWeight: FontWeight.w400,
  );
}
