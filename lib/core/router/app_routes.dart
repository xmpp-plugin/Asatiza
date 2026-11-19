/// Route paths used with go_router. Features navigate with these
/// constants, never with string literals.
abstract final class AppRoutes {
  static const String home = '/home';
  static const String teachers = '/teachers';
  static const String chats = '/chats';
  static const String alerts = '/alerts';

  /// Full-screen route opened by the centre "+" button.
  static const String createPost = '/create-post';
}
