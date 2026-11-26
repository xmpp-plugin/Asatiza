import 'package:asatiza/core/errors/failures.dart';
import 'package:asatiza/core/logic/profile_completeness_rules.dart';
import 'package:asatiza/data/mock/mock_profiles.dart';
import 'package:asatiza/data/models/enums/gender.dart';
import 'package:asatiza/data/models/enums/learner_age_group.dart';
import 'package:asatiza/data/models/enums/learner_level.dart';
import 'package:asatiza/data/models/enums/subject.dart';
import 'package:asatiza/data/models/enums/teacher_gender_preference.dart';
import 'package:asatiza/data/models/enums/teaching_language.dart';
import 'package:asatiza/data/models/student_details.dart';
import 'package:asatiza/data/repositories/mock/mock_chat_repository.dart';
import 'package:asatiza/data/repositories/mock/mock_connection_repository.dart';
import 'package:asatiza/data/repositories/mock/mock_feed_repository.dart';
import 'package:asatiza/data/repositories/mock/mock_notification_repository.dart';
import 'package:asatiza/data/repositories/mock/mock_profile_repository.dart';
import 'package:asatiza/data/repositories/mock/mock_safety_repository.dart';
import '../fakes/mock_auth_repository.dart';
import 'package:asatiza/features/profile/bloc/edit_profile_cubit.dart';
import 'package:asatiza/features/profile/bloc/my_profile_cubit.dart';
import 'package:asatiza/features/profile/presentation/edit_profile_screen.dart';
import 'package:asatiza/features/profile/presentation/my_profile_screen.dart';
import 'package:asatiza/features/settings/bloc/change_password_cubit.dart';
import 'package:asatiza/features/settings/bloc/delete_account_cubit.dart';
import 'package:asatiza/features/settings/bloc/settings_cubit.dart';
import 'package:asatiza/features/settings/presentation/blocked_users_screen.dart';
import 'package:asatiza/features/settings/presentation/policy_screen.dart';
import 'package:asatiza/features/settings/presentation/settings_screen.dart';
import '../fakes/mock_media_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../helpers/test_app.dart';
import '../fakes/fake_block_repository.dart';

Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 20));

