import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/failures.dart';
import '../../../data/models/connection.dart';
import '../../../data/models/enums/connection_status.dart';
import '../../../data/models/post.dart';
import '../../../data/models/profile.dart';
import '../../../data/repositories/connection_repository.dart';
import '../../../data/repositories/feed_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../data/repositories/block_repository.dart';
import 'public_profile_state.dart';

/// Someone else's profile: details, connection state, counts and block.
class PublicProfileCubit extends Cubit<PublicProfileState> {
  PublicProfileCubit(
    this._profiles,
    this._connections,
    this._feed,
    this._blocks, {
    required this.viewerId,
    required this.profileId,
  }) : super(const PublicProfileState()) {
    _profileSub = _profiles
        .watchProfile(profileId)
        .listen(
          (p) => _emit(state.copyWith(profile: p)),
          onError: (Object _) => _emit(state.copyWith(notFound: true)),
        );
    _mineSub = _connections
        .watchConnections(viewerId)
        .listen(_onMine, onError: (Object _) {});
    _theirsSub = _connections
        .watchConnections(profileId)
        .listen(
          (list) => _emit(
            state.copyWith(
              connectionCount: list
                  .where((c) => c.status == ConnectionStatus.accepted)
                  .length,
            ),
          ),
          onError: (Object _) {},
        );
    _postsSub = _feed
        .watchPosts(viewerId: viewerId)
        .listen(
          (posts) => _emit(
            state.copyWith(
              postCount: posts.where((p) => p.authorId == profileId).length,
            ),
          ),
          onError: (Object _) {},
        );
  }

  final ProfileRepository _profiles;
  final ConnectionRepository _connections;
  final FeedRepository _feed;
  final BlockRepository _blocks;
  final String viewerId;
  final String profileId;

  StreamSubscription<Profile>? _profileSub;
  StreamSubscription<List<Connection>>? _mineSub;
  StreamSubscription<List<Connection>>? _theirsSub;
  StreamSubscription<List<Post>>? _postsSub;

  void _emit(PublicProfileState next) {
    if (!isClosed) {
      emit(next);
    }
  }

  void _onMine(List<Connection> list) {
    Connection? found;
    for (final c in list) {
      if (c.involves(profileId)) {
        found = c;
        break;
      }
    }
    _emit(state.copyWith(connection: () => found));
  }

  /// Accepts this person's pending request to the viewer.
  Future<void> accept() async {
    final c = state.connection;
    if (c == null) {
      return;
    }
    try {
      await _connections.respond(
        connectionId: c.id,
        userId: viewerId,
        accept: true,
      );
    } on Failure {
      // Already answered elsewhere; the stream shows the current state.
    }
  }

  /// Blocks the person; false when it failed (offline / server error), so
  /// the screen can say so. Nothing changes on failure.
  Future<bool> block() async {
    try {
      await _blocks.blockUser(blockerId: viewerId, blockedId: profileId);
    } on Failure {
      return false;
    }
    _emit(state.copyWith(blocked: true));
    return true;
  }

  @override
  Future<void> close() async {
    await _profileSub?.cancel();
    await _mineSub?.cancel();
    await _theirsSub?.cancel();
    await _postsSub?.cancel();
    return super.close();
  }
}
