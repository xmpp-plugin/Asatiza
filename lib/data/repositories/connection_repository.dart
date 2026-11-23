import '../models/connection.dart';

/// Provisional contract for connection requests (plan section 4). Throws only
/// `Failure` types.
abstract interface class ConnectionRepository {
  /// Pending and accepted connections involving [userId], newest first.
  /// Emits again on every change.
  Stream<List<Connection>> watchConnections(String userId);

  /// Sends a request from [requesterId] to [receiverId].
  ///
  /// Throws `ValidationFailure` with:
  /// - `connectNoteTooLong` when [note] is over 200 characters;
  /// - `profileIncomplete` when the sender's profile is under 60 %;
  /// - `alreadyConnected` when a pending or accepted connection exists.
  ///
  /// Throws `NotFoundFailure` when either profile does not exist.
  Future<Connection> sendRequest({
    required String requesterId,
    required String receiverId,
    String? note,
  });

  /// The receiver accepts or declines a pending request. Throws
  /// `NotFoundFailure` when [connectionId] is not a pending request to
  /// [userId].
  Future<void> respond({
    required String connectionId,
    required String userId,
    required bool accept,
  });

  /// Removes an accepted connection or cancels a sent request. Throws
  /// `NotFoundFailure` when [userId] is not part of [connectionId].
  Future<void> remove({required String connectionId, required String userId});
}
