import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app.dart';
import 'core/session/session_cubit.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/chat_repository.dart';
import 'data/repositories/connection_repository.dart';
import 'data/repositories/discover_repository.dart';
import 'data/repositories/feed_repository.dart';
import 'data/repositories/notification_repository.dart';
import 'data/repositories/mock/mock_auth_repository.dart';
import 'data/repositories/mock/mock_chat_repository.dart';
import 'data/repositories/mock/mock_connection_repository.dart';
import 'data/repositories/mock/mock_discover_repository.dart';
import 'data/repositories/mock/mock_feed_repository.dart';
import 'data/repositories/mock/mock_notification_repository.dart';
import 'data/repositories/mock/mock_profile_repository.dart';
import 'data/repositories/mock/mock_safety_repository.dart';
import 'data/repositories/profile_repository.dart';
import 'data/repositories/safety_repository.dart';

/// Composition root: the only place concrete repositories are created.
/// UI-only phase: in-memory mock implementations (reset on restart). The
/// backend phases swap them for Supabase implementations here.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _registerFontLicenses();

  final profiles = MockProfileRepository();
  final feed = MockFeedRepository();
  final safety = MockSafetyRepository();
  final discover = MockDiscoverRepository(profiles, safety);
  final connections = MockConnectionRepository(profiles);
  final chats = MockChatRepository(connections);
  final notifications = MockNotificationRepository();
  final auth = MockAuthRepository(
    profiles,
    onDelete: (userId) {
      feed.removeUser(userId);
      chats.removeUser(userId);
      connections.removeUser(userId);
      notifications.removeUser(userId);
      safety.removeUser(userId);
    },
  );

  runApp(
    MultiRepositoryProvider(
      providers: <RepositoryProvider<Object>>[
        RepositoryProvider<AuthRepository>.value(value: auth),
        RepositoryProvider<ProfileRepository>.value(value: profiles),
        RepositoryProvider<FeedRepository>.value(value: feed),
        RepositoryProvider<SafetyRepository>.value(value: safety),
        RepositoryProvider<DiscoverRepository>.value(value: discover),
        RepositoryProvider<ChatRepository>.value(value: chats),
        RepositoryProvider<NotificationRepository>.value(value: notifications),
        RepositoryProvider<ConnectionRepository>.value(value: connections),
      ],
      child: BlocProvider<SessionCubit>(
        create: (_) => SessionCubit(auth, profiles),
        child: const AsatizaApp(),
      ),
    ),
  );
}

/// The bundled fonts use the SIL Open Font License, which requires shipping
/// the license text; it appears on the app's licenses page.
void _registerFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    const fonts = <String, String>{
      'Fraunces': 'assets/fonts/OFL-Fraunces.txt',
      'Plus Jakarta Sans': 'assets/fonts/OFL-PlusJakartaSans.txt',
      'Amiri': 'assets/fonts/OFL-Amiri.txt',
    };
    for (final entry in fonts.entries) {
      final text = await rootBundle.loadString(entry.value);
      yield LicenseEntryWithLineBreaks(<String>[entry.key], text);
    }
  });
}
