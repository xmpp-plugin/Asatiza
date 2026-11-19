import '../../../core/errors/failures.dart';
import '../../../data/models/enums/post_tag.dart';

/// Post limits (plan section 9).
class PostRules {
  const PostRules();

  static const int maxLength = 1500;
  static const int maxPostsPerDay = 10;

  /// The first broken rule, or null when the post can be published.
  ValidationReason? validate({
    required String body,
    required PostTag? tag,
    required int postsToday,
  }) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) {
      return ValidationReason.postEmpty;
    }
    if (trimmed.length > maxLength) {
      return ValidationReason.postTooLong;
    }
    if (tag == null) {
      return ValidationReason.postTagMissing;
    }
    if (postsToday >= maxPostsPerDay) {
      return ValidationReason.dailyPostLimit;
    }
    return null;
  }

  bool canPublish({required String body, required PostTag? tag}) =>
      validate(body: body, tag: tag, postsToday: 0) == null;
}
