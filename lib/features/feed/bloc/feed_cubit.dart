import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/failures.dart';
import '../../../data/models/post.dart';
import '../../../data/models/profile.dart';
import '../../../data/repositories/feed_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../data/repositories/block_repository.dart';
import 'feed_state.dart';

/// Home feed: ordered posts (repository order) minus blocked authors, with
/// their author profiles; [pageSize] more on [loadMore], from the top on
/// [refresh] (PHASE_010).
class FeedCubit extends Cubit<FeedState> {
  FeedCubit(this._feed, this._profiles, this._blocks, {required this.viewerId})
    : super(const FeedState()) {
    unawaited(_listenPosts());
    _blockedSub = _blocks.watchBlockedIds(viewerId).listen((ids) {
      _blocked = ids;
      _rebuild();
    }, onError: (Object _) {});
  }

  final FeedRepository _feed;
  final ProfileRepository _profiles;
  final BlockRepository _blocks;
  final String viewerId;

  StreamSubscription<List<Post>>? _postsSub;
  StreamSubscription<Set<String>>? _blockedSub;
  List<Post>? _latestPosts;
  Set<String> _blocked = const <String>{};

  static const int pageSize = 20;
  int _limit = pageSize;
  bool _loadingMore = false;

  /// Subscribes to the first [_limit] posts; completes on the first list.
  Future<void> _listenPosts() async {
    await _postsSub?.cancel();
    final done = Completer<void>();
    void finish() {
      if (!done.isCompleted) done.complete();
    }

    _postsSub = _feed
        .watchPosts(viewerId: viewerId, limit: _limit)
        .listen(
          (posts) async {
            _latestPosts = posts;
            await _rebuild();
            finish();
          },
          onError: (Object _) => finish(),
          onDone: finish,
        );
    return done.future;
  }

  /// Pull-to-refresh: back to the first page.
  Future<void> refresh() {
    _limit = pageSize;
    return _listenPosts();
  }

  /// Loads the next [pageSize] posts (near the end of the list).
  Future<void> loadMore() async {
    if (_loadingMore || !state.canLoadMore || isClosed) {
      return;
    }
    _loadingMore = true;
    _limit += pageSize;
    await _listenPosts();
    _loadingMore = false;
  }

  /// Deletes the viewer's own post; true when it was deleted.
  Future<bool> deletePost(String postId) async {
    try {
      await _feed.deletePost(postId: postId, userId: viewerId);
      return true;
    } on Failure {
      return false;
    }
  }

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
          canLoadMore: posts.length >= _limit,
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
