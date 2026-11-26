import 'package:asatiza/core/errors/failures.dart';
import 'package:asatiza/core/session/session_cubit.dart';
import 'package:asatiza/data/mock/mock_profiles.dart';
import 'package:asatiza/data/models/enums/gender.dart';
import 'package:asatiza/data/models/enums/post_tag.dart';
import 'package:asatiza/data/models/enums/report_reason.dart';
import 'package:asatiza/data/models/enums/subject.dart';
import 'package:asatiza/data/models/enums/teaches_audience.dart';
import 'package:asatiza/data/models/enums/teaching_language.dart';
import 'package:asatiza/data/models/enums/user_role.dart';
import 'package:asatiza/data/models/enums/weekday.dart';
import 'package:asatiza/data/models/profile.dart';
import '../fakes/mock_auth_repository.dart';
import 'package:asatiza/core/services/image_source_kind.dart';
import 'package:asatiza/data/repositories/mock/mock_feed_repository.dart';
import '../fakes/mock_media_repository.dart';
import 'package:asatiza/data/repositories/mock/mock_profile_repository.dart';
import 'package:asatiza/data/repositories/mock/mock_safety_repository.dart';
import 'package:asatiza/features/auth/bloc/login_cubit.dart';
import 'package:asatiza/features/auth/bloc/login_state.dart';
import 'package:asatiza/features/auth/bloc/otp_cubit.dart';
import 'package:asatiza/features/auth/bloc/otp_state.dart';
import 'package:asatiza/features/auth/bloc/password_reset_cubit.dart';
import 'package:asatiza/features/auth/bloc/password_reset_state.dart';
import 'package:asatiza/features/auth/bloc/sign_up_cubit.dart';
import 'package:asatiza/features/auth/bloc/sign_up_state.dart';
import 'package:asatiza/features/feed/bloc/feed_cubit.dart';
import 'package:asatiza/features/feed/bloc/feed_state.dart';
import 'package:asatiza/features/feed/bloc/post_detail_cubit.dart';
import 'package:asatiza/features/post/bloc/create_post_cubit.dart';
import 'package:asatiza/features/post/bloc/create_post_state.dart';
import 'package:asatiza/features/profile_setup/bloc/student_setup_cubit.dart';
import 'package:asatiza/features/profile_setup/bloc/teacher_setup_cubit.dart';
import 'package:asatiza/features/safety/bloc/report_cubit.dart';
import 'package:asatiza/features/safety/bloc/report_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';
import '../fakes/fake_block_repository.dart';
import 'package:asatiza/features/discover/bloc/public_profile_cubit.dart';
import 'package:asatiza/features/settings/bloc/blocked_users_cubit.dart';
import 'package:asatiza/data/repositories/mock/mock_connection_repository.dart';

/// Lets stream listeners and async cubit work run.
Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 20));

