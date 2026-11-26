/// Someone the user blocked, and when.
typedef BlockedUser = ({String userId, DateTime blockedAt});

/// Blocks (plan section 9: blocked users can't see your profile or posts,
/// can't message you, and disappear from your lists).
///
/// Throws only `Failure` subtypes.
abstract interface class BlockRepository {
  /// Blocks [blockedId] for [blockerId]. Blocking twice, or blocking
  /// yourself, is a no-op.
  Future<void> blockUser({
    required String blockerId,
    required String blockedId,
  });

  /// Emits the ids [userId] has blocked now, and again after every block or
  /// unblock made through this repository.
  Stream<Set<String>> watchBlockedIds(String userId);

  /// People [userId] blocked, newest first; emits like [watchBlockedIds].
  Stream<List<BlockedUser>> watchBlockedUsers(String userId);

  /// Removes the block. Unblocking someone who is not blocked is a no-op.
  Future<void> unblockUser({
    required String blockerId,
    required String blockedId,
  });
}
