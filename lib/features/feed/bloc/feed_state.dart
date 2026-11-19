import 'package:equatable/equatable.dart';

import '../../../data/models/post.dart';
import '../../../data/models/profile.dart';

enum FeedStatus { loading, ready }

class FeedState extends Equatable {
  const FeedState({
    this.status = FeedStatus.loading,
    this.posts = const <Post>[],
    this.authors = const <String, Profile>{},
    this.strengthCardDismissed = false,
  });

  final FeedStatus status;

  /// Feed order, without posts from blocked users.
  final List<Post> posts;
  final Map<String, Profile> authors;

  /// The user hid the profile-strength card for this session.
  final bool strengthCardDismissed;

  /// Posts whose author profile is loaded (safe to render).
  List<Post> get visiblePosts =>
      posts.where((p) => authors.containsKey(p.authorId)).toList();

  FeedState copyWith({
    FeedStatus? status,
    List<Post>? posts,
    Map<String, Profile>? authors,
    bool? strengthCardDismissed,
  }) {
    return FeedState(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      authors: authors ?? this.authors,
      strengthCardDismissed:
          strengthCardDismissed ?? this.strengthCardDismissed,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    posts,
    authors,
    strengthCardDismissed,
  ];
}
