import 'package:equatable/equatable.dart';

import 'message.dart';

/// A one-to-one chat between two connected users, as seen by one viewer:
/// [lastMessage] and [unreadCount] are filled per viewer by the repository.
class Conversation extends Equatable {
  const Conversation({
    required this.id,
    required this.memberIds,
    required this.startedAt,
    this.lastMessage,
    this.unreadCount = 0,
  });

  final String id;

  /// The two members.
  final List<String> memberIds;

  /// When the connection was accepted ("Connected 3 days ago").
  final DateTime startedAt;
  final Message? lastMessage;
  final int unreadCount;

  /// The other member, seen from [userId].
  String otherId(String userId) =>
      memberIds.firstWhere((id) => id != userId, orElse: () => userId);

  @override
  List<Object?> get props => <Object?>[
    id,
    memberIds,
    startedAt,
    lastMessage,
    unreadCount,
  ];
}
