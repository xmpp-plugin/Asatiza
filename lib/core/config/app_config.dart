/// Run-time settings passed with `--dart-define` or
/// `--dart-define-from-file=env/dev.json` (git-ignored; see
/// `env/dev.example.json`). Never hard-code real values.
///
/// Without both values the app runs on the in-memory mock repositories.
class AppConfig {
  const AppConfig({required this.supabaseUrl, required this.supabaseAnonKey});

  /// Reads the compile-time defines `SUPABASE_URL` and `SUPABASE_ANON_KEY`.
  const AppConfig.fromEnvironment()
    : supabaseUrl = const String.fromEnvironment('SUPABASE_URL'),
      supabaseAnonKey = const String.fromEnvironment('SUPABASE_ANON_KEY');

  final String supabaseUrl;

  /// The public client key (publishable key or legacy anon key); never the
  /// `service_role` / secret key.
  final String supabaseAnonKey;

  /// True when both settings are present: accounts and profiles use Supabase.
  bool get hasBackend =>
      supabaseUrl.trim().isNotEmpty && supabaseAnonKey.trim().isNotEmpty;
}
