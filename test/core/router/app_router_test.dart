import 'package:asatiza/features/chat/presentation/chats_screen.dart';
import 'package:asatiza/features/discover/presentation/discover_screen.dart';
import 'package:asatiza/features/feed/presentation/home_screen.dart';
import 'package:asatiza/features/notifications/presentation/notifications_screen.dart';
import 'package:asatiza/features/onboarding/presentation/welcome_screen.dart';
import 'package:asatiza/features/post/presentation/create_post_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_app.dart';

Future<void> tapTab(WidgetTester tester, String label) async {
  await tester.tap(find.bySemanticsLabel(label));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('each tab shows its screen; visited tabs stay alive', (
    tester,
  ) async {
    final app = TestApp();
    await app.startSignedIn(tester);

    await tapTab(tester, 'Teachers');
    expect(find.byType(DiscoverScreen), findsOneWidget);
    await tapTab(tester, 'Chats');
    expect(find.byType(ChatsScreen), findsOneWidget);
    expect(find.byType(DiscoverScreen, skipOffstage: false), findsOneWidget);
    await tapTab(tester, 'Alerts');
    expect(find.byType(NotificationsScreen), findsOneWidget);
    await tapTab(tester, 'Home');
    expect(find.byType(HomeScreen), findsOneWidget);
    await app.stop(tester);
  });

  testWidgets('centre + opens New post full-screen and Close returns', (
    tester,
  ) async {
    final app = TestApp();
    await app.startSignedIn(tester);

    await tester.tap(find.byTooltip('Create post'));
    await tester.pumpAndSettle();
    expect(find.byType(CreatePostScreen), findsOneWidget);
    expect(find.text('New post'), findsOneWidget);

    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.byType(CreatePostScreen), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);
    await app.stop(tester);
  });

  testWidgets('system back on a non-Home tab returns to Home', (tester) async {
    final app = TestApp();
    await app.startSignedIn(tester);

    await tapTab(tester, 'Chats');
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    await app.stop(tester);
  });

  testWidgets('logging out returns to Welcome', (tester) async {
    final app = TestApp();
    await app.startSignedIn(tester);

    // Stream cancels complete in the real zone; run outside the fake clock.
    await tester.runAsync(app.session.logOut);
    await tester.pumpAndSettle();
    expect(find.byType(WelcomeScreen), findsOneWidget);
    await app.stop(tester);
  });
}
