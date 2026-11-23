import 'dart:async';

import 'package:asatiza/app.dart';
import 'package:asatiza/core/session/session_cubit.dart';
import 'package:asatiza/core/widgets/app_text_field.dart';
import 'package:asatiza/core/widgets/otp_input.dart';
import 'package:asatiza/data/mock/mock_profiles.dart';
import 'package:asatiza/data/repositories/auth_repository.dart';
import 'package:asatiza/data/repositories/chat_repository.dart';
import 'package:asatiza/data/repositories/connection_repository.dart';
import 'package:asatiza/data/repositories/discover_repository.dart';
import 'package:asatiza/data/repositories/feed_repository.dart';
import 'package:asatiza/data/repositories/notification_repository.dart';
import 'package:asatiza/data/repositories/mock/mock_auth_repository.dart';
import 'package:asatiza/data/repositories/mock/mock_chat_repository.dart';
import 'package:asatiza/data/repositories/mock/mock_connection_repository.dart';
import 'package:asatiza/data/repositories/mock/mock_discover_repository.dart';
import 'package:asatiza/data/repositories/mock/mock_feed_repository.dart';
import 'package:asatiza/data/repositories/mock/mock_notification_repository.dart';
import 'package:asatiza/data/repositories/mock/mock_profile_repository.dart';
import 'package:asatiza/data/repositories/mock/mock_safety_repository.dart';
import 'package:asatiza/data/repositories/profile_repository.dart';
import 'package:asatiza/data/repositories/safety_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

/// The app wired with fresh mock repositories, as in `main.dart`.
class TestApp {
  TestApp()
    : profiles = MockProfileRepository(),
      feed = MockFeedRepository(),
      safety = MockSafetyRepository() {
    discover = MockDiscoverRepository(profiles, safety);
    connections = MockConnectionRepository(profiles);
    chats = MockChatRepository(connections);
    notifications = MockNotificationRepository();
    auth = MockAuthRepository(
      profiles,
      onDelete: (userId) {
        feed.removeUser(userId);
        chats.removeUser(userId);
        connections.removeUser(userId);
        notifications.removeUser(userId);
        safety.removeUser(userId);
      },
    );
    session = SessionCubit(auth, profiles);
  }

  final MockProfileRepository profiles;
  final MockFeedRepository feed;
  final MockSafetyRepository safety;
  late final MockAuthRepository auth;
  late final MockDiscoverRepository discover;
  late final MockConnectionRepository connections;
  late final MockChatRepository chats;
  late final MockNotificationRepository notifications;
  late final SessionCubit session;

  Widget build() => MultiRepositoryProvider(
    providers: <RepositoryProvider<Object>>[
      RepositoryProvider<AuthRepository>.value(value: auth),
      RepositoryProvider<ProfileRepository>.value(value: profiles),
      RepositoryProvider<FeedRepository>.value(value: feed),
      RepositoryProvider<SafetyRepository>.value(value: safety),
      RepositoryProvider<DiscoverRepository>.value(value: discover),
      RepositoryProvider<ConnectionRepository>.value(value: connections),
      RepositoryProvider<ChatRepository>.value(value: chats),
      RepositoryProvider<NotificationRepository>.value(value: notifications),
    ],
    child: BlocProvider<SessionCubit>.value(
      value: session,
      child: const AsatizaApp(),
    ),
  );

  /// Pumps the app, waits past the splash and lands on Welcome.
  Future<void> start(WidgetTester tester) async {
    await loadDesignFonts();
    tester.view.physicalSize = const Size(390, 844) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(build());
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle();
  }

  /// Starts signed in as a mock account and lands on Home.
  Future<void> startSignedIn(
    WidgetTester tester, {
    bool teacher = false,
  }) async {
    await start(tester);
    // Signs in by profile id so screen tests do not depend on the mock
    // login emails.
    final user = await profiles.getProfile(
      teacher ? MockIds.ahmed : MockIds.ayesha,
    );
    session.signedIn(user);
    await tester.pumpAndSettle();
  }

  /// Unmounts the app so cubits close and their timers stop.
  Future<void> stop(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    // Not awaited: the app is already unmounted and nothing depends on it.
    unawaited(session.close());
  }
}

/// Types into the [AppTextField] labelled [label].
Future<void> enterField(WidgetTester tester, String label, String text) async {
  await tester.enterText(
    find.descendant(
      of: find.widgetWithText(AppTextField, label),
      matching: find.byType(TextField),
    ),
    text,
  );
  await tester.pump();
}

/// Types a code into the visible [OtpInput].
Future<void> enterCode(WidgetTester tester, String code) async {
  await tester.enterText(
    find.descendant(
      of: find.byType(OtpInput),
      matching: find.byType(TextField),
    ),
    code,
  );
  await tester.pumpAndSettle();
}

/// Taps the first widget showing [text] and settles.
Future<void> tapText(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text).first);
  await tester.tap(find.text(text).first);
  await tester.pumpAndSettle();
}

bool _fontsLoaded = false;

/// Loads the bundled design fonts so text measures like on a device
/// (tests otherwise use the wide Ahem test font).
Future<void> loadDesignFonts() async {
  if (_fontsLoaded) {
    return;
  }
  _fontsLoaded = true;
  const families = <String, List<String>>{
    'Fraunces': <String>['assets/fonts/Fraunces-SemiBold.ttf'],
    'PlusJakartaSans': <String>[
      'assets/fonts/PlusJakartaSans-Regular.ttf',
      'assets/fonts/PlusJakartaSans-Medium.ttf',
      'assets/fonts/PlusJakartaSans-SemiBold.ttf',
      'assets/fonts/PlusJakartaSans-Bold.ttf',
    ],
    'Amiri': <String>['assets/fonts/Amiri-Regular.ttf'],
  };
  for (final entry in families.entries) {
    final loader = FontLoader(entry.key);
    for (final asset in entry.value) {
      loader.addFont(rootBundle.load(asset));
    }
    await loader.load();
  }
}
