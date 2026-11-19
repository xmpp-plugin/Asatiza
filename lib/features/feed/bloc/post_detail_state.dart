import 'package:equatable/equatable.dart';

import '../../../data/models/comment.dart';
import '../../../data/models/post.dart';
import '../../../data/models/profile.dart';

enum PostDetailStatus { loading, ready, notFound }

class PostDetailState extends Equatable {
  const PostDetailState({
    this.status = PostDetailStatus.loading,
    this.post,
    this.comments = const <Comment>[],
    this.people = const <String, Profile>{},
    this.sending = false,
  });

  final PostDetailStatus status;
  final Post? post;

  /// Oldest first.
  final List<Comment> comments;

  /// Post author and comment authors by id.
  final Map<String, Profile> people;
  final bool sending;

  Profile? get author => post == null ? null : people[post!.authorId];

  PostDetailState copyWith({
    PostDetailStatus? status,
    Post? post,
    List<Comment>? comments,
    Map<String, Profile>? people,
    bool? sending,
  }) {
    return PostDetailState(
      status: status ?? this.status,
      post: post ?? this.post,
      comments: comments ?? this.comments,
      people: people ?? this.people,
      sending: sending ?? this.sending,
    );
  }

  @override
  List<Object?> get props => <Object?>[status, post, comments, people, sending];
}
