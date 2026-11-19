import 'package:asatiza/core/widgets/app_checkbox.dart';
import 'package:asatiza/core/widgets/post_card.dart';
import 'package:asatiza/core/widgets/profile_strength_card.dart';
import 'package:asatiza/features/auth/presentation/email_code_screen.dart';
import 'package:asatiza/features/auth/presentation/log_in_screen.dart';
import 'package:asatiza/features/auth/presentation/new_password_screen.dart';
import 'package:asatiza/features/auth/presentation/sign_up_screen.dart';
import 'package:asatiza/features/feed/presentation/home_screen.dart';
import 'package:asatiza/features/feed/presentation/post_detail_screen.dart';
import 'package:asatiza/features/onboarding/presentation/welcome_screen.dart';
import 'package:asatiza/features/profile_setup/presentation/student_setup_screen.dart';
import 'package:asatiza/features/profile_setup/presentation/teacher_setup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets('Welcome: swipe slides, Skip opens Sign up', (tester) async {
    final app = TestApp();
    await app.start(tester);
    expect(find.byType(WelcomeScreen), findsOneWidget);
    await tester.drag(find.byType(PageView), const Offset(-390, 0));
    await tester.pumpAndSettle();
    expect(find.text('Connect with verified teachers'), findsOneWidget);
    await tapText(tester, 'Skip');
    expect(find.byType(SignUpScreen), findsOneWidget);
    await app.stop(tester);
  });

  testWidgets('Sign up as a student → code → student setup → skip → Home', (
    tester,
  ) async {
    final app = TestApp();
    await app.start(tester);
    await tapText(tester, 'Create account');

    await enterField(tester, 'Full name', 'Zainab Ali');
    await enterField(tester, 'Email', 'zainab.ali@gmail.com');
    await enterField(tester, 'Password', 'tajweed2026');
    await tapText(tester, 'Create account');
    expect(
      find.byType(SignUpScreen),
      findsOneWidget,
      reason: 'consent is required',
    );

    await tester.tap(find.byType(AppCheckbox));
    await tester.pump();
    await tapText(tester, 'Create account');
    expect(find.byType(EmailCodeScreen), findsOneWidget);
    expect(
      find.textContaining('zainab.ali@gmail.com', findRichText: true),
      findsOneWidget,
    );

    await enterCode(tester, '481203');
    expect(find.byType(StudentSetupScreen), findsOneWidget);
    expect(find.text('Tell us about the learner'), findsOneWidget);

    await tapText(tester, 'Skip for now');
    expect(find.byType(HomeScreen), findsOneWidget);
    await app.stop(tester);
  });

  testWidgets('Teacher sign-up walks the 3 setup steps', (tester) async {
    final app = TestApp();
    await app.start(tester);
    await tapText(tester, 'Create account');
    await tapText(tester, 'Teacher');
    await enterField(tester, 'Full name', 'Usman Ali');
    await enterField(tester, 'Email', 'usman.ali@gmail.com');
    await enterField(tester, 'Password', 'tajweed2026');
    await tester.tap(find.byType(AppCheckbox));
    await tester.pump();
    await tapText(tester, 'Create account');
    await enterCode(tester, '481203');

    expect(find.byType(TeacherSetupScreen), findsOneWidget);
    expect(find.text('Step 1 of 3'), findsOneWidget);
    await enterField(tester, 'Headline', 'Hifz teacher for boys, 6 years');
    await tapText(tester, 'Continue');
    expect(find.text('What do you teach?'), findsOneWidget);
    await tapText(tester, 'Hifz');
    await tapText(tester, 'Continue');
    expect(find.text('Your classes and fee'), findsOneWidget);
    await tapText(tester, 'Finish setup');
    expect(find.byType(HomeScreen), findsOneWidget);
    await app.stop(tester);
  });

  testWidgets('Log in as Ayesha: strength card 65% and the feed', (
    tester,
  ) async {
    final app = TestApp();
    await app.start(tester);
    await tapText(tester, 'I already have an account');
    expect(find.byType(LogInScreen), findsOneWidget);
    await enterField(tester, 'Email', 'ayesha.khan@gmail.com');
    await enterField(tester, 'Password', 'tajweed2026');
    await tapText(tester, 'Log in');

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(ProfileStrengthCard), findsOneWidget);
    expect(find.text('Your profile is 65% complete'), findsOneWidget);
    expect(
      find.text('Add your learning goal to reach teachers faster.'),
      findsOneWidget,
    );
    expect(find.text('2 steps left'), findsOneWidget);
    expect(find.text('Qari Ahmed Khan'), findsWidgets);
    expect(find.text('Liked'), findsOneWidget);
    await app.stop(tester);
  });

  testWidgets('Forgot password: email → code → new password → Home', (
    tester,
  ) async {
    final app = TestApp();
    await app.start(tester);
    await tapText(tester, 'I already have an account');
    await tapText(tester, 'Forgot password?');
    expect(find.text('Reset your password'), findsOneWidget);
    await enterField(tester, 'Email', 'ayesha.khan@gmail.com');
    await tapText(tester, 'Send code');
    expect(find.text('Enter the code'), findsOneWidget);
    await enterCode(tester, '270593');
    expect(find.byType(NewPasswordScreen), findsOneWidget);
    await enterField(tester, 'New password', 'newpass2026');
    await enterField(tester, 'Confirm password', 'newpass2026');
    await tapText(tester, 'Save and log in');
    expect(find.byType(HomeScreen), findsOneWidget);
    await app.stop(tester);
  });

  testWidgets('Post detail: comments, add a comment, report and block', (
    tester,
  ) async {
    final app = TestApp();
    await app.startSignedIn(tester);

    await tester.tap(find.text('Comment').first);
    await tester.pumpAndSettle();
    expect(find.byType(PostDetailScreen), findsOneWidget);
    expect(find.text('Comments (6)'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Write a comment…'),
      'JazakAllahu khairan, very clear.',
    );
    await tester.pump();
    await tester.tap(find.bySemanticsLabel('Send comment'));
    await tester.pumpAndSettle();
    expect(find.text('Comments (7)'), findsOneWidget);

    await tester.tap(find.text('Report').first);
    await tester.pumpAndSettle();
    expect(find.text('Report this post'), findsOneWidget);
    await tester.tap(find.text('Spam'));
    await tester.tap(find.textContaining('Also block', findRichText: true));
    await tester.pump();
    await tester.tap(find.widgetWithText(InkWell, 'Report').last);
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(
      find.text('Thank you. Our team will review this post.'),
      findsOneWidget,
    );
    final authors = tester
        .widgetList<PostCard>(find.byType(PostCard))
        .map((c) => c.author.fullName);
    expect(authors, isNot(contains('Qari Ahmed Khan')));
    await app.stop(tester);
  });

  testWidgets('Create post: needs a tag, then appears in the feed', (
    tester,
  ) async {
    final app = TestApp();
    await app.startSignedIn(tester);
    await tester.tap(find.byTooltip('Create post'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextField).first,
      'Which mushaf do you recommend for Hifz?',
    );
    await tester.pump();
    expect(find.text('39 / 1,500'), findsOneWidget);
    await tapText(tester, 'Question');
    await tapText(tester, 'Photo');
    await tester.tap(find.widgetWithText(InkWell, 'Post'));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Which mushaf do you recommend for Hifz?'),
      300,
    );
    expect(
      find.text('Which mushaf do you recommend for Hifz?'),
      findsOneWidget,
    );
    await app.stop(tester);
  });
}
