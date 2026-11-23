import 'dart:async';

import '../../models/enums/report_reason.dart';
import '../safety_repository.dart';

/// In-memory [SafetyRepository]. Reports are kept for the session only.
class MockSafetyRepository implements SafetyRepository {
  final List<({String postId, String reporterId, ReportReason reason})>
  _reports = <({String postId, String reporterId, ReportReason reason})>[];
  MockSafetyRepository({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;

  /// blocker id → blocked id → when.
  final Map<String, Map<String, DateTime>> _blocks =
      <String, Map<String, DateTime>>{};
  final StreamController<void> _changes = StreamController<void>.broadcast();

  /// Mock-layer only: number of reports filed this session.
  int get reportCount => _reports.length;

  /// Fires after any block change (mock helper).
  Stream<void> get changes => _changes.stream;

  /// True when either user blocked the other (mock helper).
  bool blockedEitherWay(String a, String b) =>
      (_blocks[a]?.containsKey(b) ?? false) ||
      (_blocks[b]?.containsKey(a) ?? false);

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
    final blocked = _blocks.putIfAbsent(blockerId, () => <String, DateTime>{});
    if (!blocked.containsKey(blockedId)) {
      blocked[blockedId] = _clock();
      _changes.add(null);
    }
  }

  @override
  Stream<Set<String>> watchBlockedIds(String userId) =>
      _watch(() => Set<String>.of(_blocks[userId]?.keys ?? const <String>[]));

  /// Emits [read] now and after every change; cancelling stops at once.
  @override
  Stream<List<BlockedUser>> watchBlockedUsers(String userId) => _watch(() {
    final list = <BlockedUser>[
      for (final e in (_blocks[userId] ?? const <String, DateTime>{}).entries)
        (userId: e.key, blockedAt: e.value),
    ]..sort((a, b) => b.blockedAt.compareTo(a.blockedAt));
    return list;
  });

  @override
  Future<void> unblockUser({
    required String blockerId,
    required String blockedId,
  }) async {
    if (_blocks[blockerId]?.remove(blockedId) != null) {
      _changes.add(null);
    }
  }

  /// Deletes [userId]'s blocks and reports (mock account deletion).
  void removeUser(String userId) {
    _blocks.remove(userId);
    for (final b in _blocks.values) {
      b.remove(userId);
    }
    _reports.removeWhere((r) => r.reporterId == userId);
    _changes.add(null);
  }

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
