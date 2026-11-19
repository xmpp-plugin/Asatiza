/// Corner radius tokens of the Asatiza design system, in logical pixels.
abstract final class AppRadius {
  /// Tags, small thumbnails, OTP boxes.
  static const double sm = 8;

  /// Inputs, buttons, post photos.
  static const double md = 12;

  /// Cards in the feed and people lists.
  static const double lg = 16;

  /// Bottom-sheet top corners, profile-strength card.
  static const double xl = 24;

  /// Chips, avatars, the centre Post button, badges.
  static const double pill = 999;

  // ---- Artboard radii outside the token scale (design is the source of
  // truth; token values above are unchanged). ----

  /// Comment bubble top-left corner.
  static const double commentTail = 4;

  /// Checkbox.
  static const double checkbox = 6;

  /// Selected segment inside a segmented control.
  static const double segment = 9;

  /// OTP digit boxes.
  static const double otpBox = 10;

  /// Role and age-group option cards.
  static const double optionCard = 14;

  /// Profile-strength card.
  static const double strengthCard = 20;
}
