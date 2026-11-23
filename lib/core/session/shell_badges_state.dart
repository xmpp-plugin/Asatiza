import 'package:equatable/equatable.dart';

/// Unread counts on the bottom bar.
class ShellBadgesState extends Equatable {
  const ShellBadgesState({this.chats = 0, this.alerts = 0});

  /// Unread chat messages.
  final int chats;

  /// Unread notifications.
  final int alerts;

  @override
  List<Object?> get props => <Object?>[chats, alerts];
}
