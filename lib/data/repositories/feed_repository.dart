import '../models/comment.dart';
import '../models/enums/post_tag.dart';
import '../models/post.dart';

/// Feed posts, likes, comments (plan section 9). The Supabase implementation
/// enforces limits, blocks and auto-hide in the database (PHASE_010). Throws
/// only `Failure` subtypes. Posts hidden by reports are never returned,
/// except to their author (`Post.isUnderReview`).
abstract interface class FeedRepository {
  /// Emits the first [limit] visible posts as seen by [viewerId]
  /// (`likedByMe` set), now and after every change made through this
  /// repository, in feed order (plan section 9): posts from the viewer's
  /// connections first, newest first, then everyone else's, newest first
  /// (see `FeedOrdering`). Ask again with a larger [limit] to load more.
  Stream<List<Post>> watchPosts({required String viewerId, int limit = 20});

  /// [authorId]'s visible posts, newest first (profiles); emits like
  /// [watchPosts].
  Stream<List<Post>> watchPostsBy({
    required String authorId,
    required String viewerId,
  });

  /// Visible posts whose text or tag contains [query], newest first.
  Future<List<Post>> searchPosts({
    required String query,
    required String viewerId,
  });

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

  /// Adds a comment and returns it. Throws `ValidationFailure` with
  /// `commentEmpty` or `dailyCommentLimit` (100 in 24 hours), or
  /// `NotFoundFailure`.
  Future<Comment> addComment({
    required String postId,
    required String authorId,
    required String body,
  });

  /// Deletes [userId]'s own post (with its likes, comments and photo).
  /// Throws `NotFoundFailure` for someone else's post.
  Future<void> deletePost({required String postId, required String userId});

  /// Deletes [userId]'s own comment. Throws `NotFoundFailure` otherwise.
  Future<void> deleteComment({
    required String commentId,
    required String userId,
  });

  /// Publishes a post ([imagePath] from `MediaRepository.uploadPostImage`)
  /// and returns it. Throws `ValidationFailure` with `postEmpty`,
  /// `postTooLong`, `postTagMissing` or `dailyPostLimit` (10 in 24 hours).
  Future<Post> createPost({
    required String authorId,
    required String body,
    required PostTag? tag,
    String? imagePath,
  });
}
