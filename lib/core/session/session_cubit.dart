import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/profile.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/profile_repository.dart';
import 'session_state.dart';

/// App-wide session. Every launch starts signed out (mock data resets).
/// Keeps the signed-in user's profile fresh after edits.
class SessionCubit extends Cubit<SessionState> {
  SessionCubit(this._auth, this._profiles)
    : super(const SessionState.signedOut());

  final AuthRepository _auth;
  final ProfileRepository _profiles;
  StreamSubscription<Profile>? _profileSub;

  /// Called after log-in, code verification or password reset.
  void signedIn(Profile user, {bool needsSetup = false}) {
    emit(SessionState.signedIn(user, needsSetup: needsSetup));
    _profileSub?.cancel();
    _profileSub = _profiles.watchProfile(user.id).listen((profile) {
      if (state.user?.id == profile.id) {
        emit(SessionState.signedIn(profile, needsSetup: state.needsSetup));
      }
    }, onError: (Object _) {});
  }

  /// Profile setup finished or skipped.
  void completeSetup() {
    final user = state.user;
    if (user != null) {
      emit(SessionState.signedIn(user));
    }
  }

  Future<void> logOut() async {
    await _profileSub?.cancel();
    _profileSub = null;
    await _auth.logOut();
    emit(const SessionState.signedOut());
  }

  @override
  Future<void> close() async {
    await _profileSub?.cancel();
    return super.close();
  }
}
