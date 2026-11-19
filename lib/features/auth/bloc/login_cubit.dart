import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/failures.dart';
import '../../../data/repositories/auth_repository.dart';
import 'login_state.dart';

/// Email + password log-in (no code at log-in, plan section 4).
class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._auth) : super(const LoginState());

  final AuthRepository _auth;

  void emailChanged(String value) =>
      emit(state.copyWith(email: value, clearFailure: true));
  void passwordChanged(String value) =>
      emit(state.copyWith(password: value, clearFailure: true));

  Future<void> submit() async {
    if (!state.canSubmit) {
      return;
    }
    emit(state.copyWith(status: LoginStatus.submitting, clearFailure: true));
    try {
      final user = await _auth.logIn(
        email: state.email,
        password: state.password,
      );
      emit(state.copyWith(status: LoginStatus.signedIn, user: user));
    } on ValidationFailure catch (f) {
      emit(state.copyWith(status: LoginStatus.editing, failure: f.reason));
    } on Failure {
      emit(state.copyWith(status: LoginStatus.editing));
    }
  }
}