void main() {
  final now = DateTime(2026, 11, 23, 18);
  late MockProfileRepository profiles;
  late MockFeedRepository feed;
  late MockSafetyRepository safety;
  late FakeBlockRepository blocks;
  late MockConnectionRepository connections;
  late MockChatRepository chats;
  late MockNotificationRepository notifications;
  late MockAuthRepository auth;

  setUp(() {
    profiles = MockProfileRepository(now: now);
    feed = MockFeedRepository(now: now);
    safety = MockSafetyRepository();
    blocks = FakeBlockRepository(clock: () => now);
    connections = MockConnectionRepository(profiles, now: now);
    chats = MockChatRepository(connections, now: now);
    notifications = MockNotificationRepository(now: now);
    auth = MockAuthRepository(
      profiles,
      onDelete: (id) {
        feed.removeUser(id);
        chats.removeUser(id);
        connections.removeUser(id);
        notifications.removeUser(id);
        safety.removeUser(id);
        blocks.removeUser(id);
      },
    );
  });

  group('mocks', () {
    test('change password rules', () async {
      Future<void> change(String current, String next, String confirm) =>
          auth.changePassword(
            currentPassword: current,
            newPassword: next,
            confirmation: confirm,
          );
      await expectLater(
        change('short', 'newpass2026', 'newpass2026'),
        throwsA(const ValidationFailure(ValidationReason.wrongCredentials)),
      );
      await expectLater(
        change('password1', 'password1', 'password1'),
        throwsA(const ValidationFailure(ValidationReason.passwordUnchanged)),
      );
      await expectLater(
        change('password1', 'newpass2026', 'newpass2027'),
        throwsA(const ValidationFailure(ValidationReason.passwordsDoNotMatch)),
      );
      await change('password1', 'newpass2026', 'newpass2026');
    });

    test('delete account removes the user everywhere', () async {
      await auth.deleteAccount(MockIds.ayesha);
      await expectLater(
        profiles.getProfile(MockIds.ayesha),
        throwsA(const NotFoundFailure()),
      );
      final posts = await feed.watchPosts(viewerId: MockIds.ahmed).first;
      expect(posts.any((p) => p.authorId == MockIds.ayesha), isFalse);
      expect(
        connections.acceptedIdsOf(MockIds.ahmed),
        isNot(contains(MockIds.ayesha)),
      );
      final ahmedChats = await chats.watchConversations(MockIds.ahmed).first;
      expect(
        ahmedChats.any((c) => c.memberIds.contains(MockIds.ayesha)),
        isFalse,
      );
      final notes = await notifications.watchNotifications(MockIds.ahmed).first;
      expect(notes.any((n) => n.actorId == MockIds.ayesha), isFalse);
    });

    test('blocked users list with dates; unblock', () async {
      await blocks.blockUser(
        blockerId: MockIds.ayesha,
        blockedId: MockIds.imran,
      );
      final list = await blocks.watchBlockedUsers(MockIds.ayesha).first;
      expect(list.single.userId, MockIds.imran);
      expect(list.single.blockedAt, now);
      await blocks.unblockUser(
        blockerId: MockIds.ayesha,
        blockedId: MockIds.imran,
      );
      expect(await blocks.watchBlockedUsers(MockIds.ayesha).first, isEmpty);
    });
  });

  group('cubits', () {
    test('change password cubit: live rules', () {
      final cubit = ChangePasswordCubit(auth)
        ..currentChanged('password1')
        ..nextChanged('newpass2026');
      expect(cubit.hasMinLength, isTrue);
      expect(cubit.differs, isTrue);
      expect(cubit.matches, isFalse);
      cubit.confirmationChanged('newpass2026');
      expect(cubit.canSave, isTrue);
    });

    test('edit profile: Save needs every required field', () async {
      final ahmed = await profiles.getProfile(MockIds.ahmed);
      expect(ahmed.isActive, isTrue);
      final cubit = EditProfileCubit(
        profiles,
        ahmed,
        media: MockMediaRepository(),
        picker: FakeImagePicker(),
        compressor: const FakeImageCompressor(),
        documents: FakeDocumentPicker(),
      )..qualificationsChanged('');
      expect(cubit.state.missingFields, <RequiredField>[
        RequiredField.qualifications,
      ]);
      expect(cubit.state.canSave, isFalse);
      await cubit.save();
      expect(cubit.state.saved, isFalse);
      cubit.qualificationsChanged('Ijazah in Hafs an Asim');
      expect(cubit.state.canSave, isTrue);
      await cubit.save();
      expect(cubit.state.saved, isTrue);
      expect((await profiles.getProfile(MockIds.ahmed)).isActive, isTrue);
      await cubit.close();
    });

    test('edit profile: a student becomes active once every required '
        'field is filled', () async {
      final ayesha = await profiles.getProfile(MockIds.ayesha);
      // As after an unfinished setup: no details, languages or location.
      final bare = await profiles.updateProfile(
        ayesha.copyWith(
          languages: const <TeachingLanguage>[],
          country: '',
          timeZone: '',
          studentDetails: const StudentDetails(),
        ),
      );
      expect(bare.isActive, isFalse);
      final cubit =
          EditProfileCubit(
              profiles,
              bare,
              media: MockMediaRepository(),
              picker: FakeImagePicker(),
              compressor: const FakeImageCompressor(),
              documents: FakeDocumentPicker(),
            )
            ..genderChanged(Gender.female)
            ..ageGroupChanged(LearnerAgeGroup.adult)
            ..countryChanged('Pakistan')
            ..timeZoneChanged('GMT+5')
            ..goalToggled(Subject.tajweed);
      expect(cubit.state.canSave, isFalse);
      cubit
        ..levelChanged(LearnerLevel.values.first)
        ..languageToggled(TeachingLanguage.urdu)
        ..preferenceChanged(TeacherGenderPreference.values.first);
      expect(cubit.state.missingFields, isEmpty);
      await cubit.save();
      expect((await profiles.getProfile(MockIds.ayesha)).isActive, isTrue);
      await cubit.close();
    });

    test('edit profile: empty name is refused', () async {
      final ayesha = await profiles.getProfile(MockIds.ayesha);
      final cubit =
          EditProfileCubit(
              profiles,
              ayesha,
              media: MockMediaRepository(),
              picker: FakeImagePicker(),
              compressor: const FakeImageCompressor(),
              documents: FakeDocumentPicker(),
            )
            ..nameChanged('  ')
            ..goalToggled(Subject.tajweed);
      await cubit.save();
      expect(cubit.state.nameMissing, isTrue);
      expect(cubit.state.saved, isFalse);
    });

    test('my profile: looking switch saves', () async {
      final cubit = MyProfileCubit(
        profiles,
        feed,
        connections,
        viewerId: MockIds.ayesha,
      );
      await settle();
      expect(cubit.state.connectionCount, 3);
      await cubit.lookingChanged(false);
      await settle();
      expect(cubit.state.profile!.studentDetails!.lookingForTeacher, isFalse);
      await cubit.close();
    });

    test('settings cubit saves switches', () async {
      final cubit = SettingsCubit(notifications, viewerId: MockIds.ayesha);
      await settle();
      expect(cubit.state.notifications.likes, isFalse);
      await cubit.update(cubit.state.notifications.copyWith(likes: true));
      await settle();
      expect(cubit.state.notifications.likes, isTrue);
      await cubit.close();
    });

    test('delete account cubit needs the confirmation', () async {
      final cubit = DeleteAccountCubit(auth, userId: MockIds.hira);
      await cubit.delete();
      expect(cubit.state.deleted, isFalse);
      cubit.confirmedChanged(true);
      await cubit.delete();
      expect(cubit.state.deleted, isTrue);
      await cubit.close();
    });
  });

  group('screens', () {
    testWidgets('Home avatar → My profile → Edit profile saves', (
      tester,
    ) async {
      final app = TestApp();
      await app.startSignedIn(tester);
      await tester.tap(find.bySemanticsLabel('My profile and settings'));
      await tester.pumpAndSettle();
      expect(find.byType(MyProfileScreen), findsOneWidget);
      expect(find.text('Connections (3)'), findsOneWidget);
      expect(find.text('Looking for a teacher'), findsOneWidget);

      await tapText(tester, 'Edit profile');
      expect(find.byType(EditProfileScreen), findsOneWidget);
      await tapText(tester, 'Hifz');
      await tapText(tester, 'Save');
      expect(find.byType(MyProfileScreen), findsOneWidget);
      final saved = await app.profiles.getProfile(MockIds.ayesha);
      expect(saved.studentDetails!.goals, contains(Subject.hifz));
      await app.stop(tester);
    });

    testWidgets('teacher edit profile has Qualifications', (tester) async {
      final app = TestApp();
      await app.startSignedIn(tester, teacher: true);
      GoRouter.of(tester.element(find.byType(Scaffold).first)).push('/me/edit');
      await tester.pumpAndSettle();
      expect(find.text('Qualifications'), findsOneWidget);
      await app.stop(tester);
    });

    testWidgets('Settings: blocked users, policies, log out sheet', (
      tester,
    ) async {
      final app = TestApp();
      await app.startSignedIn(tester);
      await app.blocks.blockUser(
        blockerId: MockIds.ayesha,
        blockedId: MockIds.imran,
      );
      GoRouter.of(
        tester.element(find.byType(Scaffold).first),
      ).push('/settings');
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(find.text('Asatiza 1.0.0'), findsOneWidget);

      await tapText(tester, 'Blocked users');
      expect(find.byType(BlockedUsersScreen), findsOneWidget);
      expect(find.text('Maulana Imran Qureshi'), findsOneWidget);
      await tapText(tester, 'Unblock');
      expect(find.text('No blocked users'), findsOneWidget);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      await tapText(tester, 'Terms of use');
      expect(find.byType(PolicyScreen), findsOneWidget);
      expect(find.text('Who can join'), findsOneWidget);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      await tapText(tester, 'Log out');
      expect(find.text('Log out of Asatiza?'), findsOneWidget);
      await tapText(tester, 'Cancel');
      expect(find.byType(SettingsScreen), findsOneWidget);

      await tapText(tester, 'Delete account');
      expect(find.text('Delete your account?'), findsOneWidget);
      await tapText(tester, 'Cancel');
      await app.stop(tester);
    });

    testWidgets('sign-up Terms link opens the policy page', (tester) async {
      final app = TestApp();
      await app.start(tester);
      GoRouter.of(tester.element(find.byType(Scaffold).first)).go('/sign-up');
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Privacy Policy').first);
      await tester.tap(find.text('Privacy Policy').first);
      await tester.pumpAndSettle();
      expect(find.byType(PolicyScreen), findsOneWidget);
      expect(find.text('What we collect'), findsOneWidget);
      await app.stop(tester);
    });
  });
}
