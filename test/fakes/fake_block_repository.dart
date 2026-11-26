import 'dart:async';

import 'package:asatiza/data/repositories/block_repository.dart';

/// Test-only in-memory [BlockRepository] (the app uses
/// `SupabaseBlockRepository`; this is the block code that lived in
/// `MockSafetyRepository` before PHASE_007).
class FakeBlockRepository implements BlockRepository {
  FakeBlockRepository({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;

  /// blocker id → blocked id → when.
  final Map<String, Map<String, DateTime>> _blocks =
      <String, Map<String, DateTime>>{};
  final StreamController<void> _changes = StreamController<void>.broadcast();

  /// When set, every call throws it (failure tests).
  Object? failWith;

  /// Fires after any block change.
  Stream<void> get changes => _changes.stream;

  /// True when either user blocked the other.
  bool blockedEitherWay(String a, String b) =>
      (_blocks[a]?.containsKey(b) ?? false) ||
      (_blocks[b]?.containsKey(a) ?? false);

  void _maybeFail() {
    final failure = failWith;
    if (failure != null) {
      throw failure;
    }
  }

  @override
  Future<void> blockUser({
    required String blockerId,
    required String blockedId,
  }) async {
    _maybeFail();
    if (blockerId == blockedId) {
      return;
    }
    final blocked = _blocks.putIfAbsent(blockerId, () => <String, DateTime>{});
    if (!blocked.containsKey(blockedId)) {
      blocked[blockedId] = _clock();
      _changes.add(null);
    }
  }

  @override
  Stream<Set<String>> watchBlockedIds(String userId) =>
      _watch(() => Set<String>.of(_blocks[userId]?.keys ?? const <String>[]));

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
    _maybeFail();
    if (_blocks[blockerId]?.remove(blockedId) != null) {
      _changes.add(null);
    }
  }

  /// Deletes [userId]'s blocks in both directions (account deletion).
  void removeUser(String userId) {
    _blocks.remove(userId);
    for (final b in _blocks.values) {
      b.remove(userId);
    }
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
