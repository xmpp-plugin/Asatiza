import 'dart:async';

import 'package:asatiza/core/errors/failures.dart';
import 'package:asatiza/core/logic/discover_visibility_rules.dart';
import 'package:asatiza/core/logic/profile_completeness_rules.dart';
import 'package:asatiza/data/mock/mock_profiles.dart';
import 'package:asatiza/data/models/enums/connection_status.dart';
import 'package:asatiza/data/models/enums/experience_filter.dart';
import 'package:asatiza/data/models/enums/gender.dart';
import 'package:asatiza/data/models/enums/learner_age_group.dart';
import 'package:asatiza/data/models/enums/subject.dart';
import 'package:asatiza/data/models/profile.dart';
import 'package:asatiza/data/repositories/discover_repository.dart';
import 'package:asatiza/data/repositories/mock/mock_connection_repository.dart';
import '../fakes/mock_discover_repository.dart';
import 'package:asatiza/data/repositories/mock/mock_profile_repository.dart';
import 'package:asatiza/features/connections/bloc/connect_request_cubit.dart';
import 'package:asatiza/features/connections/bloc/connections_cubit.dart';
import 'package:asatiza/features/connections/logic/connect_note_rules.dart';
import 'package:asatiza/features/connections/presentation/connections_screen.dart';
import 'package:asatiza/features/discover/bloc/discover_cubit.dart';
import 'package:asatiza/features/discover/bloc/discover_state.dart';
import 'package:asatiza/features/discover/logic/daily_shuffle.dart';
import 'package:asatiza/features/discover/logic/student_filter.dart';
import 'package:asatiza/features/discover/logic/teacher_filter.dart';
import 'package:asatiza/features/discover/presentation/discover_screen.dart';
import 'package:asatiza/features/discover/presentation/public_profile_screen.dart';
import 'package:asatiza/features/discover/presentation/search_results_screen.dart';
import 'package:asatiza/features/discover/presentation/widgets/student_card.dart';
import 'package:asatiza/features/discover/presentation/widgets/teacher_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../helpers/test_app.dart';
import '../fakes/fake_block_repository.dart';
import 'package:asatiza/data/repositories/connection_repository.dart';
import 'package:asatiza/data/models/connection.dart';

Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 20));

String subjectName(Subject s) => s.name;

