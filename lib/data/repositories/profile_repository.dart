import '../models/profile.dart';

/// Reading and updating profiles (my profile, setup, edit, other users).
///
/// Provisional contract (PHASE_002). Throws only `Failure` subtypes.
abstract interface class ProfileRepository {
  /// Returns the profile with [id]. Throws `NotFoundFailure`.
  Future<Profile> getProfile(String id);

  /// Profiles for several ids, in no particular order; unknown ids are
  /// skipped. Never throws for missing ids.
  Future<List<Profile>> getProfiles(Iterable<String> ids);

  /// Emits the profile with [id] now and after every change.
  Stream<Profile> watchProfile(String id);

  /// Saves the user's own editable fields and returns the stored profile.
  /// Role and verification are never changed by the app.
  /// Throws `NotFoundFailure`.
  Future<Profile> updateProfile(Profile profile);
}