void main() {
  late MockProfileRepository profiles;
  late MockAuthRepository auth;
  late MockFeedRepository feed;
  late MockSafetyRepository safety;
  late FakeBlockRepository blocks;

  setUp(() {
    profiles = MockProfileRepository();
    auth = MockAuthRepository(profiles);
    feed = MockFeedRepository();
    safety = MockSafetyRepository();
    blocks = FakeBlockRepository();
  });

  test('SessionCubit: sign in, setup flag, profile updates, log out', () async {
    final session = SessionCubit(auth, profiles);
    final ayesha = await profiles.getProfile(MockIds.ayesha);
    // Setup is needed while the profile is not active.
    session.signedIn(ayesha.copyWith(isActive: false));
    expect(session.state.needsSetup, isTrue);
    session.completeSetup(ayesha);
    expect(ayesha.isActive, isTrue);
    expect(session.state.needsSetup, isFalse);
    await profiles.updateProfile(ayesha.copyWith(city: 'Lahore'));
    await settle();
    expect(session.state.user!.city, 'Lahore');
    await session.logOut();
    expect(session.state.isSignedIn, isFalse);
    await session.close();
  });

  test(
    'SignUpCubit: needs every field and consent, then sends the code',
    () async {
      final cubit = SignUpCubit(auth)
        ..nameChanged('Zainab Ali')
        ..emailChanged('zainab.ali@gmail.com')
        ..passwordChanged('tajweed2026');
      expect(cubit.state.canSubmit, isFalse);
      cubit
        ..consentChanged(true)
        ..roleChanged(UserRole.teacher);
      expect(cubit.state.canSubmit, isTrue);
      await cubit.submit();
      expect(cubit.state.status, SignUpStatus.codeSent);
      await cubit.close();
    },
  );

  test('OtpCubit: auto-verifies 6 digits and returns the new user', () async {
    await auth.signUp(
      fullName: 'Zainab Ali',
      email: 'zainab.ali@gmail.com',
      password: 'tajweed2026',
      role: UserRole.student,
    );
    final cubit = OtpCubit(
      auth,
      purpose: OtpPurpose.signUp,
      email: 'zainab.ali@gmail.com',
    );
    expect(cubit.state.secondsLeft, 60);
    expect(cubit.state.canResend, isFalse);
    cubit.codeChanged('48 12 03');
    await settle();
    expect(cubit.state.status, OtpStatus.verified);
    expect(cubit.state.user!.fullName, 'Zainab Ali');
    await cubit.close();
  });

  test(
    'LoginCubit: wrong-length password is blocked; mock teacher logs in',
    () async {
      final cubit = LoginCubit(auth)
        ..emailChanged(MockAccounts.teacherEmail)
        ..passwordChanged('short');
      expect(cubit.state.canSubmit, isFalse);
      cubit.passwordChanged('tajweed2026');
      await cubit.submit();
      expect(cubit.state.status, LoginStatus.signedIn);
      expect(cubit.state.user!.id, MockIds.ahmed);
      await cubit.close();
    },
  );

  test(
    'LoginCubit: unconfirmed email sends a fresh code and asks for it',
    () async {
      final unconfirmed = _UnconfirmedAuth(profiles);
      final cubit = LoginCubit(unconfirmed)
        ..emailChanged('new.user@example.com')
        ..passwordChanged('tajweed2026');
      final statuses = <LoginStatus>[];
      final sub = cubit.stream.listen((s) => statuses.add(s.status));
      await cubit.submit();
      await settle();
      expect(statuses, contains(LoginStatus.needsCode));
      expect(unconfirmed.resentTo, 'new.user@example.com');
      expect(cubit.state.status, LoginStatus.editing);
      expect(cubit.state.failure, isNull);
      await sub.cancel();
      await cubit.close();
    },
  );

  test(
    'SessionCubit.restore: mock stays signed out; a kept session signs in',
    () async {
      final mockSession = SessionCubit(auth, profiles);
      await mockSession.restore();
      expect(mockSession.state.isSignedIn, isFalse);
      await mockSession.close();

      final ahmed = await profiles.getProfile(MockIds.ahmed);
      final kept = SessionCubit(_KeptSessionAuth(profiles, ahmed), profiles);
      await kept.restore();
      expect(kept.state.user?.id, MockIds.ahmed);
      expect(kept.state.needsSetup, isFalse);
      await kept.close();
    },
  );

  test('Failure.displayReason: validation, network and anything else', () {
    expect(
      const ValidationFailure(ValidationReason.invalidCode).displayReason,
      ValidationReason.invalidCode,
    );
    expect(const NetworkFailure().displayReason, ValidationReason.network);
    expect(
      const UnexpectedFailure().displayReason,
      ValidationReason.unexpected,
    );
    expect(ValidationReason.network.isGeneral, isTrue);
    expect(ValidationReason.wrongCredentials.isGeneral, isFalse);
  });

  test('LoginCubit: no connection shows the network error', () async {
    final cubit = LoginCubit(_OfflineAuth(profiles))
      ..emailChanged(MockAccounts.teacherEmail)
      ..passwordChanged('tajweed2026');
    await cubit.submit();
    expect(cubit.state.status, LoginStatus.editing);
    expect(cubit.state.failure, ValidationReason.network);
    cubit.emailChanged('${MockAccounts.teacherEmail} ');
    expect(cubit.state.failure, isNull);
    await cubit.close();
  });

  testWidgets('OtpCubit: a failed resend shows the error instead of throwing', (
    tester,
  ) async {
    final cubit = OtpCubit(
      _OfflineAuth(profiles),
      purpose: OtpPurpose.signUp,
      email: 'new.user@example.com',
    );
    await tester.pump(const Duration(seconds: 61));
    expect(cubit.state.canResend, isTrue);
    await cubit.resend();
    expect(cubit.state.failure, ValidationReason.network);
    expect(cubit.state.canResend, isTrue);
    await cubit.close();
  });

  test(
    'PasswordResetCubit: send code, then save a matching new password',
    () async {
      final step1 = PasswordResetCubit(auth)
        ..emailChanged(MockAccounts.studentEmail);
      await step1.sendCode();
      expect(step1.state.status, PasswordResetStatus.codeSent);
      final step3 = PasswordResetCubit(auth, email: MockAccounts.studentEmail)
        ..passwordChanged('newpass2026')
        ..confirmationChanged('newpass2025');
      expect(step3.state.canSave, isFalse);
      step3.confirmationChanged('newpass2026');
      await step3.savePassword();
      expect(step3.state.user!.id, MockIds.ahmed);
      await step1.close();
      await step3.close();
    },
  );

  test(
    'TeacherSetupCubit: steps save to the profile; finish sets done',
    () async {
      await auth.signUp(
        fullName: 'Usman Ali',
        email: 'usman.ali@gmail.com',
        password: 'tajweed2026',
        role: UserRole.teacher,
      );
      final user = await auth.verifySignUpCode(
        email: 'usman.ali@gmail.com',
        code: '123456',
      );
      final media = MockMediaRepository();
      final cubit = TeacherSetupCubit(
        profiles,
        user,
        media: media,
        picker: FakeImagePicker(),
        compressor: const FakeImageCompressor(),
        documents: FakeDocumentPicker(),
      );
      // Continue does nothing until the step's required fields are filled.
      expect(cubit.state.step, 1);
      expect(cubit.state.stepComplete, isFalse);
      await cubit.next();
      expect(cubit.state.step, 1);
      cubit.headlineChanged('Hifz teacher for boys, 6 years');
      await cubit.photoPicked(ImageSourceKind.gallery);
      expect(cubit.state.draft.photoPath, startsWith('${user.id}/avatar-'));
      await cubit.next();
      expect(
        (await profiles.getProfile(user.id)).photoPath,
        cubit.state.draft.photoPath,
      );
      expect(cubit.state.step, 2);
      expect(
        (await profiles.getProfile(user.id)).headline,
        'Hifz teacher for boys, 6 years',
      );
      cubit
        ..subjectToggled(Subject.hifz)
        ..countryChanged('Pakistan');
      await cubit.next();
      expect(cubit.state.step, 2, reason: 'languages, gender, time zone');
      cubit
        ..languageToggled(TeachingLanguage.urdu)
        ..genderChanged(Gender.male)
        ..timeZoneChanged('GMT+5');
      await cubit.next();
      expect(cubit.state.step, 3);
      cubit
        ..dayToggled(Weekday.monday)
        ..feeChanged('5,000')
        ..experienceChanged('6')
        ..bioChanged('Hifz for boys with a weekly plan.')
        ..qualificationsChanged('Hafiz, Jamia Ashrafia');
      expect(cubit.state.stepComplete, isFalse, reason: '"Teaches" missing');
      cubit.audienceToggled(TeachesAudience.children);
      await cubit.next();
      expect(cubit.state.done, isTrue);
      expect((await profiles.getProfile(user.id)).isActive, isTrue);
      final saved = await profiles.getProfile(user.id);
      expect(saved.teacherDetails!.feeAmount, 5000);
      expect(
        saved.teacherDetails!.availableFromMinutes,
        TeacherSetupCubit.defaultFrom,
      );
      await cubit.close();
    },
  );

  test('StudentSetupCubit: resumes at the first incomplete step; '
      'Continue needs the step fields', () async {
    final ayesha = await profiles.getProfile(MockIds.ayesha);
    // Step 2 fields missing (as after an unfinished setup).
    final unfinished = await profiles.updateProfile(
      ayesha.copyWith(timeZone: '', country: ''),
    );
    expect(unfinished.isActive, isFalse);
    final cubit = StudentSetupCubit(
      profiles,
      unfinished,
      media: MockMediaRepository(),
      picker: FakeImagePicker(),
      compressor: const FakeImageCompressor(),
    );
    expect(cubit.state.step, 2);
    expect(cubit.state.stepComplete, isFalse);
    await cubit.next();
    expect(cubit.state.step, 2);
    cubit
      ..countryChanged('Pakistan')
      ..timeZoneChanged('GMT+5');
    expect(cubit.state.stepComplete, isTrue);
    await cubit.next();
    expect(cubit.state.step, 3);
    cubit.back();
    expect(cubit.state.step, 2);
    await cubit.next();
    await cubit.next();
    expect(cubit.state.done, isTrue);
    expect((await profiles.getProfile(MockIds.ayesha)).isActive, isTrue);
    await cubit.close();
  });

  test(
    'FeedCubit: loads ordered posts with authors; like toggles; block hides',
    () async {
      final cubit = FeedCubit(feed, profiles, blocks, viewerId: MockIds.ayesha);
      await settle();
      expect(cubit.state.status, FeedStatus.ready);
      expect(cubit.state.visiblePosts.first.authorId, MockIds.ahmed);
      await cubit.toggleLike('post-002');
      await settle();
      expect(
        cubit.state.posts.firstWhere((p) => p.id == 'post-002').likedByMe,
        isTrue,
      );
      await blocks.blockUser(
        blockerId: MockIds.ayesha,
        blockedId: MockIds.ahmed,
      );
      await settle();
      expect(
        cubit.state.posts.where((p) => p.authorId == MockIds.ahmed),
        isEmpty,
      );
      await cubit.close();
    },
  );

  test('PostDetailCubit: comments with authors; add comment', () async {
    final cubit = PostDetailCubit(
      feed,
      profiles,
      postId: 'post-001',
      viewerId: MockIds.ayesha,
    );
    await settle();
    expect(cubit.state.comments, hasLength(6));
    expect(cubit.state.author!.id, MockIds.ahmed);
    expect(await cubit.addComment('JazakAllahu khairan, very clear.'), isTrue);
    await settle();
    expect(cubit.state.comments, hasLength(7));
    expect(await cubit.addComment('   '), isFalse);
    await cubit.close();
  });

  test(
    'CreatePostCubit: needs text and a tag; posts with the sample photo',
    () async {
      final cubit = CreatePostCubit(feed, authorId: MockIds.ayesha)
        ..bodyChanged('Which mushaf do you recommend for Hifz?');
      expect(cubit.state.canPost, isFalse);
      cubit
        ..tagSelected(PostTag.question)
        ..photoAdded();
      await cubit.submit();
      expect(cubit.state.status, CreatePostStatus.posted);
      final posts = await feed.watchPosts(viewerId: MockIds.ayesha).first;
      final mine = posts.firstWhere((p) => p.body.startsWith('Which mushaf'));
      expect(mine.imagePath, CreatePostCubit.sampleAttachment);
      await cubit.close();
    },
  );

  test('ReportCubit: reason required; also-block blocks the author', () async {
    final cubit = ReportCubit(
      safety,
      blocks,
      postId: 'post-001',
      authorId: MockIds.ahmed,
      reporterId: MockIds.ayesha,
    );
    expect(cubit.state.canSend, isFalse);
    cubit
      ..reasonSelected(ReportReason.spam)
      ..alsoBlockChanged(true);
    await cubit.submit();
    expect(cubit.state.status, ReportStatus.sent);
    expect(safety.reportCount, 1);
    expect(
      await blocks.watchBlockedIds(MockIds.ayesha).first,
      contains(MockIds.ahmed),
    );
    await cubit.close();
  });

  test('PublicProfileCubit.block: a failure changes nothing', () async {
    final cubit = PublicProfileCubit(
      profiles,
      MockConnectionRepository(profiles),
      feed,
      blocks,
      viewerId: MockIds.ayesha,
      profileId: MockIds.ahmed,
    );
    await settle();
    blocks.failWith = const NetworkFailure();
    expect(await cubit.block(), isFalse);
    expect(cubit.state.blocked, isFalse);
    blocks.failWith = null;
    expect(await cubit.block(), isTrue);
    expect(cubit.state.blocked, isTrue);
    await cubit.close();
  });

  test('BlockedUsersCubit.unblock: a failure keeps the block', () async {
    await blocks.blockUser(blockerId: MockIds.ayesha, blockedId: MockIds.imran);
    final cubit = BlockedUsersCubit(blocks, profiles, viewerId: MockIds.ayesha);
    await settle();
    expect(cubit.state.blocked.single.userId, MockIds.imran);
    blocks.failWith = const NetworkFailure();
    expect(await cubit.unblock(MockIds.imran), isFalse);
    blocks.failWith = null;
    expect(
      await blocks.watchBlockedIds(MockIds.ayesha).first,
      contains(MockIds.imran),
    );
    expect(await cubit.unblock(MockIds.imran), isTrue);
    await settle();
    expect(cubit.state.blocked, isEmpty);
    await cubit.close();
  });

  test('Failures are value-equal', () {
    expect(
      const ValidationFailure(ValidationReason.invalidCode),
      const ValidationFailure(ValidationReason.invalidCode),
    );
  });
}

/// Log-in always reports an unconfirmed email; records the resend.
class _UnconfirmedAuth extends MockAuthRepository {
  _UnconfirmedAuth(super.profiles);

  String? resentTo;

  @override
  Future<Profile> logIn({required String email, required String password}) =>
      throw const ValidationFailure(ValidationReason.emailNotConfirmed);

  @override
  Future<void> resendCode({required String email}) async => resentTo = email;
}

/// Restores [_user] as if a session was kept from an earlier launch.
class _KeptSessionAuth extends MockAuthRepository {
  _KeptSessionAuth(super.profiles, this._user);

  final Profile _user;

  @override
  Future<Profile?> restoreSession() async => _user;
}

/// Every call fails as if offline.
class _OfflineAuth extends MockAuthRepository {
  _OfflineAuth(super.profiles);

  @override
  Future<Profile> logIn({required String email, required String password}) =>
      throw const NetworkFailure();

  @override
  Future<void> resendCode({required String email}) =>
      throw const NetworkFailure();
}
