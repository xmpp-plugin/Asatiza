import '../models/enums/user_role.dart';
import '../models/profile.dart';

/// Sign up, email code, log in and password reset.
///
/// Provisional contract (PHASE_002): the Supabase phase must honour it.
/// Every method throws only [Failure] subtypes from `core/errors`.
abstract interface class AuthRepository {
  /// Starts sign-up and sends a 6-digit code to [email].
  ///
  /// Throws `ValidationFailure` with `invalidEmail`, `passwordTooShort` or
  /// `emailAlreadyRegistered`. No account exists until [verifySignUpCode].
  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
  });

  /// Confirms the sign-up code, creates the account and signs it in.
  ///
  /// Returns the new user's [Profile]. Throws `ValidationFailure(invalidCode)`.
  Future<Profile> verifySignUpCode({
    required String email,
    required String code,
  });

  /// Sends a fresh code to [email] (sign-up or password reset).
  Future<void> resendCode({required String email});

  /// Signs in with email + password and returns the user's [Profile].
  ///
  /// Throws `ValidationFailure` with `invalidEmail`, `passwordTooShort` or
  /// `wrongCredentials`.
  Future<Profile> logIn({required String email, required String password});

  /// Sends a password-reset code to [email]. Throws `ValidationFailure(invalidEmail)`.
  Future<void> requestPasswordReset({required String email});

  /// Checks the reset code. Throws `ValidationFailure(invalidCode)`.
  Future<void> verifyResetCode({required String email, required String code});

  /// Sets the new password after a verified reset code, signs the user in
  /// and returns the [Profile]. Throws `ValidationFailure` with
  /// `passwordTooShort` or `passwordsDoNotMatch`.
  Future<Profile> setNewPassword({
    required String email,
    required String password,
    required String confirmation,
  });

  /// Ends the session. Never throws.
  Future<void> logOut();
}
