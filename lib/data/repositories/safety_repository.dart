import '../models/enums/report_reason.dart';

/// Reports of posts and comments (blocks live in `BlockRepository`,
/// PHASE_007). Reporting the same item twice does nothing; a post reported
/// by 3 different people is hidden automatically (PHASE_010). Throws only
/// `Failure` subtypes.
abstract interface class SafetyRepository {
  /// Files an anonymous report on a post. Throws `NotFoundFailure`.
  Future<void> reportPost({
    required String postId,
    required String reporterId,
    required ReportReason reason,
  });

  /// Files an anonymous report on a comment. Throws `NotFoundFailure`.
  Future<void> reportComment({
    required String commentId,
    required String reporterId,
    required ReportReason reason,
  });
}
