import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/failures.dart';
import '../../models/enums/report_reason.dart';
import '../safety_repository.dart';
import 'supabase_failure_mapper.dart';

/// [SafetyRepository] on `public.reports` through the `report_content`
/// database function (`supabase/migrations/20261202120000_feed.sql`): one
/// report per person and item; 3 different reporters hide a post.
class SupabaseSafetyRepository implements SafetyRepository {
  SupabaseSafetyRepository(
    this._client, {
    SupabaseFailureMapper failures = const SupabaseFailureMapper(),
  }) : _failures = failures;

  final SupabaseClient _client;
  final SupabaseFailureMapper _failures;

  /// `hateOrHarassment` → `hate_or_harassment`.
  static String reasonToDb(ReportReason reason) => reason.name.replaceAllMapped(
    RegExp('[A-Z]'),
    (m) => '_${m[0]!.toLowerCase()}',
  );

  Future<void> _report(
    String type,
    String id,
    String reporterId,
    ReportReason reason,
  ) async {
    if (reporterId != _client.auth.currentUser?.id) {
      throw const NotFoundFailure();
    }
    try {
      await _client.rpc<void>(
        'report_content',
        params: <String, dynamic>{
          'p_type': type,
          'p_id': id,
          'p_reason': reasonToDb(reason),
        },
      );
    } on PostgrestException catch (error) {
      throw error.message == 'not_found'
          ? const NotFoundFailure()
          : _failures.map(error);
    } catch (error) {
      throw _failures.map(error);
    }
  }

  @override
  Future<void> reportPost({
    required String postId,
    required String reporterId,
    required ReportReason reason,
  }) => _report('post', postId, reporterId, reason);

  @override
  Future<void> reportComment({
    required String commentId,
    required String reporterId,
    required ReportReason reason,
  }) => _report('comment', commentId, reporterId, reason);
}
