import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/profile.dart';
import '../errors/failures.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/profile_repository.dart';
import 'session_state.dart';

/// App-wide session. Starts signed out; [restore] signs back in with a
/// session kept from an earlier launch (backend mode; the mock never keeps
/// one). Keeps the signed-in user's profile fresh after edits.
class SessionCubit extends Cubit<SessionState> {
  SessionCubit(this._auth, this._profiles)
    : super(const SessionState.signedOut());

  final AuthRepository _auth;
  final ProfileRepository _profiles;
  StreamSubscription<Profile>? _profileSub;

  /// Called once by Splash. A failure (e.g. offline) leaves the user signed
  /// out for this launch; the stored session is kept for the next one.
  Future<void> restore() async {
    try {
      final user = await _auth.restoreSession();
      if (user != null && !isClosed && !state.isSignedIn) {
        signedIn(user);
      }
    } on Failure {
      // Stay signed out.
    }
  }

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
