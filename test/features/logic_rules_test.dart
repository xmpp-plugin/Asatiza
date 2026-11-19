import 'package:asatiza/core/errors/failures.dart';
import 'package:asatiza/core/utils/relative_time_formatter.dart';
import 'package:asatiza/data/models/enums/post_tag.dart';
import 'package:asatiza/data/models/post.dart';
import 'package:asatiza/features/auth/logic/otp_rules.dart';
import 'package:asatiza/features/auth/logic/password_rules.dart';
import 'package:asatiza/features/feed/logic/feed_ordering.dart';
import 'package:asatiza/features/post/logic/post_rules.dart';
import 'package:asatiza/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  group('FeedOrdering', () {
    final now = DateTime(2026, 11, 19, 12);
    Post p(String id, String author, int hoursAgo) => Post(
      id: id,
      authorId: author,
      body: id,
      tag: PostTag.reminder,
      createdAt: now.subtract(Duration(hours: hoursAgo)),
    );

    test(
      'connections first (newest first), then everyone else (newest first)',
      () {
        final ordered = const FeedOrdering().order(
          <Post>[
            p('a', 'stranger', 1),
            p('b', 'friend', 5),
            p('c', 'friend', 2),
            p('d', 'stranger', 3),
          ],
          <String>{'friend'},
        );
        expect(ordered.map((e) => e.id), <String>['c', 'b', 'a', 'd']);
      },
    );
  });

  group('PostRules', () {
    const rules = PostRules();
    test('empty, too long, missing tag and daily limit are rejected', () {
      expect(
        rules.validate(body: '  ', tag: PostTag.hifz, postsToday: 0),
        ValidationReason.postEmpty,
      );
      expect(
        rules.validate(body: 'a' * 1501, tag: PostTag.hifz, postsToday: 0),
        ValidationReason.postTooLong,
      );
      expect(
        rules.validate(body: 'Salam', tag: null, postsToday: 0),
        ValidationReason.postTagMissing,
      );
      expect(
        rules.validate(body: 'Salam', tag: PostTag.hifz, postsToday: 10),
        ValidationReason.dailyPostLimit,
      );
    });
    test('1,500 characters with a tag is accepted', () {
      expect(
        rules.validate(body: 'a' * 1500, tag: PostTag.reminder, postsToday: 9),
        isNull,
      );
    });
  });

  group('PasswordRules and OtpRules', () {
    const passwords = PasswordRules();
    const otp = OtpRules();
    test('passwords need 8 characters and must match', () {
      expect(passwords.hasMinLength('1234567'), isFalse);
      expect(passwords.hasMinLength('12345678'), isTrue);
      expect(passwords.matches('newpass2026', 'newpass2026'), isTrue);
      expect(passwords.matches('newpass2026', 'newpass2025'), isFalse);
    });
    test('email format', () {
      expect(passwords.isValidEmail('ayesha.khan@gmail.com'), isTrue);
      expect(passwords.isValidEmail('ayesha.khan@'), isFalse);
    });
    test('codes are 6 digits; input is sanitised', () {
      expect(otp.isComplete('481203'), isTrue);
      expect(otp.isComplete('48120'), isFalse);
      expect(otp.sanitize('48 12-03 99'), '481203');
    });
  });

  group('RelativeTimeFormatter', () {
    // The app gets date symbols from flutter_localizations; unit tests load them.
    setUpAll(() => initializeDateFormatting('en'));
    final l10n = lookupAppLocalizations(const Locale('en'));
    const formatter = RelativeTimeFormatter();
    final now = DateTime(2026, 11, 19, 16, 30);
    String f(Duration ago) =>
        formatter.format(now.subtract(ago), l10n, now: now);

    test('matches the design style', () {
      expect(f(const Duration(seconds: 20)), 'now');
      expect(f(const Duration(minutes: 58)), '58m');
      expect(f(const Duration(hours: 2)), '2h');
      expect(f(const Duration(hours: 20)), '20h');
      expect(f(const Duration(days: 1, hours: 2)), 'Yesterday');
      expect(f(const Duration(days: 7)), '12 Nov');
    });
  });
}
