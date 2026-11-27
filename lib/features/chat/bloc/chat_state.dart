import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';

import '../../../data/models/conversation.dart';
import '../../../data/models/message.dart';
import '../../../data/models/profile.dart';

enum ChatStatus { loading, ready, unavailable }

/// 18 Chat conversation.
class ChatState extends Equatable {
  const ChatState({
    this.status = ChatStatus.loading,
    this.other,
    this.conversation,
    this.messages = const <Message>[],
    this.sending = false,
    this.uploadingPhoto = false,
    this.error,
  });

  final ChatStatus status;

  /// The person you are chatting with.
  final Profile? other;
  final Conversation? conversation;

  /// Oldest first.
  final List<Message> messages;
  final bool sending;

  /// A photo is being compressed and uploaded.
  final bool uploadingPhoto;

  /// Why the last send failed (shown once as a snackbar); null otherwise.
  final ValidationReason? error;

  /// False after the connection was removed: history only (PHASE_009).
  bool get canSend => conversation?.canSend ?? false;

  ChatState copyWith({
    ChatStatus? status,
    Profile? other,
    Conversation? conversation,
    List<Message>? messages,
    bool? sending,
    bool? uploadingPhoto,
    ValidationReason? Function()? error,
  }) {
    return ChatState(
      status: status ?? this.status,
      other: other ?? this.other,
      conversation: conversation ?? this.conversation,
      messages: messages ?? this.messages,
      sending: sending ?? this.sending,
      uploadingPhoto: uploadingPhoto ?? this.uploadingPhoto,
      error: error != null ? error() : this.error,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    other,
    conversation,
    messages,
    sending,
    uploadingPhoto,
    error,
  ];
}
