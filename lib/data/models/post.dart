import 'package:equatable/equatable.dart';

import 'enums/post_tag.dart';

/// A feed post (plan table `posts`), as seen by one viewer.
class Post extends Equatable {
  const Post({
    required this.id,
    required this.authorId,
    required this.body,
    required this.tag,
    required this.createdAt,
    this.arabicVerse,
    this.imagePath,
    this.imageUrl,
    this.isUnderReview = false,
    this.likeCount = 0,
    this.commentCount = 0,
    this.likedByMe = false,
  });

  final String id;
  final String authorId;
  final String body;
  final PostTag tag;
  final DateTime createdAt;

  /// Optional Quranic verse shown centred in Amiri, right-to-left.
  final String? arabicVerse;

  /// `post-images` Storage path (test fakes: a bundled illustration asset).
  final String? imagePath;

  /// Public URL of [imagePath], filled by the repository; never written.
  final String? imageUrl;

  /// Hidden by 3 reports; only its author still sees it (PHASE_010).
  final bool isUnderReview;
  final int likeCount;
  final int commentCount;

  /// Whether the current viewer liked the post.
  final bool likedByMe;

  Post copyWith({int? likeCount, int? commentCount, bool? likedByMe}) {
    return Post(
      id: id,
      authorId: authorId,
      body: body,
      tag: tag,
      createdAt: createdAt,
      arabicVerse: arabicVerse,
      imagePath: imagePath,
      imageUrl: imageUrl,
      isUnderReview: isUnderReview,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      likedByMe: likedByMe ?? this.likedByMe,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    authorId,
    body,
    tag,
    createdAt,
    arabicVerse,
    imagePath,
    imageUrl,
    isUnderReview,
    likeCount,
    commentCount,
    likedByMe,
  ];
}
