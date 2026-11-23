import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/failures.dart';
import '../../../features/auth/logic/otp_rules.dart';
import '../../../features/auth/logic/password_rules.dart';
import '../../models/enums/user_role.dart';
import '../../models/profile.dart';
import '../auth_repository.dart';
import '../profile_repository.dart';
import 'supabase_failure_mapper.dart';

/// [AuthRepository] on Supabase Auth with 6-digit email codes (the
/// "Confirm signup" and "Reset password" templates send `{{ .Token }}`).
///
/// Sign-up stores `full_name` and `role` in the user metadata; the
/// `handle_new_user` trigger creates the profile rows from them. Account
/// deletion calls the `delete_my_account()` database function.
class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(
    this._client,
    this._profiles, {
    SupabaseFailureMapper failures = const SupabaseFailureMapper(),
  }) : _failures = failures;

  final SupabaseClient _client;
  final ProfileRepository _profiles;
  final SupabaseFailureMapper _failures;

  /// Emails with a password reset in progress, so [resendCode] sends the
  /// right kind of code.
  final Set<String> _resetEmails = <String>{};

  static const PasswordRules _passwords = PasswordRules();
  static const OtpRules _otp = OtpRules();

  GoTrueClient get _auth => _client.auth;

  Future<T> _guard<T>(Future<T> Function() run) async {
    try {
      return await run();
    } catch (error) {
      throw _failures.map(error);
    }
  }

  String _key(String email) => email.trim().toLowerCase();

  void _checkEmail(String email) {
    if (!_passwords.isValidEmail(email)) {
      throw const ValidationFailure(ValidationReason.invalidEmail);
    }
  }

  void _checkPassword(String password) {
    if (!_passwords.hasMinLength(password)) {
      throw const ValidationFailure(ValidationReason.passwordTooShort);
    }
  }

  void _checkCode(String code) {
    if (!_otp.isComplete(code)) {
      throw const ValidationFailure(ValidationReason.invalidCode);
    }
  }

  Future<Profile> _signedInProfile() {
    final user = _auth.currentUser;
    if (user == null) {
      throw const UnexpectedFailure();
    }
    return _profiles.getProfile(user.id);
  }

  @override
  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
  }) => _guard(() async {
    _checkEmail(email);
    _checkPassword(password);
    final response = await _auth.signUp(
      email: email.trim(),
      password: password,
      data: <String, dynamic>{'full_name': fullName.trim(), 'role': role.name},
    );
    // With email confirmation on, a taken email returns a user with no
    // identities instead of an error.
    final identities = response.user?.identities;
    if (identities != null && identities.isEmpty) {
      throw const ValidationFailure(ValidationReason.emailAlreadyRegistered);
    }
    _resetEmails.remove(_key(email));
  });

  @override
  Future<Profile> verifySignUpCode({
    required String email,
    required String code,
  }) => _guard(() async {
    _checkCode(code);
    await _auth.verifyOTP(
      type: OtpType.signup,
      email: email.trim(),
      token: code,
    );
    return _signedInProfile();
  });

  @override
  Future<void> resendCode({required String email}) => _guard(() async {
    _checkEmail(email);
    if (_resetEmails.contains(_key(email))) {
      await _auth.resetPasswordForEmail(email.trim());
    } else {
      await _auth.resend(type: OtpType.signup, email: email.trim());
    }
  });

  @override
  Future<Profile> logIn({required String email, required String password}) =>
      _guard(() async {
        _checkEmail(email);
        _checkPassword(password);
        await _auth.signInWithPassword(email: email.trim(), password: password);
        return _signedInProfile();
      });

  @override
  Future<void> requestPasswordReset({required String email}) =>
      _guard(() async {
        _checkEmail(email);
        await _auth.resetPasswordForEmail(email.trim());
        _resetEmails.add(_key(email));
      });

  @override
  Future<void> verifyResetCode({required String email, required String code}) =>
      _guard(() async {
        _checkCode(code);
        await _auth.verifyOTP(
          type: OtpType.recovery,
          email: email.trim(),
          token: code,
        );
      });

  @override
  Future<Profile> setNewPassword({
    required String email,
    required String password,
    required String confirmation,
  }) => _guard(() async {
    _checkPassword(password);
    if (!_passwords.matches(password, confirmation)) {
      throw const ValidationFailure(ValidationReason.passwordsDoNotMatch);
    }
    await _auth.updateUser(UserAttributes(password: password));
    _resetEmails.remove(_key(email));
    return _signedInProfile();
  });

  @override
  Future<Profile?> restoreSession() => _guard(() async {
    final user = _auth.currentUser;
    if (_auth.currentSession == null || user == null) {
      return null;
    }
    try {
      return await _profiles.getProfile(user.id);
    } on NotFoundFailure {
      // The account was deleted elsewhere: drop the stale session.
      await _signOutQuietly();
      return null;
    }
  });

  @override
  Future<void> logOut() async {
    _resetEmails.clear();
    await _signOutQuietly();
  }

  Future<void> _signOutQuietly() async {
    try {
      await _auth.signOut();
    } catch (_) {
      // Never throws: the local session is cleared even when offline.
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmation,
  }) => _guard(() async {
    final email = _auth.currentUser?.email;
    if (email == null) {
      throw const UnexpectedFailure();
    }
    if (!_passwords.hasMinLength(currentPassword)) {
      throw const ValidationFailure(ValidationReason.wrongCredentials);
    }
    _checkPassword(newPassword);
    if (!_passwords.differs(currentPassword, newPassword)) {
      throw const ValidationFailure(ValidationReason.passwordUnchanged);
    }
    if (!_passwords.matches(newPassword, confirmation)) {
      throw const ValidationFailure(ValidationReason.passwordsDoNotMatch);
    }
    // Supabase does not check the current password on update: confirm it
    // by signing in again (same user, fresh session).
    await _auth.signInWithPassword(email: email, password: currentPassword);
    await _auth.updateUser(UserAttributes(password: newPassword));
  });

  @override
  Future<void> deleteAccount(String userId) => _guard(() async {
    if (_auth.currentUser?.id != userId) {
      throw const NotFoundFailure();
    }
    await _client.rpc<void>('delete_my_account');
    await _signOutQuietly();
  });
}
