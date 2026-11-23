import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';

/// Connect sheet: the optional note and the send status.
class ConnectRequestState extends Equatable {
  const ConnectRequestState({
    this.note = '',
    this.sending = false,
    this.sent = false,
    this.error,
  });

  final String note;
  final bool sending;
  final bool sent;

  /// Why the last send failed, if it did.
  final ValidationReason? error;

  ConnectRequestState copyWith({
    String? note,
    bool? sending,
    bool? sent,
    ValidationReason? Function()? error,
  }) {
    return ConnectRequestState(
      note: note ?? this.note,
      sending: sending ?? this.sending,
      sent: sent ?? this.sent,
      error: error != null ? error() : this.error,
    );
  }

  @override
  List<Object?> get props => <Object?>[note, sending, sent, error];
}
