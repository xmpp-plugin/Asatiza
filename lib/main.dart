import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app.dart';
import 'core/session/session_cubit.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/feed_repository.dart';
import 'data/repositories/mock/mock_auth_repository.dart';
import 'data/repositories/mock/mock_feed_repository.dart';
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
  final auth = MockAuthRepository(profiles);
  final feed = MockFeedRepository();
  final safety = MockSafetyRepository();

  runApp(
    MultiRepositoryProvider(
      providers: <RepositoryProvider<Object>>[
        RepositoryProvider<AuthRepository>.value(value: auth),
        RepositoryProvider<ProfileRepository>.value(value: profiles),
        RepositoryProvider<FeedRepository>.value(value: feed),
        RepositoryProvider<SafetyRepository>.value(value: safety),
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
