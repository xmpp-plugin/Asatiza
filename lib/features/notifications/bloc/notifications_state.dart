import 'package:equatable/equatable.dart';

import '../../../data/models/app_notification.dart';
import '../../../data/models/connection.dart';
import '../../../data/models/enums/connection_status.dart';
import '../../../data/models/profile.dart';

/// 19 Notifications: New (unread) and Earlier (read).
class NotificationsState extends Equatable {
  const NotificationsState({
    this.loading = true,
    this.items = const <AppNotification>[],
    this.people = const <String, Profile>{},
    this.connections = const <String, Connection>{},
  });

  final bool loading;

  /// Newest first.
  final List<AppNotification> items;

  /// Actors' profiles, by id.
  final Map<String, Profile> people;

  /// The viewer's pending / accepted connections, by id.
  final Map<String, Connection> connections;

  /// Items whose actor (if any) is still available.
  List<AppNotification> get _shown => items
      .where((n) => n.actorId == null || people.containsKey(n.actorId))
      .toList();

  List<AppNotification> get unread => _shown.where((n) => !n.read).toList();
  List<AppNotification> get earlier => _shown.where((n) => n.read).toList();

  /// True while the request behind [n] still waits for an answer.
  bool isOpenRequest(AppNotification n) {
    final c = n.connectionId == null ? null : connections[n.connectionId];
    return c != null &&
        c.receiverId == n.userId &&
        c.status == ConnectionStatus.pending;
  }

  NotificationsState copyWith({
    bool? loading,
    List<AppNotification>? items,
    Map<String, Profile>? people,
    Map<String, Connection>? connections,
  }) {
    return NotificationsState(
      loading: loading ?? this.loading,
      items: items ?? this.items,
      people: people ?? this.people,
      connections: connections ?? this.connections,
    );
  }

  @override
  List<Object?> get props => <Object?>[loading, items, people, connections];
}
