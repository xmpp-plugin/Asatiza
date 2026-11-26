import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/failures.dart';
import '../../../data/repositories/connection_repository.dart';
import 'connect_request_state.dart';

/// Sends a connection request with an optional note (Connect sheet).
class ConnectRequestCubit extends Cubit<ConnectRequestState> {
  ConnectRequestCubit(
    this._connections, {
    required this.requesterId,
    required this.receiverId,
  }) : super(const ConnectRequestState());

  final ConnectionRepository _connections;
  final String requesterId;
  final String receiverId;

  void noteChanged(String note) =>
      emit(state.copyWith(note: note, error: () => null));

  Future<void> send() async {
    if (state.sending || state.sent) {
      return;
    }
    emit(state.copyWith(sending: true, error: () => null));
    try {
      await _connections.sendRequest(
        requesterId: requesterId,
        receiverId: receiverId,
        note: state.note,
      );
      emit(state.copyWith(sending: false, sent: true));
    } on ValidationFailure catch (f) {
      emit(state.copyWith(sending: false, error: () => f.reason));
    } on Failure catch (f) {
      // Offline, server error, or the person is no longer available.
      emit(state.copyWith(sending: false, error: () => f.displayReason));
    }
  }
}
