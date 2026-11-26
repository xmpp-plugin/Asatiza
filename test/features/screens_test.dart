import 'package:asatiza/core/errors/failures.dart';
import 'package:asatiza/data/mock/mock_profiles.dart';
import 'package:asatiza/data/models/profile.dart';
import 'package:asatiza/data/repositories/auth_repository.dart';
import '../fakes/mock_auth_repository.dart';
import 'package:asatiza/data/repositories/mock/mock_profile_repository.dart';
import 'package:asatiza/l10n/app_localizations.dart';
import 'package:asatiza/core/theme/app_theme.dart';
import 'package:asatiza/core/widgets/app_button.dart';
import 'package:asatiza/core/widgets/app_checkbox.dart';
import 'package:asatiza/core/widgets/post_card.dart';
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
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets('AppButton: loading shows a spinner and ignores taps', (
    tester,
  ) async {
    var taps = 0;
    Widget button({required bool loading}) => MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: AppButton(
          label: 'Save',
          loading: loading,
          onPressed: () => taps++,
        ),
      ),
    );
    await tester.pumpWidget(button(loading: true));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
    await tester.tap(find.byType(AppButton));
    expect(taps, 0);

    await tester.pumpWidget(button(loading: false));
    expect(find.byType(CircularProgressIndicator), findsNothing);
    await tester.tap(find.byType(AppButton));
    expect(taps, 1);
  });

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

    // No Skip; Continue stays disabled until the learner is chosen.
    expect(find.text('Skip for now'), findsNothing);
    await tapText(tester, 'Continue');
    expect(find.text('Tell us about the learner'), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
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
    expect(find.text('Skip for now'), findsNothing);
    await enterField(tester, 'Headline', 'Hifz teacher for boys, 6 years');
    await tapText(tester, 'Continue');
    expect(find.text('What do you teach?'), findsOneWidget);
    await tapText(tester, 'Hifz');
    // Languages, gender, country and time zone are still missing.
    await tapText(tester, 'Continue');
    expect(find.text('What do you teach?'), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
    await app.stop(tester);
  });

  testWidgets('Log in with the mock email: Qari Ahmed, straight to Home', (
    tester,
  ) async {
    final app = TestApp();
    await app.start(tester);
    await tapText(tester, 'I already have an account');
    expect(find.byType(LogInScreen), findsOneWidget);
    await enterField(tester, 'Email', MockAccounts.teacherEmail);
    await enterField(tester, 'Password', 'tajweed2026');
    await tapText(tester, 'Log in');

    // An active profile goes straight to Home, with no percentage card.
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.textContaining('% complete'), findsNothing);
    expect(find.text('Qari Ahmed Khan'), findsWidgets);
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
    // An existing, active account (a new email would create an incomplete
    // mock account and open setup instead).
    await enterField(tester, 'Email', MockAccounts.teacherEmail);
    await tapText(tester, 'Send code');
    expect(find.text('Enter the code'), findsOneWidget);
    // Never confirms that the email has an account.
    expect(
      find.textContaining('If an account exists for', findRichText: true),
      findsOneWidget,
    );
    await enterCode(tester, '270593');
    expect(find.byType(NewPasswordScreen), findsOneWidget);
    await enterField(tester, 'New password', 'newpass2026');
    await enterField(tester, 'Confirm password', 'newpass2026');
    await tapText(tester, 'Save and log in');
    expect(find.byType(HomeScreen), findsOneWidget);
    await app.stop(tester);
  });

  testWidgets('New password: a refused password shows a message', (
    tester,
  ) async {
    final auth = _RefusingAuth(MockProfileRepository());
    await tester.pumpWidget(
      RepositoryProvider<AuthRepository>.value(
        value: auth,
        child: MaterialApp(
          theme: AppTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const NewPasswordScreen(email: 'ayesha.khan@gmail.com'),
        ),
      ),
    );
    await enterField(tester, 'New password', 'samepass2026');
    await enterField(tester, 'Confirm password', 'samepass2026');

    auth.next = const ValidationFailure(ValidationReason.passwordUnchanged);
    await tapText(tester, 'Save and log in');
    expect(
      find.text('Choose a new password, not the one you used before.'),
      findsOneWidget,
    );

    auth.next = const ValidationFailure(ValidationReason.passwordTooShort);
    await tapText(tester, 'Save and log in');
    expect(
      find.text(
        'This password is too weak. Try a longer one with letters and numbers.',
      ),
      findsOneWidget,
    );
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

/// Mock auth whose password save is refused with [next] (as Supabase does
/// for a reused or weak password).
class _RefusingAuth extends MockAuthRepository {
  _RefusingAuth(super.profiles);

  Failure next = const ValidationFailure(ValidationReason.passwordUnchanged);

  @override
  Future<Profile> setNewPassword({
    required String email,
    required String password,
    required String confirmation,
  }) async => throw next;
}
