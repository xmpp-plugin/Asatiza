import 'package:equatable/equatable.dart';

import '../../../data/models/profile.dart';
import '../../../data/repositories/safety_repository.dart';

/// 21b Blocked users.
class BlockedUsersState extends Equatable {
  const BlockedUsersState({
    this.loading = true,
    this.blocked = const <BlockedUser>[],
    this.people = const <String, Profile>{},
  });

  final bool loading;

  /// Newest first.
  final List<BlockedUser> blocked;
  final Map<String, Profile> people;

  List<BlockedUser> get visible =>
      blocked.where((b) => people.containsKey(b.userId)).toList();

  BlockedUsersState copyWith({
    bool? loading,
    List<BlockedUser>? blocked,
    Map<String, Profile>? people,
  }) {
    return BlockedUsersState(
      loading: loading ?? this.loading,
      blocked: blocked ?? this.blocked,
      people: people ?? this.people,
    );
  }

  @override
  List<Object?> get props => <Object?>[loading, blocked, people];
}
