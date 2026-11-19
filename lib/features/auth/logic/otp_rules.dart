/// Email-code rules (plan section 4).
class OtpRules {
  const OtpRules();

  static const int length = 6;

  /// "Resend code" unlocks after this many seconds.
  static const int resendAfterSeconds = 60;

  static final RegExp _digits = RegExp(r'^\d+$');

  bool isComplete(String code) =>
      code.length == length && _digits.hasMatch(code);

  /// Keeps digits only, at most [length] of them.
  String sanitize(String input) {
    final digits = input.replaceAll(RegExp(r'\D'), '');
    return digits.length > length ? digits.substring(0, length) : digits;
  }
}
