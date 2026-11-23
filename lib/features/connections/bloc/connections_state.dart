import 'package:equatable/equatable.dart';

import '../../../data/models/connection.dart';
import '../../../data/models/enums/connection_status.dart';
import '../../../data/models/profile.dart';

enum ConnectionsTab { connected, requests, sent }

/// My connections (artboard 16): Connected / Requests / Sent.
class ConnectionsState extends Equatable {
  const ConnectionsState({
    required this.viewerId,
    this.loading = true,
    this.tab = ConnectionsTab.connected,
    this.connections = const <Connection>[],
    this.people = const <String, Profile>{},
  });

  final String viewerId;
  final bool loading;
  final ConnectionsTab tab;
  final List<Connection> connections;

  /// Profiles of the other people, by id.
  final Map<String, Profile> people;

  List<Connection> _where(bool Function(Connection) test) => connections
      .where((c) => test(c) && people.containsKey(c.otherId(viewerId)))
      .toList();

  List<Connection> get connected =>
      _where((c) => c.status == ConnectionStatus.accepted);

  List<Connection> get requests => _where(
    (c) => c.status == ConnectionStatus.pending && c.receiverId == viewerId,
  );

  List<Connection> get sent => _where(
    (c) => c.status == ConnectionStatus.pending && c.requesterId == viewerId,
  );

  List<Connection> get visible => switch (tab) {
    ConnectionsTab.connected => connected,
    ConnectionsTab.requests => requests,
    ConnectionsTab.sent => sent,
  };

  ConnectionsState copyWith({
    bool? loading,
    ConnectionsTab? tab,
    List<Connection>? connections,
    Map<String, Profile>? people,
  }) {
    return ConnectionsState(
      viewerId: viewerId,
      loading: loading ?? this.loading,
      tab: tab ?? this.tab,
      connections: connections ?? this.connections,
      people: people ?? this.people,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    viewerId,
    loading,
    tab,
    connections,
    people,
  ];
}
