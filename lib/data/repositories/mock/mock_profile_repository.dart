import 'dart:async';

import '../../../core/errors/failures.dart';
import '../../mock/mock_profiles.dart';
import '../../models/profile.dart';
import '../profile_repository.dart';

/// In-memory [ProfileRepository] seeded with [buildMockProfiles]. State
/// resets when the app restarts.
class MockProfileRepository implements ProfileRepository {
  MockProfileRepository({DateTime? now})
    : _profiles = <String, Profile>{
        for (final p in buildMockProfiles(now ?? DateTime.now())) p.id: p,
      };

  final Map<String, Profile> _profiles;
  final StreamController<void> _changes = StreamController<void>.broadcast();

  /// Mock-layer only: adds a profile created by sign-up or first log-in.
  /// Every stored profile (mock helper for the other mock repositories).
  Iterable<Profile> get all => _profiles.values;

  /// Fires after any profile changes (mock helper).
  Stream<void> get changes => _changes.stream;

  /// Deletes a profile (mock account deletion).
  void remove(String id) {
    _profiles.remove(id);
    _changes.add(null);
  }

  void insert(Profile profile) {
    _profiles[profile.id] = profile;
    _changes.add(null);
  }

  /// Mock-layer only: finds a profile by its email, if any.
  Profile? findByEmail(String email) {
    final lower = email.trim().toLowerCase();
    for (final p in _profiles.values) {
      if (p.email?.toLowerCase() == lower) {
        return p;
      }
    }
    return null;
  }

  @override
  Future<Profile> getProfile(String id) async {
    final profile = _profiles[id];
    if (profile == null) {
      throw const NotFoundFailure();
    }
    return profile;
  }

  @override
  Future<List<Profile>> getProfiles(Iterable<String> ids) async => <Profile>[
    for (final id in ids.toSet()) ?_profiles[id],
  ];

  @override
  Stream<Profile> watchProfile(String id) {
    if (!_profiles.containsKey(id)) {
      return Stream<Profile>.error(const NotFoundFailure());
    }
    late final StreamController<Profile> controller;
    StreamSubscription<void>? changes;
    controller = StreamController<Profile>(
      onListen: () {
        controller.add(_profiles[id]!);
        changes = _changes.stream.listen((_) {
          final profile = _profiles[id];
          if (profile != null) {
            controller.add(profile);
          }
        });
      },
      onCancel: () => changes?.cancel(),
    );
    return controller.stream;
  }

  @override
  Future<Profile> updateProfile(Profile profile) async {
    final current = _profiles[profile.id];
    if (current == null) {
      throw const NotFoundFailure();
    }
    // Role, verification, id and created date are never taken from the app.
    final stored = current.copyWith(
      fullName: profile.fullName,
      email: profile.email,
      headline: profile.headline,
      photoPath: profile.photoPath,
      gender: profile.gender,
      country: profile.country,
      city: profile.city,
      timeZone: profile.timeZone,
      languages: profile.languages,
      bio: profile.bio,
      teacherDetails: profile.teacherDetails,
      studentDetails: profile.studentDetails,
    );
    _profiles[profile.id] = stored;
    _changes.add(null);
    return stored;
  }
}
