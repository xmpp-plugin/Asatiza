import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/failures.dart';
import '../../../data/models/connection.dart';
import '../../../data/models/profile.dart';
import '../../../data/repositories/connection_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../data/repositories/safety_repository.dart';
import 'connections_state.dart';

/// My connections: lists, accept / decline, remove, cancel and block.
class ConnectionsCubit extends Cubit<ConnectionsState> {
  ConnectionsCubit(
    this._connections,
    this._profiles,
    this._safety, {
    required String viewerId,
    ConnectionsTab initialTab = ConnectionsTab.connected,
  }) : super(ConnectionsState(viewerId: viewerId, tab: initialTab)) {
    _sub = _connections
        .watchConnections(viewerId)
        .listen(_onConnections, onError: (Object _) {});
    _blockedSub = _safety
        .watchBlockedIds(viewerId)
        .listen(_onBlocked, onError: (Object _) {});
  }

  final ConnectionRepository _connections;
  final ProfileRepository _profiles;
  final SafetyRepository _safety;

  StreamSubscription<List<Connection>>? _sub;
  StreamSubscription<Set<String>>? _blockedSub;
  Set<String> _blocked = const <String>{};
  List<Connection> _latest = const <Connection>[];

  String get _viewerId => state.viewerId;

  Future<void> _onConnections(List<Connection> list) async {
    _latest = list;
    await _rebuild();
  }

  Future<void> _onBlocked(Set<String> ids) async {
    _blocked = ids;
    await _rebuild();
  }

  Future<void> _rebuild() async {
    final visible = _latest
        .where((c) => !_blocked.contains(c.otherId(_viewerId)))
        .toList();
    final ids = visible.map((c) => c.otherId(_viewerId)).toSet();
    final missing = ids.where((id) => !state.people.containsKey(id));
    var people = state.people;
    if (missing.isNotEmpty) {
      final loaded = await _profiles.getProfiles(missing);
      people = <String, Profile>{...people, for (final p in loaded) p.id: p};
    }
    if (!isClosed) {
      emit(
        state.copyWith(loading: false, connections: visible, people: people),
      );
    }
  }

  void tabChanged(ConnectionsTab tab) => emit(state.copyWith(tab: tab));

  Future<void> respond(Connection connection, {required bool accept}) => _guard(
    () => _connections.respond(
      connectionId: connection.id,
      userId: _viewerId,
      accept: accept,
    ),
  );

  /// Removes an accepted connection or cancels a sent request.
  Future<void> remove(Connection connection) => _guard(
    () => _connections.remove(connectionId: connection.id, userId: _viewerId),
  );

  Future<void> block(Connection connection) => _guard(
    () => _safety.blockUser(
      blockerId: _viewerId,
      blockedId: connection.otherId(_viewerId),
    ),
  );

  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } on Failure {
      // Already changed elsewhere; the stream shows the current state.
    }
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    await _blockedSub?.cancel();
    return super.close();
  }
}
