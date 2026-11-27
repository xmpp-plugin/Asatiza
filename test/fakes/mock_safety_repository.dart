import 'package:asatiza/data/models/enums/report_reason.dart';
import 'package:asatiza/data/repositories/safety_repository.dart';

/// In-memory [SafetyRepository] (reports only). Reports are kept for the
/// session; they become real with the Feed phase. Blocks are real since
/// PHASE_007 (`SupabaseBlockRepository`).
// Test-only fake: the app uses the Supabase implementation (moved from
// `lib/` in PHASE_010).
class MockSafetyRepository implements SafetyRepository {
  final List<({String postId, String reporterId, ReportReason reason})>
  _reports = <({String postId, String reporterId, ReportReason reason})>[];

  /// Mock-layer only: number of reports filed this session.
  int get reportCount => _reports.length;

  @override
  Future<void> reportPost({
    required String postId,
    required String reporterId,
    required ReportReason reason,
  }) async {
    _reports.add((postId: postId, reporterId: reporterId, reason: reason));
  }

  @override
  Future<void> reportComment({
    required String commentId,
    required String reporterId,
    required ReportReason reason,
  }) async {
    _reports.add((postId: commentId, reporterId: reporterId, reason: reason));
  }

  /// Deletes [userId]'s reports (mock account deletion).
  void removeUser(String userId) {
    _reports.removeWhere((r) => r.reporterId == userId);
  }
}
