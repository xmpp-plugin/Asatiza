import '../models/comment.dart';
import '../models/enums/post_tag.dart';
import '../models/post.dart';

/// Feed posts, likes and comments.
///
/// Provisional contract (PHASE_002). Throws only `Failure` subtypes.
/// Hidden posts are never returned.
abstract interface class FeedRepository {
  /// Emits all visible posts as seen by [viewerId] (`likedByMe` set), now and
  /// after every change, in feed order (plan section 9): posts from the
  /// viewer's connections first, newest first, then everyone else's, newest
  /// first (see `FeedOrdering`).
  Stream<List<Post>> watchPosts({required String viewerId});

  /// Emits one post for [viewerId]. Errors with `NotFoundFailure`.
  Stream<Post> watchPost({required String postId, required String viewerId});

  /// Emits a post's comments, oldest first, now and after every change.
  Stream<List<Comment>> watchComments({
    required String postId,
    required String viewerId,
  });

  /// Likes or unlikes [postId] for [userId]. Throws `NotFoundFailure`.
  Future<void> toggleLike({required String postId, required String userId});

  /// Likes or unlikes a comment. Throws `NotFoundFailure`.
  Future<void> toggleCommentLike({
    required String commentId,
    required String userId,
  });

  /// Adds a comment and returns it. Throws `ValidationFailure(commentEmpty)`
  /// or `NotFoundFailure`.
  Future<Comment> addComment({
    required String postId,
    required String authorId,
    required String body,
  });

  /// Publishes a post and returns it. Throws `ValidationFailure` with
  /// `postEmpty`, `postTooLong`, `postTagMissing` or `dailyPostLimit`.
  Future<Post> createPost({
    required String authorId,
    required String body,
    required PostTag? tag,
    String? imagePath,
  });
}
