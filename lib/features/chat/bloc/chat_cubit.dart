import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/failures.dart';
import '../../../data/models/message.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import 'chat_state.dart';

/// Opens the chat with [otherId] (only for accepted connections), streams
/// its messages, marks them read while open and sends text or an image.
class ChatCubit extends Cubit<ChatState> {
  ChatCubit(
    this._chats,
    this._profiles, {
    required this.viewerId,
    required this.otherId,
  }) : super(const ChatState()) {
    unawaited(_open());
  }

  /// Mock phase: the photo button attaches this sample page (no picker).
  static const String samplePhoto = 'assets/illustrations/qaida_page.svg';

  final ChatRepository _chats;
  final ProfileRepository _profiles;
  final String viewerId;
  final String otherId;
  StreamSubscription<List<Message>>? _sub;

  Future<void> _open() async {
    try {
      final other = await _profiles.getProfile(otherId);
      final conversation = await _chats.openConversation(
        userId: viewerId,
        otherId: otherId,
      );
      if (isClosed) {
        return;
      }
      emit(state.copyWith(other: other, conversation: conversation));
      _sub = _chats
          .watchMessages(conversationId: conversation.id, viewerId: viewerId)
          .listen(
            _onMessages,
            onError: (Object _) =>
                _emit(state.copyWith(status: ChatStatus.unavailable)),
          );
    } on Failure {
      _emit(state.copyWith(status: ChatStatus.unavailable));
    }
  }

  void _emit(ChatState next) {
    if (!isClosed) {
      emit(next);
    }
  }

  void _onMessages(List<Message> messages) {
    _emit(state.copyWith(status: ChatStatus.ready, messages: messages));
    final unread = messages.any((m) => m.senderId != viewerId && !m.isRead);
    final id = state.conversation?.id;
    if (unread && id != null) {
      unawaited(
        _chats
            .markRead(conversationId: id, userId: viewerId)
            .catchError((Object _) {}),
      );
    }
  }

  /// Sends [text]; false when nothing was sent.
  Future<bool> send({String? text, String? imagePath}) async {
    final id = state.conversation?.id;
    if (id == null || state.sending) {
      return false;
    }
    _emit(state.copyWith(sending: true));
    try {
      await _chats.sendMessage(
        conversationId: id,
        senderId: viewerId,
        body: text,
        imagePath: imagePath,
      );
      return true;
    } on ValidationFailure catch (f) {
      if (f.reason == ValidationReason.notConnected) {
        _emit(state.copyWith(status: ChatStatus.unavailable));
      }
      return false;
    } on Failure {
      return false;
    } finally {
      _emit(state.copyWith(sending: false));
    }
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
