import 'package:asatiza/app.dart';
import 'package:asatiza/core/router/app_router.dart';
import 'package:asatiza/core/router/app_routes.dart';
import 'package:asatiza/features/chat/presentation/chats_screen.dart';
import 'package:asatiza/features/discover/presentation/discover_screen.dart';
import 'package:asatiza/features/feed/presentation/home_screen.dart';
import 'package:asatiza/features/notifications/presentation/notifications_screen.dart';
import 'package:asatiza/features/post/presentation/create_post_screen.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpApp(WidgetTester tester) async {
  appRouter.go(AppRoutes.home);
  await tester.pumpWidget(const AsatizaApp());
  await tester.pumpAndSettle();
}

Future<void> tapTab(WidgetTester tester, String label) async {
  await tester.tap(find.bySemanticsLabel(label));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('each tab shows its screen with the design title', (
    tester,
  ) async {
    await pumpApp(tester);

    await tapTab(tester, 'Teachers');
    expect(find.byType(DiscoverScreen), findsOneWidget);

    await tapTab(tester, 'Chats');
    expect(find.byType(ChatsScreen), findsOneWidget);

    await tapTab(tester, 'Alerts');
    expect(find.byType(NotificationsScreen), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);

    await tapTab(tester, 'Home');
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('visited tabs stay alive while another tab is shown', (
    tester,
  ) async {
    await pumpApp(tester);

    await tapTab(tester, 'Teachers');
    await tapTab(tester, 'Chats');

    expect(find.byType(DiscoverScreen), findsNothing);
    expect(find.byType(DiscoverScreen, skipOffstage: false), findsOneWidget);
  });

  testWidgets('centre + opens New post full-screen and Close returns', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.byTooltip('Create post'));
    await tester.pumpAndSettle();
    expect(find.byType(CreatePostScreen), findsOneWidget);
    expect(find.text('New post'), findsOneWidget);
    expect(find.text('Teachers'), findsNothing);

    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.byType(CreatePostScreen), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('system back on a non-Home tab returns to Home', (tester) async {
    await pumpApp(tester);

    await tapTab(tester, 'Chats');
    expect(find.byType(ChatsScreen), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(ChatsScreen), findsNothing);
  });

  testWidgets('system back on New post closes it', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byTooltip('Create post'));
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(CreatePostScreen), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
