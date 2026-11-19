import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../../data/models/enums/user_role.dart';
import '../logic/password_rules.dart';

enum SignUpStatus { editing, submitting, codeSent }

class SignUpState extends Equatable {
  const SignUpState({
    this.role = UserRole.student,
    this.fullName = '',
    this.email = '',
    this.password = '',
    this.consent = false,
    this.status = SignUpStatus.editing,
    this.failure,
  });

  final UserRole role;
  final String fullName;
  final String email;
  final String password;

  /// "I am 18 or older and agree to the Terms…" (18+ gate).
  final bool consent;
  final SignUpStatus status;
  final ValidationReason? failure;

  static const PasswordRules _rules = PasswordRules();

  bool get passwordLongEnough => _rules.hasMinLength(password);

  bool get canSubmit =>
      fullName.trim().isNotEmpty &&
      _rules.isValidEmail(email) &&
      passwordLongEnough &&
      consent &&
      status != SignUpStatus.submitting;

  SignUpState copyWith({
    UserRole? role,
    String? fullName,
    String? email,
    String? password,
    bool? consent,
    SignUpStatus? status,
    ValidationReason? failure,
    bool clearFailure = false,
  }) {
    return SignUpState(
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      password: password ?? this.password,
      consent: consent ?? this.consent,
      status: status ?? this.status,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    role,
    fullName,
    email,
    password,
    consent,
    status,
    failure,
  ];
}
