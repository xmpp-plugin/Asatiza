import 'package:equatable/equatable.dart';

/// One chat message: text, an image, or both (mirrors the planned
/// `messages` table, plan section 12).
class Message extends Equatable {
  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.sentAt,
    this.body,
    this.imagePath,
    this.readAt,
  });

  final String id;
  final String conversationId;
  final String senderId;
  final DateTime sentAt;
  final String? body;

  /// Image attachment (asset path in the mock phase).
  final String? imagePath;

  /// When the other person read it; null while unread.
  final DateTime? readAt;

  bool get isRead => readAt != null;

  Message markRead(DateTime at) => Message(
    id: id,
    conversationId: conversationId,
    senderId: senderId,
    sentAt: sentAt,
    body: body,
    imagePath: imagePath,
    readAt: readAt ?? at,
  );

  @override
  List<Object?> get props => <Object?>[
    id,
    conversationId,
    senderId,
    sentAt,
    body,
    imagePath,
    readAt,
  ];
}
