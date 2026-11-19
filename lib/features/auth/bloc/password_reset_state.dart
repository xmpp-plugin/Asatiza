import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../../data/models/profile.dart';
import '../logic/password_rules.dart';

enum PasswordResetStatus { editing, submitting, codeSent, passwordSaved }

/// Forgot-password email step and new-password step.
class PasswordResetState extends Equatable {
  const PasswordResetState({
    this.email = '',
    this.password = '',
    this.confirmation = '',
    this.status = PasswordResetStatus.editing,
    this.failure,
    this.user,
  });

  final String email;
  final String password;
  final String confirmation;
  final PasswordResetStatus status;
  final ValidationReason? failure;

  /// Signed-in user after the new password is saved.
  final Profile? user;

  static const PasswordRules _rules = PasswordRules();

  bool get emailValid => _rules.isValidEmail(email);
  bool get passwordLongEnough => _rules.hasMinLength(password);
  bool get passwordsMatch => _rules.matches(password, confirmation);
  bool get canSave =>
      passwordLongEnough &&
      passwordsMatch &&
      status != PasswordResetStatus.submitting;

  PasswordResetState copyWith({
    String? email,
    String? password,
    String? confirmation,
    PasswordResetStatus? status,
    ValidationReason? failure,
    bool clearFailure = false,
    Profile? user,
  }) {
    return PasswordResetState(
      email: email ?? this.email,
      password: password ?? this.password,
      confirmation: confirmation ?? this.confirmation,
      status: status ?? this.status,
      failure: clearFailure ? null : failure ?? this.failure,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    email,
    password,
    confirmation,
    status,
    failure,
    user,
  ];
}
