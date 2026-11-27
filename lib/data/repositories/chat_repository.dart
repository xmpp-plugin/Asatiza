import '../models/conversation.dart';
import '../models/message.dart';

/// One-to-one chat (plan section 4: only between accepted connections). The
/// Supabase implementation enforces membership, connections and blocks in
/// the database and streams changes live (PHASE_009). Throws only `Failure`
/// types.
abstract interface class ChatRepository {
  /// [userId]'s conversations, newest message first, with last message and
  /// unread count for [userId]. Emits again on every change.
  Stream<List<Conversation>> watchConversations(String userId);

  /// The conversation between [userId] and [otherId], created on first use.
  /// An existing conversation opens even when they are no longer connected
  /// (`Conversation.canSend` false: read-only). Throws
  /// `ValidationFailure(notConnected)` when it would have to be created and
  /// they are not connected; `NotFoundFailure` across a block.
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

  /// Sends text and / or an image ([imagePath] from
  /// `MediaRepository.uploadChatImage`). Throws `ValidationFailure` with
  /// `messageEmpty` (both empty), `messageTooLong` (over 2,000 characters),
  /// `notConnected` (connection removed), `dailyMessageLimit` (300 messages
  /// in 24 hours) or `dailyPhotoLimit` (30 photos in 24 hours).
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
