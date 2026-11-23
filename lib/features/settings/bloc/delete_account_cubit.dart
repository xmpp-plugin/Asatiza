import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/failures.dart';
import '../../../data/repositories/auth_repository.dart';
import 'delete_account_state.dart';

/// Deletes the account once the user ticks the confirmation box.
class DeleteAccountCubit extends Cubit<DeleteAccountState> {
  DeleteAccountCubit(this._auth, {required this.userId})
    : super(const DeleteAccountState());

  final AuthRepository _auth;
  final String userId;

  void confirmedChanged(bool value) =>
      emit(state.copyWith(confirmed: value, failed: false));

  Future<void> delete() async {
    if (!state.confirmed || state.deleting) {
      return;
    }
    emit(state.copyWith(deleting: true));
    try {
      await _auth.deleteAccount(userId);
      emit(state.copyWith(deleting: false, deleted: true));
    } on Failure {
      emit(state.copyWith(deleting: false, failed: true));
    }
  }
}
