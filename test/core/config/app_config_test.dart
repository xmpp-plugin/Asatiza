import 'package:asatiza/core/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('no defines → mock mode', () {
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
}
