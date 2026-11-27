import 'dart:async';

import 'package:asatiza/core/errors/failures.dart';
import 'package:asatiza/features/feed/logic/feed_ordering.dart';
import 'package:asatiza/features/post/logic/post_rules.dart';
import 'package:asatiza/data/mock/mock_posts.dart';
import 'package:asatiza/data/mock/mock_profiles.dart';
import 'package:asatiza/data/models/comment.dart';
import 'package:asatiza/data/models/enums/post_tag.dart';
import 'package:asatiza/data/models/post.dart';
import 'package:asatiza/data/repositories/feed_repository.dart';

/// In-memory [FeedRepository] seeded with [buildMockPosts] and
/// [buildMockComments]. State resets when the app restarts.
// Test-only fake: the app uses the Supabase implementation (moved from
// `lib/` in PHASE_010).
class MockFeedRepository implements FeedRepository {
  MockFeedRepository({
    DateTime? now,
    Set<String> Function(String userId) connectedIdsOf = mockConnectedIds,
  }) : _connectedIdsOf = connectedIdsOf {
    final start = now ?? DateTime.now();
    for (final seed in buildMockPosts(start)) {
      _posts[seed.post.id] = seed.post;
      _likes[seed.post.id] = <String>{...seed.likedBy};
      _otherLikes[seed.post.id] = seed.post.likeCount - seed.likedBy.length;
    }
    for (final comment in buildMockComments(start)) {
      _comments.add(comment);
      _commentLikes[comment.id] = <String>{};
    }
  }

  final Set<String> Function(String userId) _connectedIdsOf;
  final Map<String, Post> _posts = <String, Post>{};
  final Map<String, Set<String>> _likes = <String, Set<String>>{};
  final Map<String, int> _otherLikes = <String, int>{};
  final List<Comment> _comments = <Comment>[];
  final Map<String, Set<String>> _commentLikes = <String, Set<String>>{};
  final StreamController<void> _changes = StreamController<void>.broadcast();
  int _nextPost = 100;
  int _nextComment = 1000;

  static const FeedOrdering _ordering = FeedOrdering();
  static const PostRules _rules = PostRules();

  /// Deletes [userId]'s posts, comments and likes (mock account deletion).
  void removeUser(String userId) {
    final postIds = _posts.values
        .where((p) => p.authorId == userId)
        .map((p) => p.id)
        .toSet();
    _posts.removeWhere((id, _) => postIds.contains(id));
    _comments.removeWhere(
      (c) => c.authorId == userId || postIds.contains(c.postId),
    );
    for (final likes in _likes.values) {
      likes.remove(userId);
    }
    for (final likes in _commentLikes.values) {
      likes.remove(userId);
    }
    _changes.add(null);
  }

  Post _view(Post post, String viewerId) {
    final likedBy = _likes[post.id] ?? const <String>{};
    return post.copyWith(
      likeCount: (_otherLikes[post.id] ?? 0) + likedBy.length,
      commentCount: _comments.where((c) => c.postId == post.id).length,
      likedByMe: likedBy.contains(viewerId),
    );
  }

  Comment _viewComment(Comment comment, String viewerId) {
    final likedBy = _commentLikes[comment.id] ?? const <String>{};
    return comment.copyWith(
      likeCount: comment.likeCount + likedBy.length,
      likedByMe: likedBy.contains(viewerId),
    );
  }

  List<Post> _feed(String viewerId) => _ordering.order(
    _posts.values.map((p) => _view(p, viewerId)),
    _connectedIdsOf(viewerId),
  );

  /// Emits [read] now and after every change; cancelling stops at once.
  Stream<T> _watch<T>(T Function() read) {
    late final StreamController<T> controller;
    StreamSubscription<void>? changes;
    controller = StreamController<T>(
      onListen: () {
        controller.add(read());
        changes = _changes.stream.listen((_) => controller.add(read()));
      },
      onCancel: () => changes?.cancel(),
    );
    return controller.stream;
  }

  @override
  Stream<List<Post>> watchPosts({required String viewerId, int limit = 20}) =>
      _watch(() => _feed(viewerId).take(limit).toList());

  @override
  Stream<List<Post>> watchPostsBy({
    required String authorId,
    required String viewerId,
  }) => _watch(
    () =>
        _posts.values
            .where((p) => p.authorId == authorId)
            .map((p) => _view(p, viewerId))
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
  );

