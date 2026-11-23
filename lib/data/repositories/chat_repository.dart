import '../models/conversation.dart';
import '../models/message.dart';

/// Provisional contract for one-to-one chat (plan section 4: only between
/// accepted connections). Throws only `Failure` types.
abstract interface class ChatRepository {
  /// [userId]'s conversations, newest message first, with last message and
  /// unread count for [userId]. Emits again on every change.
  Stream<List<Conversation>> watchConversations(String userId);

  /// The conversation between [userId] and [otherId], created on first use.
  /// Throws `ValidationFailure(notConnected)` unless they are connected.
  Future<Conversation> openConversation({
    required String userId,
    required String otherId,
  });

  /// Messages of [conversationId], oldest first. Throws `NotFoundFailure`
  /// when [viewerId] is not a member.
  Stream<List<Message>> watchMessages({
    required String conversationId,
    required String viewerId,
  });

  /// Sends text and / or an image. Throws `ValidationFailure(messageEmpty)`
  /// when both are empty.
  Future<Message> sendMessage({
    required String conversationId,
    required String senderId,
    String? body,
    String? imagePath,
  });

  /// Marks the other member's messages as read by [userId].
  Future<void> markRead({
    required String conversationId,
    required String userId,
  });
}
