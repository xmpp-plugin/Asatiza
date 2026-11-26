import 'package:asatiza/core/errors/failures.dart';
import 'package:asatiza/data/mock/mock_posts.dart';
import 'package:asatiza/data/mock/mock_profiles.dart';
import 'package:asatiza/data/models/enums/post_tag.dart';
import 'package:asatiza/data/models/enums/report_reason.dart';
import 'package:asatiza/data/models/enums/user_role.dart';
import '../fakes/mock_auth_repository.dart';
import 'package:asatiza/data/repositories/mock/mock_feed_repository.dart';
import 'package:asatiza/data/repositories/mock/mock_profile_repository.dart';
import 'package:asatiza/data/repositories/mock/mock_safety_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import '../fakes/fake_block_repository.dart';

void main() {
  final now = DateTime(2026, 11, 19, 16);

  group('seed data', () {
    final profiles = buildMockProfiles(now);
    test('20 teachers and 14 students with unique UUID-style ids', () {
      expect(profiles.where((p) => p.role == UserRole.teacher), hasLength(20));
      expect(profiles.where((p) => p.role == UserRole.student), hasLength(14));
      expect(profiles.map((p) => p.id).toSet(), hasLength(34));
      expect(
        profiles.every((p) => RegExp(r'^[0-9a-f-]{36}$').hasMatch(p.id)),
        isTrue,
      );
    });
    test('no placeholder text', () {
      final words = RegExp(
        r'\b(test|lorem|sample|placeholder|dummy)\b',
        caseSensitive: false,
      );
      final texts = <String>[
        ...profiles
            .expand(
              (p) => <String?>[
                p.fullName,
                p.headline,
                p.bio,
                p.studentDetails?.note,
              ],
            )
            .whereType<String>(),
        ...buildMockPosts(now).map((s) => s.post.body),
        ...buildMockComments(now).map((c) => c.body),
      ];
      expect(texts.where(words.hasMatch), isEmpty);
    });
    test('initials skip titles', () {
      final ahmed = profiles.firstWhere((p) => p.id == MockIds.ahmed);
      expect(ahmed.initials, 'AK');
    });
  });

  group('MockAuthRepository', () {
    late MockProfileRepository profiles;
    late MockAuthRepository auth;
    setUp(() {
      profiles = MockProfileRepository(now: now);
      auth = MockAuthRepository(profiles);
    });

    // Developer decision 2026-11-23: both mock login emails are the same
    // address, which opens Qari Ahmed's (teacher) account.
    test('the mock login email opens Qari Ahmed (teacher)', () async {
      final user = await auth.logIn(
        email: MockAccounts.teacherEmail,
        password: 'tajweed2026',
      );
      expect(user.id, MockIds.ahmed);
      expect(user.role, UserRole.teacher);
    });
    test(
      'unknown email signs in as a new student named from the email',
      () async {
        final user = await auth.logIn(
          email: 'omar.siddiqui@gmail.com',
          password: 'tajweed2026',
        );
        expect(user.role, UserRole.student);
        expect(user.fullName, 'Omar Siddiqui');
      },
    );
    test('short password and bad code are rejected', () async {
      expect(
        () => auth.logIn(email: MockAccounts.studentEmail, password: '1234'),
        throwsA(const ValidationFailure(ValidationReason.passwordTooShort)),
      );
      expect(
        () => auth.verifySignUpCode(email: 'new@gmail.com', code: '12'),
        throwsA(const ValidationFailure(ValidationReason.invalidCode)),
      );
    });
    test(
      'sign-up creates the account with the chosen role after the code',
      () async {
        await auth.signUp(
          fullName: 'Bilal Ahmad',
          email: 'bilal.teaches@gmail.com',
          password: 'tajweed2026',
          role: UserRole.teacher,
        );
        final user = await auth.verifySignUpCode(
          email: 'bilal.teaches@gmail.com',
          code: '481203',
        );
        expect(user.role, UserRole.teacher);
        expect(user.teacherDetails, isNotNull);
        expect(
          () => auth.signUp(
            fullName: 'x',
            email: MockAccounts.studentEmail,
            password: 'tajweed2026',
            role: UserRole.student,
          ),
          throwsA(
            const ValidationFailure(ValidationReason.emailAlreadyRegistered),
          ),
        );
      },
    );
  });

  group('MockFeedRepository', () {
    late MockFeedRepository feed;
    setUp(() => feed = MockFeedRepository(now: now));

    test(
      'Ayesha sees connections first and her like on the first post',
      () async {
        final posts = await feed.watchPosts(viewerId: MockIds.ayesha).first;
        expect(posts.first.authorId, MockIds.ahmed);
        expect(posts.first.likedByMe, isTrue);
        expect(posts.first.likeCount, 48);
        expect(posts.first.commentCount, 6);
        expect(posts.take(3).map((p) => p.authorId).toSet(), <String>{
          MockIds.ahmed,
          MockIds.maryam,
          MockIds.khadija,
        });
      },
    );
    test('like toggles and comment adds', () async {
      await feed.toggleLike(postId: 'post-001', userId: MockIds.ayesha);
      var post = await feed
          .watchPost(postId: 'post-001', viewerId: MockIds.ayesha)
          .first;
      expect(post.likedByMe, isFalse);
      expect(post.likeCount, 47);
      await feed.addComment(
        postId: 'post-001',
        authorId: MockIds.ayesha,
        body: 'JazakAllahu khairan',
      );
      post = await feed
          .watchPost(postId: 'post-001', viewerId: MockIds.ayesha)
          .first;
      expect(post.commentCount, 7);
    });
    test('createPost validates and publishes', () async {
      expect(
        () =>
            feed.createPost(authorId: MockIds.ayesha, body: 'Salam', tag: null),
        throwsA(const ValidationFailure(ValidationReason.postTagMissing)),
      );
      final post = await feed.createPost(
        authorId: MockIds.ayesha,
        body: 'Revision plan for Juz Amma',
        tag: PostTag.question,
      );
      final posts = await feed.watchPosts(viewerId: MockIds.ayesha).first;
      expect(posts.map((p) => p.id), contains(post.id));
    });
  });

  group(
    'MockSafetyRepository, FakeBlockRepository and MockProfileRepository',
    () {
      test('reports are counted; blocking emits the blocked id', () async {
        final safety = MockSafetyRepository();
        await safety.reportPost(
          postId: 'post-001',
          reporterId: MockIds.ayesha,
          reason: ReportReason.spam,
        );
        expect(safety.reportCount, 1);
        final blocks = FakeBlockRepository();
        await blocks.blockUser(
          blockerId: MockIds.ayesha,
          blockedId: MockIds.ahmed,
        );
        // Blocking yourself is a no-op (BlockRepository contract).
        await blocks.blockUser(
          blockerId: MockIds.ayesha,
          blockedId: MockIds.ayesha,
        );
        expect(await blocks.watchBlockedIds(MockIds.ayesha).first, <String>{
          MockIds.ahmed,
        });
      });
      test('updateProfile never changes role or verification', () async {
        final profiles = MockProfileRepository(now: now);
        final ahmed = await profiles.getProfile(MockIds.ahmed);
        final saved = await profiles.updateProfile(
          ahmed.copyWith(headline: 'Tajweed teacher, 9 years'),
        );
        expect(saved.headline, 'Tajweed teacher, 9 years');
        expect(saved.role, UserRole.teacher);
        expect(saved.isVerified, isTrue);
      });
    },
  );
}
