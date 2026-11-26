import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/services/document_picker_service.dart';
import 'core/services/file_picker_document_picker_service.dart';
import 'core/services/flutter_image_compress_image_compressor.dart';
import 'core/services/image_compressor.dart';
import 'core/services/image_picker_image_picker_service.dart';
import 'core/services/image_picker_service.dart';
import 'core/session/session_cubit.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/block_repository.dart';
import 'data/repositories/chat_repository.dart';
import 'data/repositories/connection_repository.dart';
import 'data/repositories/discover_repository.dart';
import 'data/repositories/feed_repository.dart';
import 'data/repositories/media_repository.dart';
import 'data/repositories/notification_repository.dart';
import 'data/repositories/mock/mock_chat_repository.dart';
import 'data/repositories/mock/mock_connection_repository.dart';
import 'data/repositories/mock/mock_feed_repository.dart';
import 'data/repositories/mock/mock_notification_repository.dart';
import 'data/repositories/mock/mock_profile_repository.dart';
import 'data/repositories/mock/mock_safety_repository.dart';
import 'data/repositories/profile_repository.dart';
import 'data/repositories/safety_repository.dart';
import 'data/repositories/supabase/supabase_auth_repository.dart';
import 'data/repositories/supabase/supabase_block_repository.dart';
import 'data/repositories/supabase/supabase_connection_repository.dart';
import 'data/repositories/supabase/supabase_discover_repository.dart';
import 'data/repositories/supabase/supabase_media_repository.dart';
import 'data/repositories/supabase/supabase_profile_repository.dart';

/// Composition root: the only place concrete repositories are created.
///
/// Each repository is either real (Supabase) or mock, never both:
/// - real: accounts ([AuthRepository]), profiles ([ProfileRepository]),
///   Storage uploads ([MediaRepository]), the Teachers / Students tabs
///   ([DiscoverRepository]), blocks ([BlockRepository]) and connections
///   ([ConnectionRepository]);
/// - mock until their phases: feed, chat, notifications and post reports
///   ([SafetyRepository]) (in-memory sample people, reset on restart).
/// When a feature becomes real, replace its mock line below and move the
/// mock class out of `lib/` into `test/fakes/` (PHASE_007 rule: the app
/// keeps only the implementation it runs).
///
/// Supabase settings: `--dart-define-from-file=…` when given, otherwise the
/// bundled `env/supabase.json` (so a plain `flutter run` works). Without
/// either the app stops with a clear error. Tests use the mocks directly and
/// never call [main].
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final config = await _loadConfig();
  if (!config.hasBackend) {
    throw StateError(
      'Supabase settings missing. Fill in ${AppConfig.assetPath} '
      '(copy env/supabase.example.json).',
    );
  }

  _registerFontLicenses();

  await Supabase.initialize(
    url: config.supabaseUrl,
    // The public key: the publishable key or the legacy anon key.
    publishableKey: config.supabaseAnonKey,
  );
  final client = Supabase.instance.client;

  // Real.
  final supabaseProfiles = SupabaseProfileRepository(client);
  final ProfileRepository userProfiles = supabaseProfiles;
  final MediaRepository media = SupabaseMediaRepository(client);
  final BlockRepository blocks = SupabaseBlockRepository(client);
  final ConnectionRepository connections = SupabaseConnectionRepository(client);
  final DiscoverRepository discover = SupabaseDiscoverRepository(
    client,
    blocks,
  );
  final AuthRepository auth = SupabaseAuthRepository(
    client,
    supabaseProfiles,
    media,
  );

  // Platform services (plugins live only in their implementations).
  final ImagePickerService imagePicker = ImagePickerImagePickerService();
  const ImageCompressor imageCompressor = FlutterImageCompressImageCompressor();
  const DocumentPickerService documentPicker =
      FilePickerDocumentPickerService();

  // Mock until their phases. `sampleProfiles` and `sampleConnections` are
  // only the sample data these mocks show; they are not registered as the
  // app's ProfileRepository / ConnectionRepository.
  final sampleProfiles = MockProfileRepository();
  final feed = MockFeedRepository();
  final safety = MockSafetyRepository();
  final sampleConnections = MockConnectionRepository(sampleProfiles);
  final chats = MockChatRepository(sampleConnections);
  final notifications = MockNotificationRepository();

  runApp(
    MultiRepositoryProvider(
      providers: <RepositoryProvider<Object>>[
        RepositoryProvider<AuthRepository>.value(value: auth),
        RepositoryProvider<ProfileRepository>.value(value: userProfiles),
        RepositoryProvider<MediaRepository>.value(value: media),
        RepositoryProvider<ImagePickerService>.value(value: imagePicker),
        RepositoryProvider<ImageCompressor>.value(value: imageCompressor),
        RepositoryProvider<DocumentPickerService>.value(value: documentPicker),
        RepositoryProvider<FeedRepository>.value(value: feed),
        RepositoryProvider<SafetyRepository>.value(value: safety),
        RepositoryProvider<BlockRepository>.value(value: blocks),
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

/// Defines win; otherwise reads the bundled public settings file.
Future<AppConfig> _loadConfig() async {
  const fromDefines = AppConfig.fromEnvironment();
  if (fromDefines.hasBackend) return fromDefines;
  final text = await rootBundle.loadString(AppConfig.assetPath);
  return AppConfig.fromJson(jsonDecode(text) as Map<String, dynamic>);
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
