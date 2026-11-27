import 'package:asatiza/core/errors/failures.dart';
import 'package:asatiza/data/models/enums/post_tag.dart';
import 'package:asatiza/data/models/enums/report_reason.dart';
import 'package:asatiza/data/repositories/supabase/supabase_feed_repository.dart';
import 'package:asatiza/data/repositories/supabase/supabase_safety_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  // No network: only row mapping and the public-URL builder are used.
  final repo = SupabaseFeedRepository(
    SupabaseClient('https://example.supabase.co', 'public-test-key'),
  );

  test('tags map to snake_case database values', () {
    expect(SupabaseFeedRepository.tagToDb(PostTag.tajweedTip), 'tajweed_tip');
    expect(
      SupabaseFeedRepository.tagToDb(PostTag.classAnnouncement),
      'class_announcement',
    );
    expect(SupabaseFeedRepository.tagToDb(PostTag.hifz), 'hifz');
  });

  test('report reasons map to snake_case database values', () {
    expect(
      SupabaseSafetyRepository.reasonToDb(ReportReason.hateOrHarassment),
      'hate_or_harassment',
    );
    expect(
      SupabaseSafetyRepository.reasonToDb(ReportReason.somethingElse),
      'something_else',
    );
  });

  test('a feed row maps to a Post with a public photo URL', () {
    final post = repo.postFromRow(<String, dynamic>{
      'id': 'p-1',
      'author_id': 'a',
      'body': 'Assalamu alaikum',
      'tag': 'tajweed_tip',
      'arabic_verse': null,
      'image_path': 'a/post_1.jpg',
      'like_count': 3,
      'comment_count': 2,
      'is_hidden': true,
      'created_at': '2026-11-27T10:00:00Z',
      'liked_by_me': true,
    });
    expect(post.tag, PostTag.tajweedTip);
    expect(post.imageUrl, contains('/post-images/a/post_1.jpg'));
    expect(post.isUnderReview, isTrue);
    expect(post.likeCount, 3);
    expect(post.commentCount, 2);
    expect(post.likedByMe, isTrue);
  });

  test('a comment row maps to a Comment', () {
    final c = SupabaseFeedRepository.commentFromRow(<String, dynamic>{
      'id': 'c-1',
      'post_id': 'p-1',
      'author_id': 'b',
      'body': 'JazakAllahu khairan',
      'like_count': 1,
      'created_at': '2026-11-27T10:05:00Z',
    }, likedByMe: true);
    expect(c.postId, 'p-1');
    expect(c.likeCount, 1);
    expect(c.likedByMe, isTrue);
  });

  test('database rule messages map to failures', () {
    Failure? map(String m) => SupabaseFeedRepository.mapError(m);
    expect(map('not_found'), const NotFoundFailure());
    expect(
      map('post_empty'),
      const ValidationFailure(ValidationReason.postEmpty),
    );
    expect(
      map('post_too_long'),
      const ValidationFailure(ValidationReason.postTooLong),
    );
    expect(
      map('post_tag_missing'),
      const ValidationFailure(ValidationReason.postTagMissing),
    );
    expect(
      map('daily_post_limit'),
      const ValidationFailure(ValidationReason.dailyPostLimit),
    );
    expect(
      map('comment_empty'),
      const ValidationFailure(ValidationReason.commentEmpty),
    );
    expect(
      map('daily_comment_limit'),
      const ValidationFailure(ValidationReason.dailyCommentLimit),
    );
    expect(map('invalid_image'), const UnexpectedFailure());
    expect(map('anything else'), isNull);
  });
}
