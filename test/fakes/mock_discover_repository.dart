import 'dart:async';

import 'package:asatiza/core/logic/discover_visibility_rules.dart';
import 'package:asatiza/data/models/profile.dart';
import 'package:asatiza/data/repositories/discover_repository.dart';
import 'package:asatiza/data/repositories/mock/mock_profile_repository.dart';

import 'fake_block_repository.dart';

/// Test-only in-memory [DiscoverRepository] over the mock profiles and
/// blocks (the app uses `SupabaseDiscoverRepository`; moved from `lib/` in
/// PHASE_007).
class MockDiscoverRepository implements DiscoverRepository {
  MockDiscoverRepository(this._profiles, this._blocks);

  final MockProfileRepository _profiles;
  final FakeBlockRepository _blocks;

  static const DiscoverVisibilityRules _rules = DiscoverVisibilityRules();

  List<Profile> _teachers(String viewerId) => <Profile>[
    for (final p in _profiles.all)
      if (p.id != viewerId &&
          _rules.isTeacherListed(p) &&
          !_blocks.blockedEitherWay(viewerId, p.id))
        p,
  ];

  List<Profile> _students(String viewerId) => <Profile>[
    for (final p in _profiles.all)
      if (p.id != viewerId &&
          _rules.isStudentListed(p) &&
          !_blocks.blockedEitherWay(viewerId, p.id))
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
          ..add(_blocks.changes.listen(push));
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
