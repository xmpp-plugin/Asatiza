import 'package:equatable/equatable.dart';

/// A comment on a post (plan table `post_comments`).
class Comment extends Equatable {
  const Comment({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.body,
    required this.createdAt,
    this.likeCount = 0,
    this.likedByMe = false,
  });

  final String id;
  final String postId;
  final String authorId;
  final String body;
  final DateTime createdAt;
  final int likeCount;
  final bool likedByMe;

  Comment copyWith({int? likeCount, bool? likedByMe}) {
    return Comment(
      id: id,
      postId: postId,
      authorId: authorId,
      body: body,
      createdAt: createdAt,
      likeCount: likeCount ?? this.likeCount,
      likedByMe: likedByMe ?? this.likedByMe,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    postId,
    authorId,
    body,
    createdAt,
    likeCount,
    likedByMe,
  ];
}
