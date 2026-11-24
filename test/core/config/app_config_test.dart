import 'package:asatiza/core/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('no defines → no backend settings', () {
    // `flutter test` runs without --dart-define: tests always use mocks.
    expect(const AppConfig.fromEnvironment().hasBackend, isFalse);
  });

  test('backend mode needs both the URL and the key', () {
    expect(
      const AppConfig(
        supabaseUrl: 'https://x.supabase.co',
        supabaseAnonKey: '',
      ).hasBackend,
      isFalse,
    );
    expect(
      const AppConfig(supabaseUrl: ' ', supabaseAnonKey: 'key').hasBackend,
      isFalse,
    );
    expect(
      const AppConfig(
        supabaseUrl: 'https://x.supabase.co',
        supabaseAnonKey: 'key',
      ).hasBackend,
      isTrue,
    );
  });

  test('settings file: the two public keys are read', () {
    final config = AppConfig.fromJson(const <String, dynamic>{
      'SUPABASE_URL': 'https://x.supabase.co',
      'SUPABASE_ANON_KEY': 'key',
    });
    expect(config.supabaseUrl, 'https://x.supabase.co');
    expect(config.supabaseAnonKey, 'key');
    expect(config.hasBackend, isTrue);
    expect(AppConfig.fromJson(const <String, dynamic>{}).hasBackend, isFalse);
  });

  test('settings file: any other key is refused (it ships in the app)', () {
    expect(
      () => AppConfig.fromJson(const <String, dynamic>{
        'SUPABASE_URL': 'https://x.supabase.co',
        'SUPABASE_ANON_KEY': 'key',
        'SECRET': 'x',
      }),
      throwsStateError,
    );
  });
}
