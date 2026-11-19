import 'package:equatable/equatable.dart';

import '../../data/models/profile.dart';

/// Who is signed in, and whether they still see profile setup.
class SessionState extends Equatable {
  const SessionState.signedOut() : user = null, needsSetup = false;

  const SessionState.signedIn(Profile this.user, {this.needsSetup = false});

  final Profile? user;

  /// True right after sign-up until setup is finished or skipped.
  final bool needsSetup;

  bool get isSignedIn => user != null;

  @override
  List<Object?> get props => <Object?>[user, needsSetup];
}
