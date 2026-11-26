import 'package:equatable/equatable.dart';

import '../../data/models/profile.dart';

/// Who is signed in, and whether they still see profile setup.
class SessionState extends Equatable {
  const SessionState.signedOut() : user = null;

  const SessionState.signedIn(Profile this.user);

  final Profile? user;

  /// True while the signed-in user's profile is not active (a required
  /// field is empty). Setup cannot be skipped; an unfinished setup resumes
  /// at every log-in (plan section 4).
  bool get needsSetup => user != null && !user!.isActive;

  bool get isSignedIn => user != null;

  @override
  List<Object?> get props => <Object?>[user];
}
