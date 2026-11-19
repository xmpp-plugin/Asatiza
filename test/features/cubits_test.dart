import 'package:asatiza/core/errors/failures.dart';
import 'package:asatiza/core/session/session_cubit.dart';
import 'package:asatiza/data/mock/mock_profiles.dart';
import 'package:asatiza/data/models/enums/learner_age_group.dart';
import 'package:asatiza/data/models/enums/post_tag.dart';
import 'package:asatiza/data/models/enums/report_reason.dart';
import 'package:asatiza/data/models/enums/subject.dart';
import 'package:asatiza/data/models/enums/user_role.dart';
import 'package:asatiza/data/models/enums/weekday.dart';
import 'package:asatiza/data/repositories/mock/mock_auth_repository.dart';
import 'package:asatiza/data/repositories/mock/mock_feed_repository.dart';
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

/// Lets stream listeners and async cubit work run.
Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 20));

void main() {
  late MockProfileRepository profiles;
  late MockAuthRepository auth;
  late MockFeedRepository feed;
  late MockSafetyRepository safety;

  setUp(() {
    profiles = MockProfileRepository();
    auth = MockAuthRepository(profiles);
    feed = MockFeedRepository();
    safety = MockSafetyRepository();
  });

  test('SessionCubit: sign in, setup flag, profile updates, log out', () async {
    final session = SessionCubit(auth, profiles);
    final ayesha = await profiles.getProfile(MockIds.ayesha);
    session.signedIn(ayesha, needsSetup: true);
    expect(session.state.needsSetup, isTrue);
    session.completeSetup();
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
      expect(step3.state.user!.id, MockIds.ayesha);
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
      final cubit = TeacherSetupCubit(profiles, user)
        ..photoAdded()
        ..headlineChanged('Hifz teacher for boys, 6 years');
      await cubit.next();
      expect(cubit.state.step, 2);
      expect(
        (await profiles.getProfile(user.id)).headline,
        'Hifz teacher for boys, 6 years',
      );
      cubit
        ..subjectToggled(Subject.hifz)
        ..countryChanged('Pakistan');
      await cubit.next();
      cubit
        ..dayToggled(Weekday.monday)
        ..feeChanged('5,000')
        ..experienceChanged('6');
      await cubit.next();
      expect(cubit.state.done, isTrue);
      final saved = await profiles.getProfile(user.id);
      expect(saved.teacherDetails!.feeAmount, 5000);
      expect(
        saved.teacherDetails!.availableFromMinutes,
        TeacherSetupCubit.defaultFrom,
      );
      await cubit.close();
    },
  );

  test('StudentSetupCubit: back and skip', () async {
    final ayesha = await profiles.getProfile(MockIds.ayesha);
    final cubit = StudentSetupCubit(profiles, ayesha)
      ..ageGroupChanged(LearnerAgeGroup.teen);
    await cubit.next();
    cubit.back();
    expect(cubit.state.step, 1);
    await cubit.skip();
    expect(cubit.state.done, isTrue);
    expect(
      (await profiles.getProfile(MockIds.ayesha)).studentDetails!.ageGroup,
      LearnerAgeGroup.teen,
    );
    await cubit.close();
  });

  test(
    'FeedCubit: loads ordered posts with authors; like toggles; block hides',
    () async {
      final cubit = FeedCubit(feed, profiles, safety, viewerId: MockIds.ayesha);
      await settle();
      expect(cubit.state.status, FeedStatus.ready);
      expect(cubit.state.visiblePosts.first.authorId, MockIds.ahmed);
      await cubit.toggleLike('post-002');
      await settle();
      expect(
        cubit.state.posts.firstWhere((p) => p.id == 'post-002').likedByMe,
        isTrue,
      );
      await safety.blockUser(
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
    expect(
      await safety.watchBlockedIds(MockIds.ayesha).first,
      contains(MockIds.ahmed),
    );
    await cubit.close();
  });

  test('Failures are value-equal', () {
    expect(
      const ValidationFailure(ValidationReason.invalidCode),
      const ValidationFailure(ValidationReason.invalidCode),
    );
  });
}
