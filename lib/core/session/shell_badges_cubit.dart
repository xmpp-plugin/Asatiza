import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/app_notification.dart';
import '../../data/models/conversation.dart';
import '../../data/repositories/chat_repository.dart';
import '../../data/repositories/notification_repository.dart';
import 'shell_badges_state.dart';

/// Combines unread chat messages and unread notifications for the bottom
/// bar badges.
class ShellBadgesCubit extends Cubit<ShellBadgesState> {
  ShellBadgesCubit(
    ChatRepository chats,
    NotificationRepository notifications, {
    required String viewerId,
  }) : super(const ShellBadgesState()) {
    _chatsSub = chats
        .watchConversations(viewerId)
        .listen(
          (list) => emit(
            ShellBadgesState(
              chats: list.fold(0, (sum, c) => sum + c.unreadCount),
              alerts: state.alerts,
            ),
          ),
          onError: (Object _) {},
        );
    _alertsSub = notifications
        .watchNotifications(viewerId)
        .listen(
          (list) => emit(
            ShellBadgesState(
              chats: state.chats,
              alerts: list.where((n) => !n.read).length,
            ),
          ),
          onError: (Object _) {},
        );
  }

  StreamSubscription<List<Conversation>>? _chatsSub;
  StreamSubscription<List<AppNotification>>? _alertsSub;

  @override
  Future<void> close() async {
    await _chatsSub?.cancel();
    await _alertsSub?.cancel();
    return super.close();
  }
}
