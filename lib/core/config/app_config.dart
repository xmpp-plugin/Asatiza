/// Run-time settings: the Supabase URL and public key.
///
/// Read from `--dart-define` / `--dart-define-from-file` when given,
/// otherwise from the bundled, git-ignored `env/supabase.json` (copy
/// `env/supabase.example.json`). Never hard-code real values. Both values are
/// required: `main` stops with an error without them.
class AppConfig {
  const AppConfig({required this.supabaseUrl, required this.supabaseAnonKey});

  /// Reads the compile-time defines `SUPABASE_URL` and `SUPABASE_ANON_KEY`.
  const AppConfig.fromEnvironment()
    : supabaseUrl = const String.fromEnvironment('SUPABASE_URL'),
      supabaseAnonKey = const String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Reads the decoded `env/supabase.json`.
  ///
  /// The file ships inside the app, so only the two public keys are allowed:
  /// any other key throws a [StateError] (keeps secrets out of the build).
  factory AppConfig.fromJson(Map<String, dynamic> json) {
    final extra = json.keys.where((k) => !allowedKeys.contains(k)).toList();
    if (extra.isNotEmpty) {
      throw StateError(
        'env/supabase.json may contain only ${allowedKeys.join(', ')}; '
        'remove: ${extra.join(', ')}',
      );
    }
    String read(String key) {
      final value = json[key];
      return value is String ? value : '';
    }

    return AppConfig(
      supabaseUrl: read('SUPABASE_URL'),
      supabaseAnonKey: read('SUPABASE_ANON_KEY'),
    );
  }

  /// The only keys allowed in the bundled settings file.
  static const List<String> allowedKeys = <String>[
    'SUPABASE_URL',
    'SUPABASE_ANON_KEY',
  ];

  /// Bundled settings file (asset path).
  static const String assetPath = 'env/supabase.json';

  final String supabaseUrl;

  /// The public client key (publishable key or legacy anon key); never the
  /// `service_role` / secret key.
  final String supabaseAnonKey;

  /// True when both settings are present.
  bool get hasBackend =>
      supabaseUrl.trim().isNotEmpty && supabaseAnonKey.trim().isNotEmpty;
}
