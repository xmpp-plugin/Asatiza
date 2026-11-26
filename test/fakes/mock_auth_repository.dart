import 'package:asatiza/core/errors/failures.dart';
import 'package:asatiza/features/auth/logic/otp_rules.dart';
import 'package:asatiza/features/auth/logic/password_rules.dart';
import 'package:asatiza/data/models/enums/user_role.dart';
import 'package:asatiza/data/models/profile.dart';
import 'package:asatiza/data/models/student_details.dart';
import 'package:asatiza/data/models/teacher_details.dart';
import 'package:asatiza/data/repositories/auth_repository.dart';
import 'package:asatiza/data/repositories/mock/mock_profile_repository.dart';

/// In-memory [AuthRepository]. Any valid email + 8-character password signs
/// in; any 6 digits are a valid code. Known emails (the two mock accounts
/// and anyone who signed up) get their own profile; other emails sign in as
/// a new student.
// Test-only fake: the app uses the Supabase implementation (moved from
// `lib/` in PHASE_007).
class MockAuthRepository implements AuthRepository {
  MockAuthRepository(this._profiles, {void Function(String userId)? onDelete})
    : _onDelete = onDelete;

  final MockProfileRepository _profiles;

  /// Clears the other mock stores when an account is deleted (wired in
  /// `main.dart`).
  final void Function(String userId)? _onDelete;
  final Map<String, ({String fullName, UserRole role})> _pendingSignUps =
      <String, ({String fullName, UserRole role})>{};
  final Set<String> _verifiedResets = <String>{};
  int _nextId = 1000;

  static const PasswordRules _passwords = PasswordRules();
  static const OtpRules _otp = OtpRules();

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

  String _key(String email) => email.trim().toLowerCase();

  Profile _create({
    required String email,
    required String fullName,
    required UserRole role,
  }) {
    _nextId++;
    final profile = Profile(
      id: '00000000-0000-4000-9000-${_nextId.toString().padLeft(12, '0')}',
      role: role,
      fullName: fullName,
      email: email.trim(),
      createdAt: DateTime.now(),
      teacherDetails: role == UserRole.teacher ? const TeacherDetails() : null,
      studentDetails: role == UserRole.student ? const StudentDetails() : null,
    );
    _profiles.insert(profile);
    return profile;
  }

  /// "omar.farooq@…" → "Omar Farooq".
  String _nameFromEmail(String email) => email
      .split('@')
      .first
      .split(RegExp(r'[._\-]+'))
      .where((w) => w.isNotEmpty)
      .map((w) => w[0].toUpperCase() + w.substring(1))
      .join(' ');

  Profile _profileFor(String email) =>
      _profiles.findByEmail(email) ??
      _create(
        email: email,
        fullName: _nameFromEmail(email),
        role: UserRole.student,
      );

  @override
  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    _checkEmail(email);
    _checkPassword(password);
    if (_profiles.findByEmail(email) != null) {
      throw const ValidationFailure(ValidationReason.emailAlreadyRegistered);
    }
    _pendingSignUps[_key(email)] = (fullName: fullName.trim(), role: role);
  }

  @override
  Future<Profile> verifySignUpCode({
    required String email,
    required String code,
  }) async {
    _checkCode(code);
    final pending = _pendingSignUps.remove(_key(email));
    if (pending == null) {
      return _profileFor(email);
    }
    return _create(
      email: email,
      fullName: pending.fullName,
      role: pending.role,
    );
  }

  @override
  Future<void> resendCode({required String email}) async => _checkEmail(email);

  @override
  Future<Profile> logIn({
    required String email,
    required String password,
  }) async {
    _checkEmail(email);
    _checkPassword(password);
    return _profileFor(email);
  }

  @override
  Future<void> requestPasswordReset({required String email}) async =>
      _checkEmail(email);

  @override
  Future<void> verifyResetCode({
    required String email,
    required String code,
  }) async {
    _checkCode(code);
    _verifiedResets.add(_key(email));
  }

  @override
  Future<Profile> setNewPassword({
    required String email,
    required String password,
    required String confirmation,
  }) async {
    _checkPassword(password);
    if (!_passwords.matches(password, confirmation)) {
      throw const ValidationFailure(ValidationReason.passwordsDoNotMatch);
    }
    _verifiedResets.remove(_key(email));
    return _profileFor(email);
  }

  @override
  Future<Profile?> restoreSession() async => null;

  @override
  Future<void> logOut() async {}

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmation,
  }) async {
    // Mock: any current password of 8+ characters is accepted.
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
  }

  @override
  Future<void> deleteAccount(String userId) async {
    await _profiles.getProfile(userId);
    _onDelete?.call(userId);
    _profiles.remove(userId);
  }
}
