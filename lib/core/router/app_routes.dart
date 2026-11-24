import '../../data/models/enums/user_role.dart';

/// Route paths used with go_router. Features navigate with these
/// constants, never with string literals.
abstract final class AppRoutes {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String signUp = '/sign-up';
  static const String signUpCode = '/sign-up/code';
  static const String logIn = '/log-in';
  static const String forgotPassword = '/forgot-password';
  static const String newPassword = '/forgot-password/new';

  static const String teacherSetup = '/setup/teacher';
  static const String studentSetup = '/setup/student';

  static const String home = '/home';
  static const String teachers = '/teachers';
  static const String chats = '/chats';
  static const String alerts = '/alerts';

  /// Full-screen route opened by the centre "+" button.
  static const String createPost = '/create-post';

  /// Post detail: `/post/<id>`.
  static const String postPattern = '/post/:id';
  static String post(String id) => '/post/$id';

  /// Home search results (inside the Home tab, keeps the bottom bar).
  static const String search = '/home/search';

  static const String profilePattern = '/profile/:id';
  static String profile(String id) => '/profile/$id';

  static const String connections = '/connections';

  static const String myProfile = '/me';
  static const String editProfile = '/me/edit';
  static const String settings = '/settings';
  static const String changePassword = '/settings/password';

  /// The signed-in teacher's own certificate in the in-app PDF viewer
  /// (PHASE_005): `/certificate?path=<storage path>`.
  static const String certificateViewer = '/certificate';
  static String certificate(String path) => Uri(
    path: certificateViewer,
    queryParameters: <String, String>{'path': path},
  ).toString();
  static const String blockedUsers = '/settings/blocked';

  /// Content / privacy / terms pages; open while signed in or out.
  static const String policyPattern = '/policy/:page';
  static String policy(String page) => '/policy/$page';
  static bool isPolicy(String location) => location.startsWith('/policy/');

  /// Chat with one connection, by the other person's id.
  static const String chatPattern = '/chat/:userId';
  static String chat(String userId) => '/chat/$userId';

  /// Screens reachable while signed out.
  static const Set<String> signedOut = <String>{
    welcome,
    signUp,
    signUpCode,
    logIn,
    forgotPassword,
    newPassword,
  };

  static String setupFor(UserRole role) =>
      role == UserRole.teacher ? teacherSetup : studentSetup;
}
