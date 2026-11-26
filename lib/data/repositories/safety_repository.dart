import '../models/enums/report_reason.dart';

/// Reports (blocks live in `BlockRepository`, PHASE_007).
///
/// Provisional contract (PHASE_002); reports become real with the Feed phase
/// (they need real posts). Throws only `Failure` subtypes.
abstract interface class SafetyRepository {
  /// Files an anonymous report on a post. Throws `NotFoundFailure`.
  Future<void> reportPost({
    required String postId,
    required String reporterId,
    required ReportReason reason,
  });
}
