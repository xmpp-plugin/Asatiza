import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';

import '../../../data/models/post.dart';
import '../../../data/models/profile.dart';

/// 20a / 20c My profile.
class MyProfileState extends Equatable {
  const MyProfileState({
    this.profile,
    this.posts = const <Post>[],
    this.connectionCount = 0,
    this.strengthCardDismissed = false,
    this.loadError,
  });

  final Profile? profile;

  /// The user's own posts, newest first.
  final List<Post> posts;
  final int connectionCount;
  final bool strengthCardDismissed;

  /// Set when the profile could not be loaded (`network` / `unexpected`).
  final ValidationReason? loadError;

  MyProfileState copyWith({
    Profile? profile,
    List<Post>? posts,
    int? connectionCount,
    bool? strengthCardDismissed,
    ValidationReason? loadError,
  }) {
    return MyProfileState(
      profile: profile ?? this.profile,
      posts: posts ?? this.posts,
      connectionCount: connectionCount ?? this.connectionCount,
      strengthCardDismissed:
          strengthCardDismissed ?? this.strengthCardDismissed,
      loadError: loadError ?? this.loadError,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    profile,
    posts,
    connectionCount,
    strengthCardDismissed,
    loadError,
  ];
}
