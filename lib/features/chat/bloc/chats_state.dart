import 'package:equatable/equatable.dart';

import '../../../data/models/conversation.dart';
import '../../../data/models/profile.dart';

/// 17 Chats list.
class ChatsState extends Equatable {
  const ChatsState({
    required this.viewerId,
    this.loading = true,
    this.conversations = const <Conversation>[],
    this.people = const <String, Profile>{},
    this.query = '',
  });

  final String viewerId;
  final bool loading;
  final List<Conversation> conversations;

  /// The other members' profiles, by id.
  final Map<String, Profile> people;
  final String query;

  /// Conversations whose other member's name matches [query].
  List<Conversation> get visible {
    final q = query.trim().toLowerCase();
    return conversations.where((c) {
      final p = people[c.otherId(viewerId)];
      return p != null && (q.isEmpty || p.fullName.toLowerCase().contains(q));
    }).toList();
  }

  ChatsState copyWith({
    bool? loading,
    List<Conversation>? conversations,
    Map<String, Profile>? people,
    String? query,
  }) {
    return ChatsState(
      viewerId: viewerId,
      loading: loading ?? this.loading,
      conversations: conversations ?? this.conversations,
      people: people ?? this.people,
      query: query ?? this.query,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    viewerId,
    loading,
    conversations,
    people,
    query,
  ];
}
