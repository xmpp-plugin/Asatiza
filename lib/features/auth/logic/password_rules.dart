/// Password and email rules used by sign-up, log-in and password reset.
class PasswordRules {
  const PasswordRules();

  static const int minLength = 8;

  static final RegExp _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  bool hasMinLength(String password) => password.length >= minLength;

  bool matches(String password, String confirmation) =>
      password.isNotEmpty && password == confirmation;

  bool isValidEmail(String email) => _email.hasMatch(email.trim());
}
