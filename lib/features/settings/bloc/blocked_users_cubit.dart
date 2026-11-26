import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/failures.dart';
import '../../../data/models/profile.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../data/repositories/block_repository.dart';
import 'blocked_users_state.dart';

/// Lists the people the user blocked and unblocks them.
class BlockedUsersCubit extends Cubit<BlockedUsersState> {
  BlockedUsersCubit(this._blocks, this._profiles, {required this.viewerId})
    : super(const BlockedUsersState()) {
    _sub = _blocks
        .watchBlockedUsers(viewerId)
        .listen(_onBlocked, onError: (Object _) {});
  }

  final BlockRepository _blocks;
  final ProfileRepository _profiles;
  final String viewerId;
  StreamSubscription<List<BlockedUser>>? _sub;

  Future<void> _onBlocked(List<BlockedUser> list) async {
    final missing = list
        .map((b) => b.userId)
        .where((id) => !state.people.containsKey(id));
    var people = state.people;
    if (missing.isNotEmpty) {
      final loaded = await _profiles.getProfiles(missing);
      people = <String, Profile>{...people, for (final p in loaded) p.id: p};
    }
    if (!isClosed) {
      emit(state.copyWith(loading: false, blocked: list, people: people));
    }
  }

  /// Removes the block; false when it failed (offline / server error), so
  /// the screen can say so. The list is unchanged on failure.
  Future<bool> unblock(String userId) async {
    try {
      await _blocks.unblockUser(blockerId: viewerId, blockedId: userId);
      return true;
    } on Failure {
      return false;
    }
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
