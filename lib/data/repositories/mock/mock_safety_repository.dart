import 'dart:async';

import '../../models/enums/report_reason.dart';
import '../safety_repository.dart';

/// In-memory [SafetyRepository]. Reports are kept for the session only.
class MockSafetyRepository implements SafetyRepository {
  final List<({String postId, String reporterId, ReportReason reason})>
  _reports = <({String postId, String reporterId, ReportReason reason})>[];
  final Map<String, Set<String>> _blocks = <String, Set<String>>{};
  final StreamController<void> _changes = StreamController<void>.broadcast();

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
  Future<void> blockUser({
    required String blockerId,
    required String blockedId,
  }) async {
    final blocked = _blocks.putIfAbsent(blockerId, () => <String>{});
    if (blocked.add(blockedId)) {
      _changes.add(null);
    }
  }

  @override
  Stream<Set<String>> watchBlockedIds(String userId) =>
      _watch(() => Set<String>.of(_blocks[userId] ?? const <String>{}));

  /// Emits [read] now and after every change; cancelling stops at once.
  Stream<T> _watch<T>(T Function() read) {
    late final StreamController<T> controller;
    StreamSubscription<void>? changes;
    controller = StreamController<T>(
      onListen: () {
        controller.add(read());
        changes = _changes.stream.listen((_) => controller.add(read()));
      },
      onCancel: () => changes?.cancel(),
    );
    return controller.stream;
  }
}
