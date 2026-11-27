import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/failures.dart';
import '../../../core/services/image_compressor.dart';
import '../../../core/services/image_picker_service.dart';
import '../../../core/services/image_source_kind.dart';
import '../../../data/models/enums/media_bucket.dart';
import '../../../data/models/message.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../data/repositories/media_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import 'chat_state.dart';

/// Opens the chat with [otherId] (created only for accepted connections;
/// an existing chat opens read-only after the connection was removed),
/// streams its messages live, marks them read while open and sends text or
/// a photo (picked, compressed and uploaded to `chat-images`).
class ChatCubit extends Cubit<ChatState> {
  ChatCubit(
    this._chats,
    this._profiles, {
    required MediaRepository media,
    required ImagePickerService picker,
    required ImageCompressor compressor,
    required this.viewerId,
    required this.otherId,
  }) : _media = media,
       _picker = picker,
       _compressor = compressor,
       super(const ChatState()) {
    unawaited(_open());
  }

  final ChatRepository _chats;
  final ProfileRepository _profiles;
  final MediaRepository _media;
  final ImagePickerService _picker;
  final ImageCompressor _compressor;
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

  /// Sends [text] and / or an uploaded [imagePath]; false when nothing was
  /// sent ([ChatState.error] says why).
  Future<bool> send({String? text, String? imagePath}) async {
    final id = state.conversation?.id;
    if (id == null || state.sending || !state.canSend) {
      return false;
    }
    _emit(state.copyWith(sending: true, error: () => null));
    try {
      await _chats.sendMessage(
        conversationId: id,
        senderId: viewerId,
        body: text,
        imagePath: imagePath,
      );
      return true;
    } on ValidationFailure catch (f) {
      _emit(state.copyWith(error: () => f.reason));
      if (f.reason == ValidationReason.notConnected) {
        // Connection removed meanwhile: re-open as read-only history.
        unawaited(_reopen());
      }
      return false;
    } on Failure catch (f) {
      _emit(state.copyWith(error: () => f.displayReason));
      return false;
    } finally {
      _emit(state.copyWith(sending: false));
    }
  }

  /// Takes or chooses a photo, compresses and uploads it, and sends it.
  Future<bool> sendPhoto(ImageSourceKind source) async {
    final id = state.conversation?.id;
    if (id == null || state.uploadingPhoto || !state.canSend) {
      return false;
    }
    _emit(state.copyWith(error: () => null));
    String? path;
    try {
      final picked = await _picker.pickImage(source);
      if (picked == null || isClosed) {
        return false;
      }
      _emit(state.copyWith(uploadingPhoto: true));
      final jpeg = await _compressor.compressPhoto(picked);
      path = await _media.uploadChatImage(viewerId, id, jpeg);
    } on Failure catch (f) {
      _emit(
        state.copyWith(uploadingPhoto: false, error: () => f.displayReason),
      );
      return false;
    }
    _emit(state.copyWith(uploadingPhoto: false));
    final sent = await send(imagePath: path);
    if (!sent) {
      // Not referenced by any message: remove the orphan (best effort).
      unawaited(
        _media
            .deleteFiles(MediaBucket.chatImages, <String>[path])
            .catchError((Object _) {}),
      );
    }
    return sent;
  }

  /// Reloads the conversation and its messages (app back in the
  /// foreground), keeping what is on screen until the new list arrives.
  Future<void> refresh() async {
    if (isClosed || state.status == ChatStatus.unavailable) {
      return;
    }
    await _sub?.cancel();
    _sub = null;
    await _open();
  }

  /// Clears the error after it was shown.
  void errorShown() => _emit(state.copyWith(error: () => null));

  Future<void> _reopen() async {
    try {
      final conversation = await _chats.openConversation(
        userId: viewerId,
        otherId: otherId,
      );
      _emit(state.copyWith(conversation: conversation));
    } on Failure {
      _emit(state.copyWith(status: ChatStatus.unavailable));
    }
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
