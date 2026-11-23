import 'dart:async';

import '../../../core/errors/failures.dart';
import '../../../core/logic/discover_visibility_rules.dart';
import '../../../features/connections/logic/connect_note_rules.dart';
import '../../mock/mock_connections.dart';
import '../../models/connection.dart';
import '../../models/enums/connection_status.dart';
import '../connection_repository.dart';
import 'mock_profile_repository.dart';

/// In-memory [ConnectionRepository] (resets on restart).
class MockConnectionRepository implements ConnectionRepository {
  MockConnectionRepository(this._profiles, {DateTime? now}) : _now = now {
    for (final c in buildMockConnections(now ?? DateTime.now())) {
      _connections[c.id] = c;
    }
  }

  final MockProfileRepository _profiles;
  final DateTime? _now;
  final Map<String, Connection> _connections = <String, Connection>{};
  final StreamController<void> _changes = StreamController<void>.broadcast();
  int _next = 1000;

  static const ConnectNoteRules _noteRules = ConnectNoteRules();
  static const DiscoverVisibilityRules _visibility = DiscoverVisibilityRules();

  /// Fires after any change (mock helper).
  Stream<void> get changes => _changes.stream;

  /// Accepted connection ids of [userId] (mock helper).
  Set<String> acceptedIdsOf(String userId) => <String>{
    for (final c in _connections.values)
      if (c.status == ConnectionStatus.accepted && c.involves(userId))
        c.otherId(userId),
  };

  /// Deletes every connection of [userId] (mock account deletion).
  void removeUser(String userId) {
    _connections.removeWhere((_, c) => c.involves(userId));
    _changes.add(null);
  }

  List<Connection> _of(String userId) {
    final list = _connections.values
        .where(
          (c) =>
              c.involves(userId) &&
              (c.status == ConnectionStatus.pending ||
                  c.status == ConnectionStatus.accepted),
        )
        .toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Stream<List<Connection>> watchConnections(String userId) {
    late final StreamController<List<Connection>> controller;
    StreamSubscription<void>? changes;
    controller = StreamController<List<Connection>>(
      onListen: () {
        controller.add(_of(userId));
        changes = _changes.stream.listen((_) => controller.add(_of(userId)));
      },
      onCancel: () => changes?.cancel(),
    );
    return controller.stream;
  }

  @override
  Future<Connection> sendRequest({
    required String requesterId,
    required String receiverId,
    String? note,
  }) async {
    if (!_noteRules.isValid(note)) {
      throw const ValidationFailure(ValidationReason.connectNoteTooLong);
    }
    final sender = await _profiles.getProfile(requesterId);
    await _profiles.getProfile(receiverId);
    if (!_visibility.canSendRequest(sender)) {
      throw const ValidationFailure(ValidationReason.profileIncomplete);
    }
    final exists = _of(requesterId).any((c) => c.involves(receiverId));
    if (exists || requesterId == receiverId) {
      throw const ValidationFailure(ValidationReason.alreadyConnected);
    }
    final connection = Connection(
      id: 'connection-${_next++}',
      requesterId: requesterId,
      receiverId: receiverId,
      status: ConnectionStatus.pending,
      createdAt: _now ?? DateTime.now(),
      note: _noteRules.normalise(note),
    );
    _connections[connection.id] = connection;
    _changes.add(null);
    return connection;
  }

  @override
  Future<void> respond({
    required String connectionId,
    required String userId,
    required bool accept,
  }) async {
    final c = _connections[connectionId];
    if (c == null ||
        c.receiverId != userId ||
        c.status != ConnectionStatus.pending) {
      throw const NotFoundFailure();
    }
    _connections[connectionId] = c.copyWith(
      status: accept ? ConnectionStatus.accepted : ConnectionStatus.declined,
    );
    _changes.add(null);
  }

  @override
  Future<void> remove({
    required String connectionId,
    required String userId,
  }) async {
    final c = _connections[connectionId];
    if (c == null || !c.involves(userId)) {
      throw const NotFoundFailure();
    }
    _connections[connectionId] = c.copyWith(status: ConnectionStatus.removed);
    _changes.add(null);
  }
}
