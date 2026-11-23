import 'package:equatable/equatable.dart';

import 'enums/notification_type.dart';

/// One in-app notification (mirrors the planned `notifications` table).
class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.createdAt,
    this.actorId,
    this.postId,
    this.connectionId,
    this.text,
    this.othersCount = 0,
    this.read = false,
  });

  final String id;

  /// Who receives it.
  final String userId;
  final NotificationType type;
  final DateTime createdAt;

  /// Who caused it (null for system notifications such as approval).
  final String? actorId;
  final String? postId;
  final String? connectionId;

  /// Request note or comment text.
  final String? text;

  /// For grouped likes: people besides [actorId].
  final int othersCount;
  final bool read;

  AppNotification markRead() => AppNotification(
    id: id,
    userId: userId,
    type: type,
    createdAt: createdAt,
    actorId: actorId,
    postId: postId,
    connectionId: connectionId,
    text: text,
    othersCount: othersCount,
    read: true,
  );

  @override
  List<Object?> get props => <Object?>[
    id,
    userId,
    type,
    createdAt,
    actorId,
    postId,
    connectionId,
    text,
    othersCount,
    read,
  ];
}
