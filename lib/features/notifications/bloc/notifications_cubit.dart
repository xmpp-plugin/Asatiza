import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/failures.dart';
import '../../../data/models/app_notification.dart';
import '../../../data/models/connection.dart';
import '../../../data/models/profile.dart';
import '../../../data/repositories/connection_repository.dart';
import '../../../data/repositories/notification_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../data/repositories/safety_repository.dart';
import 'notifications_state.dart';

/// Notifications with Accept / Decline on requests and Mark all read.
class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit(
    this._notifications,
    this._connections,
    this._profiles,
    this._safety, {
    required this.viewerId,
  }) : super(const NotificationsState()) {
    _itemsSub = _notifications
        .watchNotifications(viewerId)
        .listen(_onItems, onError: (Object _) {});
    _connectionsSub = _connections
        .watchConnections(viewerId)
        .listen(
          (list) => _emit(
            state.copyWith(
              connections: <String, Connection>{for (final c in list) c.id: c},
            ),
          ),
          onError: (Object _) {},
        );
    _blockedSub = _safety.watchBlockedIds(viewerId).listen((ids) {
      _blocked = ids;
      unawaited(_onItems(_latest));
    }, onError: (Object _) {});
  }

  final NotificationRepository _notifications;
  final ConnectionRepository _connections;
  final ProfileRepository _profiles;
  final SafetyRepository _safety;
  final String viewerId;

  StreamSubscription<List<AppNotification>>? _itemsSub;
  StreamSubscription<List<Connection>>? _connectionsSub;
  StreamSubscription<Set<String>>? _blockedSub;
  List<AppNotification> _latest = const <AppNotification>[];
  Set<String> _blocked = const <String>{};

  void _emit(NotificationsState next) {
    if (!isClosed) {
      emit(next);
    }
  }

  Future<void> _onItems(List<AppNotification> list) async {
    _latest = list;
    final actors = list.map((n) => n.actorId).whereType<String>().toSet();
    final missing = actors.where((id) => !state.people.containsKey(id));
    var people = state.people;
    if (missing.isNotEmpty) {
      final loaded = await _profiles.getProfiles(missing);
      people = <String, Profile>{...people, for (final p in loaded) p.id: p};
    }
    people = <String, Profile>{
      for (final e in people.entries)
        if (!_blocked.contains(e.key)) e.key: e.value,
    };
    _emit(state.copyWith(loading: false, items: list, people: people));
  }

  Future<void> markAllRead() => _notifications.markAllRead(viewerId);

  Future<void> open(AppNotification n) async {
    try {
      await _notifications.markRead(notificationId: n.id, userId: viewerId);
    } on Failure {
      // Removed meanwhile; the stream shows the current list.
    }
  }

  /// Accepts or declines the request behind [n]; true when it was accepted.
  Future<bool> respond(AppNotification n, {required bool accept}) async {
    final id = n.connectionId;
    if (id == null) {
      return false;
    }
    try {
      await _connections.respond(
        connectionId: id,
        userId: viewerId,
        accept: accept,
      );
      await open(n);
      return accept;
    } on Failure {
      return false;
    }
  }

  @override
  Future<void> close() async {
    await _itemsSub?.cancel();
    await _connectionsSub?.cancel();
    await _blockedSub?.cancel();
    return super.close();
  }
}
