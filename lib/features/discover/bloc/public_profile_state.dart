import 'package:equatable/equatable.dart';

import '../../../data/models/connection.dart';
import '../../../data/models/profile.dart';

/// Public profile (artboards 14 / 14b).
class PublicProfileState extends Equatable {
  const PublicProfileState({
    this.profile,
    this.notFound = false,
    this.connection,
    this.connectionCount = 0,
    this.postCount = 0,
    this.blocked = false,
  });

  final Profile? profile;
  final bool notFound;

  /// The viewer's pending or accepted connection with this person.
  final Connection? connection;
  final int connectionCount;
  final int postCount;

  /// The viewer blocked this person (the screen closes).
  final bool blocked;

  PublicProfileState copyWith({
    Profile? profile,
    bool? notFound,
    Connection? Function()? connection,
    int? connectionCount,
    int? postCount,
    bool? blocked,
  }) {
    return PublicProfileState(
      profile: profile ?? this.profile,
      notFound: notFound ?? this.notFound,
      connection: connection != null ? connection() : this.connection,
      connectionCount: connectionCount ?? this.connectionCount,
      postCount: postCount ?? this.postCount,
      blocked: blocked ?? this.blocked,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    profile,
    notFound,
    connection,
    connectionCount,
    postCount,
    blocked,
  ];
}
