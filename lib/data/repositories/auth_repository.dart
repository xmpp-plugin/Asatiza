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
  /// Throws `ValidationFailure` with `invalidEmail`, `passwordTooShort`,
  /// `wrongCredentials` or `emailNotConfirmed` (sign-up code never entered;
  /// the caller sends a fresh code with [resendCode]), or `NetworkFailure`.
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

  /// The user of a session kept from an earlier launch, or null when
  /// signed out. Mock: always null (every launch starts signed out).
  /// Throws `NetworkFailure` or `UnexpectedFailure` when a stored session
  /// exists but its profile cannot be loaded.
  Future<Profile?> restoreSession();

  /// Ends the session. Never throws.
  Future<void> logOut();

  /// Changes the signed-in user's password; the session stays signed in.
  /// Throws `ValidationFailure` with `wrongCredentials` (current password
  /// wrong), `passwordTooShort`, `passwordUnchanged` or
  /// `passwordsDoNotMatch`.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmation,
  });

  /// Permanently deletes [userId]'s account and data (profile, photo,
  /// certificates, posts, comments, likes, chats, connections,
  /// notifications), then signs out.
  Future<void> deleteAccount(String userId);
}
