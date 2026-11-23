import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/conversation.dart';
import '../../../data/models/profile.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import 'chats_state.dart';

/// Lists the viewer's conversations and searches them by name.
class ChatsCubit extends Cubit<ChatsState> {
  ChatsCubit(this._chats, this._profiles, {required String viewerId})
    : super(ChatsState(viewerId: viewerId)) {
    _sub = _chats
        .watchConversations(viewerId)
        .listen(_onConversations, onError: (Object _) {});
  }

  final ChatRepository _chats;
  final ProfileRepository _profiles;
  StreamSubscription<List<Conversation>>? _sub;

  Future<void> _onConversations(List<Conversation> list) async {
    final ids = list.map((c) => c.otherId(state.viewerId));
    final missing = ids.where((id) => !state.people.containsKey(id)).toSet();
    var people = state.people;
    if (missing.isNotEmpty) {
      final loaded = await _profiles.getProfiles(missing);
      people = <String, Profile>{...people, for (final p in loaded) p.id: p};
    }
    if (!isClosed) {
      emit(state.copyWith(loading: false, conversations: list, people: people));
    }
  }

  void queryChanged(String query) => emit(state.copyWith(query: query));

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