  @override
  Future<List<Post>> searchPosts({
    required String query,
    required String viewerId,
  }) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      return const <Post>[];
    }
    return _posts.values
        .where(
          (p) =>
              p.body.toLowerCase().contains(q) ||
              p.tag.name.toLowerCase().contains(q.replaceAll(' ', '')),
        )
        .map((p) => _view(p, viewerId))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<void> deletePost({
    required String postId,
    required String userId,
  }) async {
    final post = _posts[postId];
    if (post == null || post.authorId != userId) {
      throw const NotFoundFailure();
    }
    _posts.remove(postId);
    _likes.remove(postId);
    _comments.removeWhere((c) => c.postId == postId);
    _changes.add(null);
  }

  @override
  Future<void> deleteComment({
    required String commentId,
    required String userId,
  }) async {
    final before = _comments.length;
    _comments.removeWhere((c) => c.id == commentId && c.authorId == userId);
    if (_comments.length == before) {
      throw const NotFoundFailure();
    }
    _commentLikes.remove(commentId);
    _changes.add(null);
  }

  @override
  Stream<Post> watchPost({required String postId, required String viewerId}) {
    if (!_posts.containsKey(postId)) {
      return Stream<Post>.error(const NotFoundFailure());
    }
    return _watch(() => _view(_posts[postId]!, viewerId));
  }

  @override
  Stream<List<Comment>> watchComments({
    required String postId,
    required String viewerId,
  }) => _watch(() {
    final list =
        _comments
            .where((c) => c.postId == postId)
            .map((c) => _viewComment(c, viewerId))
            .toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  });

  @override
  Future<void> toggleLike({
    required String postId,
    required String userId,
  }) async {
    final likedBy = _likes[postId];
    if (likedBy == null) {
      throw const NotFoundFailure();
    }
    if (!likedBy.remove(userId)) {
      likedBy.add(userId);
    }
    _changes.add(null);
  }

  @override
  Future<void> toggleCommentLike({
    required String commentId,
    required String userId,
  }) async {
    final likedBy = _commentLikes[commentId];
    if (likedBy == null) {
      throw const NotFoundFailure();
    }
    if (!likedBy.remove(userId)) {
      likedBy.add(userId);
    }
    _changes.add(null);
  }

  @override
  Future<Comment> addComment({
    required String postId,
    required String authorId,
    required String body,
  }) async {
    if (!_posts.containsKey(postId)) {
      throw const NotFoundFailure();
    }
    if (body.trim().isEmpty) {
      throw const ValidationFailure(ValidationReason.commentEmpty);
    }
    // 100 comments in any 24 hours, as in add_comment.
    final since = DateTime.now().subtract(const Duration(hours: 24));
    if (_comments
            .where((c) => c.authorId == authorId && c.createdAt.isAfter(since))
            .length >=
        100) {
      throw const ValidationFailure(ValidationReason.dailyCommentLimit);
    }
    _nextComment++;
    final comment = Comment(
      id: 'comment-$_nextComment',
      postId: postId,
      authorId: authorId,
      body: body.trim(),
      createdAt: DateTime.now(),
    );
    _comments.add(comment);
    _commentLikes[comment.id] = <String>{};
    _changes.add(null);
    return comment;
  }

  @override
  Future<Post> createPost({
    required String authorId,
    required String body,
    required PostTag? tag,
    String? imagePath,
  }) async {
    final today = DateTime.now();
    final postsToday = _posts.values
        .where(
          (p) =>
              p.authorId == authorId &&
              p.createdAt.year == today.year &&
              p.createdAt.month == today.month &&
              p.createdAt.day == today.day,
        )
        .length;
    final broken = _rules.validate(
      body: body,
      tag: tag,
      postsToday: postsToday,
    );
    if (broken != null) {
      throw ValidationFailure(broken);
    }
    _nextPost++;
    final post = Post(
      id: 'post-$_nextPost',
      authorId: authorId,
      body: body.trim(),
      tag: tag!,
      createdAt: today,
      imagePath: imagePath,
    );
    _posts[post.id] = post;
    _likes[post.id] = <String>{};
    _otherLikes[post.id] = 0;
    _changes.add(null);
    return _view(post, authorId);
  }
}
