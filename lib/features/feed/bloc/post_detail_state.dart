import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';

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
    this.error,
  });

  final PostDetailStatus status;
  final Post? post;

  /// Oldest first.
  final List<Comment> comments;

  /// Post author and comment authors by id.
  final Map<String, Profile> people;
  final bool sending;

  /// Why the last comment failed (shown once); null otherwise.
  final ValidationReason? error;

  Profile? get author => post == null ? null : people[post!.authorId];

  PostDetailState copyWith({
    PostDetailStatus? status,
    Post? post,
    List<Comment>? comments,
    Map<String, Profile>? people,
    bool? sending,
    ValidationReason? Function()? error,
  }) {
    return PostDetailState(
      status: status ?? this.status,
      post: post ?? this.post,
      comments: comments ?? this.comments,
      people: people ?? this.people,
      sending: sending ?? this.sending,
      error: error != null ? error() : this.error,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    post,
    comments,
    people,
    sending,
    error,
  ];
}
