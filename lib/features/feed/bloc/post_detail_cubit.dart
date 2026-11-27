import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/failures.dart';
import '../../../data/models/comment.dart';
import '../../../data/models/post.dart';
import '../../../data/models/profile.dart';
import '../../../data/repositories/feed_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import 'post_detail_state.dart';

/// One post with its comments; like, comment, comment-like and delete
/// (own post / comment) actions.
class PostDetailCubit extends Cubit<PostDetailState> {
  PostDetailCubit(
    this._feed,
    this._profiles, {
    required this.postId,
    required this.viewerId,
  }) : super(const PostDetailState()) {
    _postSub = _feed
        .watchPost(postId: postId, viewerId: viewerId)
        .listen(
          (post) => _onData(post: post),
          onError: (Object _) {
            if (!isClosed) {
              emit(state.copyWith(status: PostDetailStatus.notFound));
            }
          },
        );
    _commentsSub = _feed
        .watchComments(postId: postId, viewerId: viewerId)
        .listen(
          (comments) => _onData(comments: comments),
          onError: (Object _) {},
        );
  }

  final FeedRepository _feed;
  final ProfileRepository _profiles;
  final String postId;
  final String viewerId;

  StreamSubscription<Post>? _postSub;
  StreamSubscription<List<Comment>>? _commentsSub;

  Future<void> _onData({Post? post, List<Comment>? comments}) async {
    final nextPost = post ?? state.post;
    final nextComments = comments ?? state.comments;
    final ids = <String>{
      ?nextPost?.authorId,
      ...nextComments.map((c) => c.authorId),
    }.where((id) => !state.people.containsKey(id));
    var people = state.people;
    if (ids.isNotEmpty) {
      final loaded = await _profiles.getProfiles(ids);
      people = <String, Profile>{...people, for (final p in loaded) p.id: p};
    }
    if (isClosed) {
      return;
    }
    emit(
      state.copyWith(
        status: nextPost == null
            ? PostDetailStatus.loading
            : PostDetailStatus.ready,
        post: nextPost,
        comments: nextComments,
        people: people,
      ),
    );
  }

  Future<void> toggleLike() async {
    try {
      await _feed.toggleLike(postId: postId, userId: viewerId);
    } on Failure {
      // Reflected by the post stream.
    }
  }

  Future<void> toggleCommentLike(String commentId) async {
    try {
      await _feed.toggleCommentLike(commentId: commentId, userId: viewerId);
    } on Failure {
      // Reflected by the comments stream.
    }
  }

  /// Returns true when the comment was posted.
  Future<bool> addComment(String body) async {
    if (body.trim().isEmpty || state.sending) {
      return false;
    }
    emit(state.copyWith(sending: true, error: () => null));
    try {
      await _feed.addComment(postId: postId, authorId: viewerId, body: body);
      return true;
    } on Failure catch (f) {
      _emitError(f.displayReason);
      return false;
    } finally {
      if (!isClosed) {
        emit(state.copyWith(sending: false));
      }
    }
  }

  void _emitError(ValidationReason reason) {
    if (!isClosed) {
      emit(state.copyWith(error: () => reason));
    }
  }

  /// Clears the error after it was shown.
  void errorShown() => emit(state.copyWith(error: () => null));

  /// Deletes the viewer's own post; true when it was deleted.
  Future<bool> deletePost() async {
    try {
      await _feed.deletePost(postId: postId, userId: viewerId);
      return true;
    } on Failure catch (f) {
      _emitError(f.displayReason);
      return false;
    }
  }

  /// Deletes the viewer's own comment.
  Future<void> deleteComment(String commentId) async {
    try {
      await _feed.deleteComment(commentId: commentId, userId: viewerId);
    } on Failure catch (f) {
      _emitError(f.displayReason);
    }
  }

  @override
  Future<void> close() async {
    await _postSub?.cancel();
    await _commentsSub?.cancel();
    return super.close();
  }
}
