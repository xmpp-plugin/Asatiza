import 'package:asatiza/app.dart';
import 'package:asatiza/core/router/app_router.dart';
import 'package:asatiza/core/router/app_routes.dart';
import 'package:asatiza/core/theme/app_colors.dart';
import 'package:asatiza/features/feed/presentation/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpApp(WidgetTester tester) async {
  appRouter.go(AppRoutes.home);
  await tester.pumpWidget(const AsatizaApp());
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('starts on Home with the 4 tabs and the centre Post button', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(find.byType(HomeScreen), findsOneWidget);
    for (final label in <String>['Home', 'Teachers', 'Chats', 'Alerts']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.byTooltip('Create post'), findsOneWidget);
  });

  testWidgets('uses the light tokens when the phone is in light mode', (
    tester,
  ) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await pumpApp(tester);

    final theme = Theme.of(tester.element(find.byType(HomeScreen)));
    expect(theme.brightness, Brightness.light);
    expect(theme.extension<AppColors>(), AppColors.light);
  });

  testWidgets('uses the dark tokens when the phone is in dark mode', (
    tester,
  ) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await pumpApp(tester);

    final theme = Theme.of(tester.element(find.byType(HomeScreen)));
    expect(theme.brightness, Brightness.dark);
    expect(theme.extension<AppColors>(), AppColors.dark);
  });
}
