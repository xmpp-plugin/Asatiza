import 'package:equatable/equatable.dart';

/// Which notifications a user wants (Settings → Notifications).
class NotificationSettings extends Equatable {
  const NotificationSettings({
    this.connectionRequests = true,
    this.newMessages = true,
    this.comments = true,
    this.likes = false,
  });

  final bool connectionRequests;
  final bool newMessages;

  /// Comments on my posts.
  final bool comments;
  final bool likes;

  NotificationSettings copyWith({
    bool? connectionRequests,
    bool? newMessages,
    bool? comments,
    bool? likes,
  }) {
    return NotificationSettings(
      connectionRequests: connectionRequests ?? this.connectionRequests,
      newMessages: newMessages ?? this.newMessages,
      comments: comments ?? this.comments,
      likes: likes ?? this.likes,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    connectionRequests,
    newMessages,
    comments,
    likes,
  ];
}
