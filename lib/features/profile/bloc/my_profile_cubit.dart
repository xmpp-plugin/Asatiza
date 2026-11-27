import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/failures.dart';
import '../../../data/models/connection.dart';
import '../../../data/models/enums/connection_status.dart';
import '../../../data/models/post.dart';
import '../../../data/models/profile.dart';
import '../../../data/repositories/connection_repository.dart';
import '../../../data/repositories/feed_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import 'my_profile_state.dart';

/// The signed-in user's own profile, posts and connection count; the
/// "Looking for a teacher" switch saves straight away.
class MyProfileCubit extends Cubit<MyProfileState> {
  MyProfileCubit(
    this._profiles,
    FeedRepository feed,
    ConnectionRepository connections, {
    required this.viewerId,
  }) : super(const MyProfileState()) {
    _profileSub = _profiles
        .watchProfile(viewerId)
        .listen(
          (p) => _emit(state.copyWith(profile: p)),
          onError: (Object e) => _emit(
            state.copyWith(
              loadError: e is Failure
                  ? e.displayReason
                  : ValidationReason.unexpected,
            ),
          ),
        );
    _postsSub = feed
        .watchPostsBy(authorId: viewerId, viewerId: viewerId)
        .listen(
          (posts) => _emit(state.copyWith(posts: posts)),
          onError: (Object _) {},
        );
    _connectionsSub = connections
        .watchConnections(viewerId)
        .listen(
          (list) => _emit(
            state.copyWith(
              connectionCount: list
                  .where((c) => c.status == ConnectionStatus.accepted)
                  .length,
            ),
          ),
          onError: (Object _) {},
        );
  }

  final ProfileRepository _profiles;
  final String viewerId;
  StreamSubscription<Profile>? _profileSub;
  StreamSubscription<List<Post>>? _postsSub;
  StreamSubscription<List<Connection>>? _connectionsSub;

  void _emit(MyProfileState next) {
    if (!isClosed) {
      emit(next);
    }
  }

  Future<void> lookingChanged(bool looking) async {
    final p = state.profile;
    final s = p?.studentDetails;
    if (p == null || s == null) {
      return;
    }
    await _profiles.updateProfile(
      p.copyWith(studentDetails: s.copyWith(lookingForTeacher: looking)),
    );
  }

  @override
  Future<void> close() async {
    await _profileSub?.cancel();
    await _postsSub?.cancel();
    await _connectionsSub?.cancel();
    return super.close();
  }
}
