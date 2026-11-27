import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/failures.dart';
import '../../models/comment.dart';
import '../../models/enums/media_bucket.dart';
import '../../models/enums/post_tag.dart';
import '../../models/post.dart';
import '../feed_repository.dart';
import 'supabase_failure_mapper.dart';

/// [FeedRepository] on `posts`, `post_likes`, `post_comments`,
/// `comment_likes` (`supabase/migrations/20261202120000_feed.sql`).
///
/// Reads go through RLS (hidden posts only for their author, blocked authors
/// never); writes and the feed / profile / search lists are database
/// functions that enforce the limits. No Realtime: streams load on subscribe
/// and after every change made through this repository (pull-to-refresh
/// re-subscribes).
class SupabaseFeedRepository implements FeedRepository {
  SupabaseFeedRepository(
    this._client, {
    SupabaseFailureMapper failures = const SupabaseFailureMapper(),
  }) : _failures = failures;

  final SupabaseClient _client;
  final SupabaseFailureMapper _failures;
  final StreamController<void> _changes = StreamController<void>.broadcast();

  /// Posts a profile shows; search results.
  static const int profilePosts = 50;
  static const int searchResults = 30;

  String? get _me => _client.auth.currentUser?.id;

  Future<T> _guard<T>(Future<T> Function() run) async {
    try {
      return await run();
    } on PostgrestException catch (error) {
      throw mapError(error.message) ?? _failures.map(error);
    } catch (error) {
      throw _failures.map(error);
    }
  }

  /// The `Failure` for a rule message raised by the feed functions, or null
  /// for anything else.
  @visibleForTesting
  static Failure? mapError(String message) => switch (message) {
    'not_found' => const NotFoundFailure(),
    'post_empty' => const ValidationFailure(ValidationReason.postEmpty),
    'post_too_long' => const ValidationFailure(ValidationReason.postTooLong),
    'post_tag_missing' => const ValidationFailure(
      ValidationReason.postTagMissing,
    ),
    'daily_post_limit' => const ValidationFailure(
      ValidationReason.dailyPostLimit,
    ),
    'comment_empty' => const ValidationFailure(ValidationReason.commentEmpty),
    'daily_comment_limit' => const ValidationFailure(
      ValidationReason.dailyCommentLimit,
    ),
    'comment_too_long' ||
    'invalid_image' ||
    'invalid_report' => const UnexpectedFailure(),
    _ => null,
  };

  /// `tajweedTip` → `tajweed_tip`.
  @visibleForTesting
  static String tagToDb(PostTag tag) => tag.name.replaceAllMapped(
    RegExp('[A-Z]'),
    (m) => '_${m[0]!.toLowerCase()}',
  );

  static PostTag _tagFromDb(Object? value) => PostTag.values.firstWhere(
    (t) => tagToDb(t) == value,
    orElse: () => PostTag.reminder,
  );

  String _publicUrl(String path) =>
      _client.storage.from(MediaBucket.postImages.id).getPublicUrl(path);

  /// Maps a `posts` row (or a `list_feed` / `list_posts_by` /
  /// `search_posts` row, which also has `liked_by_me`).
  @visibleForTesting
  Post postFromRow(Map<String, dynamic> row, {bool? likedByMe}) {
    final path = row['image_path'] as String?;
    return Post(
      id: row['id'] as String,
      authorId: row['author_id'] as String,
      body: row['body'] as String,
      tag: _tagFromDb(row['tag']),
      createdAt: DateTime.parse(row['created_at'] as String),
      arabicVerse: row['arabic_verse'] as String?,
      imagePath: path,
      imageUrl: path == null ? null : _publicUrl(path),
      isUnderReview: (row['is_hidden'] as bool?) ?? false,
      likeCount: (row['like_count'] as int?) ?? 0,
      commentCount: (row['comment_count'] as int?) ?? 0,
      likedByMe: likedByMe ?? (row['liked_by_me'] as bool?) ?? false,
    );
  }

  /// Maps a `post_comments` row.
  @visibleForTesting
  static Comment commentFromRow(
    Map<String, dynamic> row, {
    bool likedByMe = false,
  }) => Comment(
    id: row['id'] as String,
    postId: row['post_id'] as String,
    authorId: row['author_id'] as String,
    body: row['body'] as String,
    createdAt: DateTime.parse(row['created_at'] as String),
    likeCount: (row['like_count'] as int?) ?? 0,
    likedByMe: likedByMe,
  );

  // ------------------------------------------------------------ streams

  /// Emits [load] on subscribe and after every local change; a failed load
  /// arrives as a `Failure` error and the stream keeps listening.
  Stream<T> _watch<T>(Future<T> Function() load) {
    late final StreamController<T> controller;
    StreamSubscription<void>? changes;
    Future<void> push() async {
      try {
        final value = await load();
        if (!controller.isClosed) {
          controller.add(value);
        }
      } on Failure catch (failure) {
        if (!controller.isClosed) {
          controller.addError(failure);
        }
      }
    }

    controller = StreamController<T>(
      onListen: () {
        unawaited(push());
        changes = _changes.stream.listen((_) => unawaited(push()));
      },
      onCancel: () async {
        await changes?.cancel();
        await controller.close();
      },
    );
    return controller.stream;
  }

