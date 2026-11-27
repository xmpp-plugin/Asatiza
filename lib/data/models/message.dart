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
    this.imageUrl,
    this.readAt,
  });

  final String id;
  final String conversationId;
  final String senderId;
  final DateTime sentAt;
  final String? body;

  /// Image attachment: a `chat-images` Storage path (PHASE_009), or an asset
  /// path in test fakes.
  final String? imagePath;

  /// Short-lived signed URL of [imagePath], filled by the repository when
  /// reading; never written to the database. Null for test fakes.
  final String? imageUrl;

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
    imageUrl: imageUrl,
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
    imageUrl,
    readAt,
  ];
}
