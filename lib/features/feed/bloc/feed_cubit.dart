import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/failures.dart';
import '../../../data/models/post.dart';
import '../../../data/models/profile.dart';
import '../../../data/repositories/feed_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../data/repositories/safety_repository.dart';
import 'feed_state.dart';

/// Home feed: ordered posts (repository order) minus blocked authors, with
/// their author profiles.
class FeedCubit extends Cubit<FeedState> {
  FeedCubit(this._feed, this._profiles, this._safety, {required this.viewerId})
    : super(const FeedState()) {
    _postsSub = _feed.watchPosts(viewerId: viewerId).listen((posts) {
      _latestPosts = posts;
      _rebuild();
    }, onError: (Object _) {});
    _blockedSub = _safety.watchBlockedIds(viewerId).listen((ids) {
      _blocked = ids;
      _rebuild();
    }, onError: (Object _) {});
  }

  final FeedRepository _feed;
  final ProfileRepository _profiles;
  final SafetyRepository _safety;
  final String viewerId;

  StreamSubscription<List<Post>>? _postsSub;
  StreamSubscription<Set<String>>? _blockedSub;
  List<Post>? _latestPosts;
  Set<String> _blocked = const <String>{};

  Future<void> _rebuild() async {
    final posts = _latestPosts;
    if (posts == null) {
      return;
    }
    final visible = posts.where((p) => !_blocked.contains(p.authorId)).toList();
    final missing = visible
        .map((p) => p.authorId)
        .where((id) => !state.authors.containsKey(id));
    var authors = state.authors;
    if (missing.isNotEmpty) {
      final loaded = await _profiles.getProfiles(missing);
      authors = <String, Profile>{...authors, for (final p in loaded) p.id: p};
    }
    if (!isClosed) {
      emit(
        state.copyWith(
          status: FeedStatus.ready,
          posts: visible,
          authors: authors,
        ),
      );
    }
  }

  Future<void> toggleLike(String postId) async {
    try {
      await _feed.toggleLike(postId: postId, userId: viewerId);
    } on Failure {
      // The post disappeared; the stream already reflects it.
    }
  }

  @override
  Future<void> close() async {
    await _postsSub?.cancel();
    await _blockedSub?.cancel();
    return super.close();
  }
}
