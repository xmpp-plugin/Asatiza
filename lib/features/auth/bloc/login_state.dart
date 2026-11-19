import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../../data/models/profile.dart';
import '../logic/password_rules.dart';

enum LoginStatus { editing, submitting, signedIn }

class LoginState extends Equatable {
  const LoginState({
    this.email = '',
    this.password = '',
    this.status = LoginStatus.editing,
    this.failure,
    this.user,
  });

  final String email;
  final String password;
  final LoginStatus status;
  final ValidationReason? failure;
  final Profile? user;

  static const PasswordRules _rules = PasswordRules();

  bool get canSubmit =>
      _rules.isValidEmail(email) &&
      _rules.hasMinLength(password) &&
      status != LoginStatus.submitting;

  LoginState copyWith({
    String? email,
    String? password,
    LoginStatus? status,
    ValidationReason? failure,
    bool clearFailure = false,
    Profile? user,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      status: status ?? this.status,
      failure: clearFailure ? null : failure ?? this.failure,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => <Object?>[email, password, status, failure, user];
}