void main() {
  final now = DateTime(2026, 11, 23);
  const completeness = ProfileCompletenessRules();
  // Seed people with their status, as the mock repository stores them.
  final seed = <Profile>[
    for (final p in buildMockProfiles(now))
      p.copyWith(isActive: completeness.isComplete(p)),
  ];
  Profile byId(String id) => seed.firstWhere((p) => p.id == id);
  const rules = DiscoverVisibilityRules();

  group('logic', () {
    test('every active teacher is listed, verified or not', () {
      final listed = seed.where(rules.isTeacherListed).toList();
      expect(listed, isNotEmpty);
      expect(listed.any((p) => !p.isVerified), isTrue);
      expect(rules.isTeacherListed(byId(MockIds.ahmed)), isTrue);
      final incomplete = byId(MockIds.ahmed).copyWith(isActive: false);
      expect(rules.isTeacherListed(incomplete), isFalse);
      expect(rules.canSendRequest(incomplete), isFalse);
    });

    test('every active student is listed; Looking is information only', () {
      final bilal = byId(MockIds.bilalKhan);
      expect(bilal.studentDetails!.lookingForTeacher, isFalse);
      expect(rules.isStudentListed(bilal), isTrue);
      expect(rules.isStudentListed(byId(MockIds.sana)), isTrue);
      expect(rules.isStudentListed(byId(MockIds.ahmed)), isFalse);
    });

    test('teacher filter: query, subject, gender, experience, fee', () {
      final teachers = seed.where(rules.isTeacherListed).toList();
      final maryam = const TeacherFilter(
        query: 'sisters',
      ).apply(teachers, subjectName);
      expect(maryam.map((p) => p.id), contains(MockIds.maryam));

      final female = const TeacherFilter(
        gender: Gender.female,
        subjects: {Subject.hifz},
      ).apply(teachers, subjectName);
      expect(female, isNotEmpty);
      expect(
        female.every(
          (p) =>
              p.gender == Gender.female &&
              p.teacherDetails!.subjects.contains(Subject.hifz),
        ),
        isTrue,
      );

      final senior = const TeacherFilter(
        experience: ExperienceFilter.tenPlus,
      ).apply(teachers, subjectName);
      expect(
        senior.every((p) => p.teacherDetails!.experienceYears! >= 10),
        isTrue,
      );

      final cheap = const TeacherFilter(
        feeMin: 10,
        feeMax: 30,
      ).apply(teachers, subjectName);
      expect(cheap, isNotEmpty);
      expect(cheap.every((p) => p.teacherDetails!.feeAmount! <= 30), isTrue);
    });

    test('teacher filter counts active filters and reset keeps the query', () {
      const f = TeacherFilter(
        query: 'q',
        subjects: {Subject.tajweed},
        gender: Gender.female,
        feeMin: 20,
        teachesChildren: true,
      );
      expect(f.activeCount, 4);
      expect(f.reset(), const TeacherFilter(query: 'q'));
    });

    test('daily shuffle: same order all day, new order the next day', () {
      final teachers = seed.where((p) => p.isTeacher).toList();
      List<String> order(String viewer, DateTime day) => DailyShuffle(
        viewerId: viewer,
        day: day,
      ).apply(teachers).map((p) => p.id).toList();
      final morning = order(MockIds.ayesha, DateTime(2026, 11, 26, 8));
      expect(order(MockIds.ayesha, DateTime(2026, 11, 26, 23)), morning);
      expect(order(MockIds.ayesha, DateTime(2026, 11, 27, 8)), isNot(morning));
      expect(order(MockIds.hira, DateTime(2026, 11, 26, 8)), isNot(morning));
      expect(morning.toSet(), teachers.map((p) => p.id).toSet());
      // Removing one person keeps the others in the same relative order.
      final fewer = DailyShuffle(
        viewerId: MockIds.ayesha,
        day: DateTime(2026, 11, 26),
      ).apply(teachers.skip(1)).map((p) => p.id).toList();
      expect(fewer, morning.where((id) => id != teachers.first.id).toList());
    });

    test('student filter: age group and newest first', () {
      final students = seed.where(rules.isStudentListed).toList();
      final children = const StudentFilter(
        ageGroups: {LearnerAgeGroup.child},
      ).apply(students, subjectName);
      expect(
        children.every(
          (p) => p.studentDetails!.ageGroup == LearnerAgeGroup.child,
        ),
        isTrue,
      );
      // No sort: the filter keeps the given order (DailyShuffle's).
      final kept = const StudentFilter().apply(students, subjectName);
      expect(kept.map((p) => p.id), students.map((p) => p.id));
    });

    test('connect note: trimmed, at most 200 characters', () {
      const r = ConnectNoteRules();
      expect(r.normalise('  '), isNull);
      expect(r.isValid('a' * 200), isTrue);
      expect(r.isValid('a' * 201), isFalse);
    });
  });

  group('mocks', () {
    late MockProfileRepository profiles;
    late FakeBlockRepository blocks;
    late MockDiscoverRepository discover;
    late MockConnectionRepository connections;

    setUp(() {
      profiles = MockProfileRepository(now: now);
      blocks = FakeBlockRepository();
      discover = MockDiscoverRepository(profiles, blocks);
      connections = MockConnectionRepository(profiles, now: now);
    });

    test('blocking hides a teacher from the list both ways', () async {
      final before = await discover
          .watchTeachers(viewerId: MockIds.ayesha)
          .first;
      expect(before.any((p) => p.id == MockIds.usman), isTrue);
      await blocks.blockUser(
        blockerId: MockIds.usman,
        blockedId: MockIds.ayesha,
      );
      final after = await discover
          .watchTeachers(viewerId: MockIds.ayesha)
          .first;
      expect(after.any((p) => p.id == MockIds.usman), isFalse);
    });

    test('students list never carries photos', () async {
      final students = await discover
          .watchStudents(viewerId: MockIds.ahmed)
          .first;
      expect(students, isNotEmpty);
      expect(students.every((p) => p.photoPath == null), isTrue);
    });

    test('request lifecycle: send, duplicate, accept, remove', () async {
      final c = await connections.sendRequest(
        requesterId: MockIds.ayesha,
        receiverId: MockIds.zainab,
        note: '  Assalamu alaikum  ',
      );
      expect(c.status, ConnectionStatus.pending);
      expect(c.note, 'Assalamu alaikum');
      await expectLater(
        connections.sendRequest(
          requesterId: MockIds.ayesha,
          receiverId: MockIds.zainab,
        ),
        throwsA(const ValidationFailure(ValidationReason.alreadyConnected)),
      );
      await connections.respond(
        connectionId: c.id,
        userId: MockIds.zainab,
        accept: true,
      );
      expect(
        connections.acceptedIdsOf(MockIds.ayesha),
        contains(MockIds.zainab),
      );
      await connections.remove(connectionId: c.id, userId: MockIds.ayesha);
      expect(
        connections.acceptedIdsOf(MockIds.ayesha),
        isNot(contains(MockIds.zainab)),
      );
    });

    test('long note and incomplete sender are rejected', () async {
      await expectLater(
        connections.sendRequest(
          requesterId: MockIds.ayesha,
          receiverId: MockIds.zainab,
          note: 'a' * 201,
        ),
        throwsA(const ValidationFailure(ValidationReason.connectNoteTooLong)),
      );
      final ayesha = await profiles.getProfile(MockIds.ayesha);
      profiles.insert(
        Profile(
          id: 'new-student',
          role: ayesha.role,
          fullName: 'Amna Rauf',
          createdAt: now,
        ),
      );
      await expectLater(
        connections.sendRequest(
          requesterId: 'new-student',
          receiverId: MockIds.zainab,
        ),
        throwsA(const ValidationFailure(ValidationReason.profileIncomplete)),
      );
    });

    test('accepted seed connections match the feed connections', () {
      expect(
        connections.acceptedIdsOf(MockIds.ayesha),
        mockConnectedIds(MockIds.ayesha),
      );
      expect(
        connections.acceptedIdsOf(MockIds.ahmed),
        mockConnectedIds(MockIds.ahmed),
      );
    });

    test('discover cubit filters and counts', () async {
      final cubit = DiscoverCubit(
        discover,
        connections,
        viewerId: MockIds.ayesha,
        showTeachers: true,
        subjectLabel: subjectName,
      );
      await settle();
      final all = cubit.state.results.length;
      expect(all, greaterThan(5));
      const female = TeacherFilter(gender: Gender.female);
      final count = cubit.countTeachers(female);
      cubit.teacherFilterChanged(female);
      expect(cubit.state.results.length, count);
      expect(cubit.state.activeFilterCount, 1);
      expect(cubit.state.connectionWith(MockIds.ahmed), isNotNull);
      await cubit.close();
    });

    test(
      'discover cubit: refresh picks up a request accepted elsewhere',
      () async {
        // Like Supabase without Realtime: each subscription loads once.
        final snapshot = _SnapshotConnections(connections);
        final cubit = DiscoverCubit(
          discover,
          snapshot,
          viewerId: MockIds.ayesha,
          showTeachers: true,
          subjectLabel: subjectName,
        );
        final sent = await connections.sendRequest(
          requesterId: MockIds.ayesha,
          receiverId: MockIds.zainab,
        );
        await cubit.refresh();
        await settle();
        expect(
          cubit.state.connectionWith(MockIds.zainab)?.status,
          ConnectionStatus.pending,
        );
        // Zainab accepts on her own device.
        await connections.respond(
          connectionId: sent.id,
          userId: MockIds.zainab,
          accept: true,
        );
        await settle();
        expect(
          cubit.state.connectionWith(MockIds.zainab)?.status,
          ConnectionStatus.pending,
          reason: 'no live update without Realtime',
        );
        await cubit.refresh();
        await settle();
        expect(
          cubit.state.connectionWith(MockIds.zainab)?.status,
          ConnectionStatus.accepted,
        );
        await cubit.close();
      },
    );

    test('discover cubit shows an error and refresh reloads', () async {
      final flaky = _FlakyDiscover(discover);
      final cubit = DiscoverCubit(
        flaky,
        connections,
        viewerId: MockIds.ayesha,
        showTeachers: true,
        subjectLabel: subjectName,
      );
      await settle();
      expect(cubit.state.status, DiscoverStatus.error);
      cubit.teacherFilterChanged(const TeacherFilter(gender: Gender.female));
      await cubit.refresh();
      expect(cubit.state.status, DiscoverStatus.ready);
      expect(cubit.state.all, isNotEmpty);
      // Filters survive the reload.
      expect(cubit.state.activeFilterCount, 1);
      expect(
        cubit.state.results.every((p) => p.gender == Gender.female),
        isTrue,
      );
      await cubit.close();
    });

    test('connect request cubit sends once and reports errors', () async {
      final cubit = ConnectRequestCubit(
        connections,
        requesterId: MockIds.ayesha,
        receiverId: MockIds.ahmed,
      );
      await cubit.send();
      expect(cubit.state.error, ValidationReason.alreadyConnected);
      final fresh = ConnectRequestCubit(
        connections,
        requesterId: MockIds.ayesha,
        receiverId: MockIds.zainab,
      )..noteChanged('Assalamu alaikum');
      await fresh.send();
      expect(fresh.state.sent, isTrue);
      await cubit.close();
      await fresh.close();
    });

    test('connect request: a receiver who is not active is refused', () async {
      final zainab = await profiles.getProfile(MockIds.zainab);
      await profiles.updateProfile(zainab.copyWith(timeZone: ''));
      final cubit = ConnectRequestCubit(
        connections,
        requesterId: MockIds.ayesha,
        receiverId: MockIds.zainab,
      );
      await cubit.send();
      expect(cubit.state.error, ValidationReason.receiverNotActive);
      expect(cubit.state.sent, isFalse);
      await cubit.close();
    });

    test('connection count of another profile', () async {
      expect(
        await connections.connectionCount(MockIds.ahmed),
        mockConnectedIds(MockIds.ahmed).length,
      );
    });

    test('connections cubit: requests tab accept moves to connected', () async {
      final cubit = ConnectionsCubit(
        connections,
        profiles,
        blocks,
        viewerId: MockIds.ahmed,
      );
      await settle();
      expect(cubit.state.requests.length, 2);
      final before = cubit.state.connected.length;
      await cubit.respond(cubit.state.requests.first, accept: true);
      await settle();
      expect(cubit.state.requests.length, 1);
      expect(cubit.state.connected.length, before + 1);
      await cubit.close();
    });
  });

  group('screens', () {
    testWidgets('Teachers: search, filter sheet, profile, connect', (
      tester,
    ) async {
      final app = TestApp();
      await app.startSignedIn(tester);
      await tester.tap(find.bySemanticsLabel('Teachers'));
      await tester.pumpAndSettle();
      expect(find.byType(DiscoverScreen), findsOneWidget);
      expect(find.byType(TeacherCard), findsWidgets);
      // List header: count only (no "verified" / "most complete" text).
      expect(find.textContaining(RegExp(r'^\d+ teachers$')), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Zainab');
      await tester.pumpAndSettle();
      expect(find.text('Ustadha Zainab Malik'), findsOneWidget);
      expect(find.byType(TeacherCard), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Filters'));
      await tester.pumpAndSettle();
      expect(find.text('Monthly fee'), findsOneWidget);
      await tapText(tester, 'Male');
      expect(find.text('No teachers to show'), findsOneWidget);
      await tapText(tester, 'No teachers to show');
      expect(find.text('Nobody matches these filters'), findsNothing);
      expect(find.text('No results for “Zainab”'), findsOneWidget);
      await tapText(tester, 'Clear filters');
      expect(find.byType(TeacherCard), findsWidgets);

      await tester.enterText(find.byType(TextField), 'Zainab');
      await tester.pumpAndSettle();
      await tapText(tester, 'View profile');
      expect(find.byType(PublicProfileScreen), findsOneWidget);
      expect(find.text('Connect first to send a message'), findsOneWidget);
      await tapText(tester, 'Connect');
      expect(find.text('Connect with Ustadha Zainab'), findsOneWidget);
      await tapText(tester, 'Send request');
      // Plan section 7: a sent request shows "Pending".
      expect(find.text('Pending'), findsOneWidget);
      await app.stop(tester);
    });

    testWidgets('Message on a connection says chat is coming soon', (
      tester,
    ) async {
      final app = TestApp();
      await app.startSignedIn(tester);
      await tester.tap(find.bySemanticsLabel('Teachers'));
      await tester.pumpAndSettle();
      // Ayesha is connected to Qari Ahmed in the sample data.
      await tester.enterText(find.byType(TextField), 'Qari Ahmed');
      await tester.pumpAndSettle();
      await tapText(tester, 'Message');
      expect(find.text('Chat is coming soon.'), findsOneWidget);
      await app.stop(tester);
    });

    testWidgets('teacher account: Students tab and requests', (tester) async {
      final app = TestApp();
      await app.startSignedIn(tester, teacher: true);
      await tester.tap(find.bySemanticsLabel('Students'));
      await tester.pumpAndSettle();
      expect(find.byType(StudentCard), findsWidgets);
      expect(find.textContaining(RegExp(r'^\d+ students$')), findsOneWidget);

      GoRouter.of(
        tester.element(find.byType(DiscoverScreen)),
      ).push('/connections');
      await tester.pumpAndSettle();
      expect(find.byType(ConnectionsScreen), findsOneWidget);
      await tapText(tester, 'Requests 2');
      expect(find.text('Omar Farooq'), findsOneWidget);
      await tapText(tester, 'Accept');
      expect(find.text('Requests 1'), findsOneWidget);
      await app.stop(tester);
    });

    testWidgets('Home search: teachers and posts', (tester) async {
      final app = TestApp();
      await app.startSignedIn(tester);
      await tester.tap(
        find.bySemanticsLabel('Search teachers, posts, subjects'),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SearchResultsScreen), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Tajweed');
      await tester.pumpAndSettle();
      expect(find.textContaining('See all'), findsWidgets);
      await tester.enterText(find.byType(TextField), 'Qiraat zzz');
      await tester.pumpAndSettle();
      expect(find.text('No results for “Qiraat zzz”'), findsOneWidget);
      unawaited(Future<void>.value());
      await app.stop(tester);
    });
  });
}

/// Fails the first teachers load, then delegates to [_inner].
class _FlakyDiscover implements DiscoverRepository {
  _FlakyDiscover(this._inner);

  final DiscoverRepository _inner;
  bool _failed = false;

  @override
  Stream<List<Profile>> watchTeachers({required String viewerId}) {
    if (!_failed) {
      _failed = true;
      return Stream<List<Profile>>.error(const NetworkFailure());
    }
    return _inner.watchTeachers(viewerId: viewerId);
  }

  @override
  Stream<List<Profile>> watchStudents({required String viewerId}) =>
      _inner.watchStudents(viewerId: viewerId);
}

/// Emits [_inner]'s connections once per subscription (no later updates),
/// like `SupabaseConnectionRepository` for changes made on another device.
class _SnapshotConnections implements ConnectionRepository {
  _SnapshotConnections(this._inner);

  final ConnectionRepository _inner;

  @override
  Stream<List<Connection>> watchConnections(String userId) =>
      _inner.watchConnections(userId).take(1);

  @override
  Future<Connection> sendRequest({
    required String requesterId,
    required String receiverId,
    String? note,
  }) => _inner.sendRequest(
    requesterId: requesterId,
    receiverId: receiverId,
    note: note,
  );

  @override
  Future<void> respond({
    required String connectionId,
    required String userId,
    required bool accept,
  }) => _inner.respond(
    connectionId: connectionId,
    userId: userId,
    accept: accept,
  );

  @override
  Future<void> remove({required String connectionId, required String userId}) =>
      _inner.remove(connectionId: connectionId, userId: userId);

  @override
  Future<int> connectionCount(String userId) => _inner.connectionCount(userId);
}
