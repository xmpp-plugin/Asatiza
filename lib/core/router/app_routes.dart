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
