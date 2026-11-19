import 'package:asatiza/core/theme/app_colors.dart';
import 'package:asatiza/features/feed/presentation/home_screen.dart';
import 'package:asatiza/features/onboarding/presentation/splash_screen.dart';
import 'package:asatiza/features/onboarding/presentation/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_app.dart';

void main() {
  testWidgets('starts on Splash, then Welcome when signed out', (tester) async {
    final app = TestApp();
    await tester.pumpWidget(app.build());
    await tester.pump();
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('Find Quran teachers & students'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle();
    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.text('Learn the Quran with the right teacher'), findsOneWidget);
    await app.stop(tester);
  });

  testWidgets(
    'signed-in user sees Home with the 4 tabs and the centre button',
    (tester) async {
      final app = TestApp();
      await app.startSignedIn(tester);
      expect(find.byType(HomeScreen), findsOneWidget);
      for (final label in <String>['Home', 'Teachers', 'Chats', 'Alerts']) {
        expect(find.text(label), findsOneWidget);
      }
      expect(find.byTooltip('Create post'), findsOneWidget);
      await app.stop(tester);
    },
  );

  testWidgets('uses the dark tokens when the phone is in dark mode', (
    tester,
  ) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    final app = TestApp();
    await app.start(tester);
    final theme = Theme.of(tester.element(find.byType(WelcomeScreen)));
    expect(theme.brightness, Brightness.dark);
    expect(theme.extension<AppColors>(), AppColors.dark);
    await app.stop(tester);
  });

  testWidgets('uses the light tokens when the phone is in light mode', (
    tester,
  ) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    final app = TestApp();
    await app.start(tester);
    final theme = Theme.of(tester.element(find.byType(WelcomeScreen)));
    expect(theme.extension<AppColors>(), AppColors.light);
    await app.stop(tester);
  });
}
