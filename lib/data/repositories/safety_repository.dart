import '../models/enums/report_reason.dart';

/// Reports and blocks.
///
/// Provisional contract (PHASE_002). Throws only `Failure` subtypes.
abstract interface class SafetyRepository {
  /// Files an anonymous report on a post. Throws `NotFoundFailure`.
  Future<void> reportPost({
    required String postId,
    required String reporterId,
    required ReportReason reason,
  });

  /// Blocks [blockedId] for [blockerId]. Blocking twice is a no-op.
  Future<void> blockUser({
    required String blockerId,
    required String blockedId,
  });

  /// Emits the ids [userId] has blocked, now and after every change.
  Stream<Set<String>> watchBlockedIds(String userId);
}
