import '../models/connection.dart';

/// Connection requests (plan sections 4, 7). The Supabase implementation
/// enforces every rule in the database (PHASE_008). Throws only `Failure`
/// types.
abstract interface class ConnectionRepository {
  /// Pending and accepted connections involving [userId] (the signed-in
  /// user), newest first. Emits now and again after every change made
  /// through this repository.
  Stream<List<Connection>> watchConnections(String userId);

  /// Sends a request from [requesterId] to [receiverId].
  ///
  /// Throws `ValidationFailure` with:
  /// - `connectNoteTooLong` when [note] is over 200 characters;
  /// - `profileIncomplete` when the sender's profile is not active;
  /// - `receiverNotActive` when the receiver's profile is not active;
  /// - `alreadyConnected` when a pending or accepted connection exists
  ///   (either direction), or the request is to yourself;
  /// - `declinedRecently` when the receiver declined this requester less
  ///   than 3 days ago;
  /// - `requestLimitReached` after 10 requests in the last 24 hours.
  ///
  /// Throws `NotFoundFailure` when the receiver does not exist or a block
  /// stands between the two.
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

  /// Accepted connections of [userId] (shown on their profile); 0 when that
  /// profile is hidden from the viewer by a block.
  Future<int> connectionCount(String userId);
}
