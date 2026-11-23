import 'dart:async';

import '../../../core/logic/discover_visibility_rules.dart';
import '../../models/profile.dart';
import '../discover_repository.dart';
import 'mock_profile_repository.dart';
import 'mock_safety_repository.dart';

/// In-memory [DiscoverRepository] over the mock profiles and blocks.
class MockDiscoverRepository implements DiscoverRepository {
  MockDiscoverRepository(this._profiles, this._safety);

  final MockProfileRepository _profiles;
  final MockSafetyRepository _safety;

  static const DiscoverVisibilityRules _rules = DiscoverVisibilityRules();

  List<Profile> _teachers(String viewerId) => <Profile>[
    for (final p in _profiles.all)
      if (p.id != viewerId &&
          _rules.isTeacherListed(p) &&
          !_safety.blockedEitherWay(viewerId, p.id))
        p,
  ];

  List<Profile> _students(String viewerId) => <Profile>[
    for (final p in _profiles.all)
      if (p.id != viewerId &&
          _rules.isStudentListed(p) &&
          !_safety.blockedEitherWay(viewerId, p.id))
        _withoutPhoto(p),
  ];

  /// Student photos are never shown in the Students list (plan section 7).
  static Profile _withoutPhoto(Profile p) => Profile(
    id: p.id,
    role: p.role,
    fullName: p.fullName,
    createdAt: p.createdAt,
    headline: p.headline,
    gender: p.gender,
    country: p.country,
    city: p.city,
    timeZone: p.timeZone,
    languages: p.languages,
    bio: p.bio,
    isVerified: p.isVerified,
    studentDetails: p.studentDetails,
  );

  Stream<List<Profile>> _watch(List<Profile> Function() read) {
    late final StreamController<List<Profile>> controller;
    final subs = <StreamSubscription<void>>[];
    controller = StreamController<List<Profile>>(
      onListen: () {
        controller.add(read());
        void push(void _) => controller.add(read());
        subs
          ..add(_profiles.changes.listen(push))
          ..add(_safety.changes.listen(push));
      },
      onCancel: () async {
        for (final s in subs) {
          await s.cancel();
        }
      },
    );
    return controller.stream;
  }

  @override
  Stream<List<Profile>> watchTeachers({required String viewerId}) =>
      _watch(() => _teachers(viewerId));

  @override
  Stream<List<Profile>> watchStudents({required String viewerId}) =>
      _watch(() => _students(viewerId));
}