  Future<List<Post>> _list(String function, Map<String, dynamic> params) =>
      _guard(() async {
        final rows = await _client.rpc<List<dynamic>>(function, params: params);
        return <Post>[
          for (final row in rows) postFromRow(row as Map<String, dynamic>),
        ];
      });

  @override
  Stream<List<Post>> watchPosts({required String viewerId, int limit = 20}) =>
      _watch(
        () => _list('list_feed', <String, dynamic>{
          'p_limit': limit,
          'p_offset': 0,
        }),
      );

  @override
  Stream<List<Post>> watchPostsBy({
    required String authorId,
    required String viewerId,
  }) => _watch(
    () => _list('list_posts_by', <String, dynamic>{
      'p_author': authorId,
      'p_limit': profilePosts,
    }),
  );

  @override
  Future<List<Post>> searchPosts({
    required String query,
    required String viewerId,
  }) => query.trim().isEmpty
      ? Future<List<Post>>.value(const <Post>[])
      : _list('search_posts', <String, dynamic>{
          'p_query': query.trim(),
          'p_limit': searchResults,
        });

  @override
  Stream<Post> watchPost({required String postId, required String viewerId}) =>
      _watch(
        () => _guard(() async {
          final row = await _client
              .from('posts')
              .select()
              .eq('id', postId)
              .maybeSingle();
          if (row == null) {
            throw const NotFoundFailure();
          }
          final liked = await _client
              .from('post_likes')
              .select('post_id')
              .eq('post_id', postId)
              .eq('user_id', viewerId)
              .maybeSingle();
          return postFromRow(row, likedByMe: liked != null);
        }),
      );

  @override
  Stream<List<Comment>> watchComments({
    required String postId,
    required String viewerId,
  }) => _watch(
    () => _guard(() async {
      final rows = await _client
          .from('post_comments')
          .select()
          .eq('post_id', postId)
          .order('created_at');
      final ids = <String>[for (final r in rows) r['id'] as String];
      final liked = ids.isEmpty
          ? const <String>{}
          : <String>{
              for (final r
                  in await _client
                      .from('comment_likes')
                      .select('comment_id')
                      .eq('user_id', viewerId)
                      .inFilter('comment_id', ids))
                r['comment_id'] as String,
            };
      return <Comment>[
        for (final r in rows)
          commentFromRow(r, likedByMe: liked.contains(r['id'])),
      ];
    }),
  );

  // ------------------------------------------------------------ writes

  void _checkMe(String userId) {
    if (userId != _me) {
      throw const NotFoundFailure();
    }
  }

  Future<T> _write<T>(Future<T> Function() run) async {
    final result = await _guard(run);
    _changes.add(null);
    return result;
  }

  @override
  Future<void> toggleLike({required String postId, required String userId}) {
    _checkMe(userId);
    return _write(
      () => _client.rpc<bool>(
        'toggle_post_like',
        params: <String, dynamic>{'p_id': postId},
      ),
    );
  }

  @override
  Future<void> toggleCommentLike({
    required String commentId,
    required String userId,
  }) {
    _checkMe(userId);
    return _write(
      () => _client.rpc<bool>(
        'toggle_comment_like',
        params: <String, dynamic>{'p_id': commentId},
      ),
    );
  }

  @override
  Future<Comment> addComment({
    required String postId,
    required String authorId,
    required String body,
  }) async {
    _checkMe(authorId);
    if (body.trim().isEmpty) {
      throw const ValidationFailure(ValidationReason.commentEmpty);
    }
    final row = await _write(
      () => _client.rpc<Map<String, dynamic>>(
        'add_comment',
        params: <String, dynamic>{'p_post': postId, 'p_body': body.trim()},
      ),
    );
    return commentFromRow(row);
  }

  @override
  Future<void> deleteComment({
    required String commentId,
    required String userId,
  }) {
    _checkMe(userId);
    return _write(
      () => _client.rpc<void>(
        'delete_comment',
        params: <String, dynamic>{'p_id': commentId},
      ),
    );
  }

  @override
  Future<void> deletePost({
    required String postId,
    required String userId,
  }) async {
    _checkMe(userId);
    final imagePath = await _write(
      () => _client.rpc<String?>(
        'delete_post',
        params: <String, dynamic>{'p_id': postId},
      ),
    );
    if (imagePath != null && imagePath.isNotEmpty) {
      // Best effort: a photo that cannot be removed stays as an orphan.
      try {
        await _client.storage.from(MediaBucket.postImages.id).remove(<String>[
          imagePath,
        ]);
      } catch (_) {}
    }
  }

  @override
  Future<Post> createPost({
    required String authorId,
    required String body,
    required PostTag? tag,
    String? imagePath,
  }) async {
    _checkMe(authorId);
    final row = await _write(
      () => _client.rpc<Map<String, dynamic>>(
        'create_post',
        params: <String, dynamic>{
          'p_body': body,
          'p_tag': tag == null ? null : tagToDb(tag),
          'p_image_path': imagePath,
          'p_arabic_verse': null,
        },
      ),
    );
    return postFromRow(row);
  }
}
