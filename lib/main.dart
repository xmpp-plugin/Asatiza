import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/app_config.dart';
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
import 'data/repositories/supabase/supabase_auth_repository.dart';
import 'data/repositories/supabase/supabase_profile_repository.dart';



/// Composition root: the only place concrete repositories are created.
///
/// Two run modes ([AppConfig]):
/// - mock (no Supabase settings; tests and demos): every repository is an
///   in-memory mock that resets on restart;
/// - backend (`--dart-define-from-file=env/dev.json`): accounts and profiles
///   use Supabase; feed, discover, connections, chat, notifications and
///   safety stay mock until their phases (they only know the seeded people).
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _registerFontLicenses();

  const config = AppConfig.fromEnvironment();

  final mockProfiles = MockProfileRepository();
  final feed = MockFeedRepository();
  final safety = MockSafetyRepository();
  final discover = MockDiscoverRepository(mockProfiles, safety);
  final connections = MockConnectionRepository(mockProfiles);
  final chats = MockChatRepository(connections);
  final notifications = MockNotificationRepository();
  final mockAuth = MockAuthRepository(
    mockProfiles,
    onDelete: (userId) {
      feed.removeUser(userId);
      chats.removeUser(userId);
      connections.removeUser(userId);
      notifications.removeUser(userId);
      safety.removeUser(userId);
    },
  );

  AuthRepository auth = mockAuth;
  ProfileRepository userProfiles = mockProfiles;
  if (config.hasBackend) {
    await Supabase.initialize(
      url: config.supabaseUrl,
      // The public key: the publishable key or the legacy anon key.
      publishableKey: config.supabaseAnonKey,
    );
    final client = Supabase.instance.client;
    final supabaseProfiles = SupabaseProfileRepository(client);
    userProfiles = supabaseProfiles;
    auth = SupabaseAuthRepository(client, supabaseProfiles);
  }

  runApp(
    MultiRepositoryProvider(
      providers: <RepositoryProvider<Object>>[
        RepositoryProvider<AuthRepository>.value(value: auth),
        RepositoryProvider<ProfileRepository>.value(value: userProfiles),
        RepositoryProvider<FeedRepository>.value(value: feed),
        RepositoryProvider<SafetyRepository>.value(value: safety),
        RepositoryProvider<DiscoverRepository>.value(value: discover),
        RepositoryProvider<ChatRepository>.value(value: chats),
        RepositoryProvider<NotificationRepository>.value(value: notifications),
        RepositoryProvider<ConnectionRepository>.value(value: connections),
      ],
      child: BlocProvider<SessionCubit>(
        create: (_) => SessionCubit(auth, userProfiles),
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
