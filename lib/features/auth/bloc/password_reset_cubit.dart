import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/failures.dart';
import '../../../data/repositories/auth_repository.dart';
import 'password_reset_state.dart';

/// Forgot password: step 1 sends the code, step 3 saves the new password
/// and signs in. (Step 2, the code, uses [OtpCubit].)
class PasswordResetCubit extends Cubit<PasswordResetState> {
  PasswordResetCubit(this._auth, {String email = ''})
    : super(PasswordResetState(email: email));

  final AuthRepository _auth;

  void emailChanged(String value) =>
      emit(state.copyWith(email: value, clearFailure: true));
  void passwordChanged(String value) =>
      emit(state.copyWith(password: value, clearFailure: true));
  void confirmationChanged(String value) =>
      emit(state.copyWith(confirmation: value, clearFailure: true));

  /// Back to the email field ("Wrong email? Change it").
  void editEmail() => emit(state.copyWith(status: PasswordResetStatus.editing));

  Future<void> sendCode() async {
    if (!state.emailValid || state.status == PasswordResetStatus.submitting) {
      return;
    }
    emit(
      state.copyWith(
        status: PasswordResetStatus.submitting,
        clearFailure: true,
      ),
    );
    try {
      await _auth.requestPasswordReset(email: state.email);
      emit(state.copyWith(status: PasswordResetStatus.codeSent));
    } on ValidationFailure catch (f) {
      emit(
        state.copyWith(status: PasswordResetStatus.editing, failure: f.reason),
      );
    } on Failure catch (f) {
      emit(
        state.copyWith(
          status: PasswordResetStatus.editing,
          failure: f.displayReason,
        ),
      );
    }
  }

  Future<void> savePassword() async {
    if (!state.canSave) {
      return;
    }
    emit(
      state.copyWith(
        status: PasswordResetStatus.submitting,
        clearFailure: true,
      ),
    );
    try {
      final user = await _auth.setNewPassword(
        email: state.email,
        password: state.password,
        confirmation: state.confirmation,
      );
      emit(
        state.copyWith(status: PasswordResetStatus.passwordSaved, user: user),
      );
    } on ValidationFailure catch (f) {
      emit(
        state.copyWith(status: PasswordResetStatus.editing, failure: f.reason),
      );
    } on Failure catch (f) {
      emit(
        state.copyWith(
          status: PasswordResetStatus.editing,
          failure: f.displayReason,
        ),
      );
    }
  }
}
