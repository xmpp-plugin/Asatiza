import 'package:equatable/equatable.dart';

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
  });

  final ChatStatus status;

  /// The person you are chatting with.
  final Profile? other;
  final Conversation? conversation;

  /// Oldest first.
  final List<Message> messages;
  final bool sending;

  ChatState copyWith({
    ChatStatus? status,
    Profile? other,
    Conversation? conversation,
    List<Message>? messages,
    bool? sending,
  }) {
    return ChatState(
      status: status ?? this.status,
      other: other ?? this.other,
      conversation: conversation ?? this.conversation,
      messages: messages ?? this.messages,
      sending: sending ?? this.sending,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    other,
    conversation,
    messages,
    sending,
  ];
}
