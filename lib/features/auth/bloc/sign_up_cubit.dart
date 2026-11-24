import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/failures.dart';
import '../../../data/models/enums/user_role.dart';
import '../../../data/repositories/auth_repository.dart';
import 'sign_up_state.dart';

/// Sign-up form. On success the screen opens the email-code step.
class SignUpCubit extends Cubit<SignUpState> {
  SignUpCubit(this._auth) : super(const SignUpState());

  final AuthRepository _auth;

  void roleChanged(UserRole role) => emit(state.copyWith(role: role));
  void nameChanged(String value) =>
      emit(state.copyWith(fullName: value, clearFailure: true));
  void emailChanged(String value) =>
      emit(state.copyWith(email: value, clearFailure: true));
  void passwordChanged(String value) =>
      emit(state.copyWith(password: value, clearFailure: true));
  void consentChanged(bool value) => emit(state.copyWith(consent: value));

  /// Back to editing after the code screen was left ("Wrong email?").
  void resumeEditing() => emit(state.copyWith(status: SignUpStatus.editing));

  Future<void> submit() async {
    if (!state.canSubmit) {
      return;
    }
    emit(state.copyWith(status: SignUpStatus.submitting, clearFailure: true));
    try {
      await _auth.signUp(
        fullName: state.fullName,
        email: state.email,
        password: state.password,
        role: state.role,
      );
      emit(state.copyWith(status: SignUpStatus.codeSent));
    } on ValidationFailure catch (f) {
      emit(state.copyWith(status: SignUpStatus.editing, failure: f.reason));
    } on Failure catch (f) {
      emit(
        state.copyWith(status: SignUpStatus.editing, failure: f.displayReason),
      );
    }
  }
}
