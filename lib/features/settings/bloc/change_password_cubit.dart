import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/failures.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../auth/logic/password_rules.dart';
import 'change_password_state.dart';

/// Change password with the three live rules from artboard 21a.
class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  ChangePasswordCubit(this._auth) : super(const ChangePasswordState());

  final AuthRepository _auth;
  static const PasswordRules _rules = PasswordRules();

  bool get hasMinLength => _rules.hasMinLength(state.next);
  bool get differs => _rules.differs(state.current, state.next);
  bool get matches => _rules.matches(state.next, state.confirmation);
  bool get canSave =>
      state.current.isNotEmpty && hasMinLength && differs && matches;

  void currentChanged(String v) =>
      emit(state.copyWith(current: v, error: () => null));
  void nextChanged(String v) =>
      emit(state.copyWith(next: v, error: () => null));
  void confirmationChanged(String v) =>
      emit(state.copyWith(confirmation: v, error: () => null));

  Future<void> save() async {
    if (state.saving || !canSave) {
      return;
    }
    emit(state.copyWith(saving: true));
    try {
      await _auth.changePassword(
        currentPassword: state.current,
        newPassword: state.next,
        confirmation: state.confirmation,
      );
      emit(state.copyWith(saving: false, saved: true));
    } on ValidationFailure catch (f) {
      emit(state.copyWith(saving: false, error: () => f.reason));
    } on Failure {
      emit(state.copyWith(saving: false));
    }
  }
}
