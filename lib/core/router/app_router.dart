import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/email_code_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/log_in_screen.dart';
import '../../features/auth/presentation/new_password_screen.dart';
import '../../features/auth/presentation/sign_up_screen.dart';
import '../../features/chat/presentation/chat_screen.dart';
import '../../features/chat/presentation/chats_screen.dart';
import '../../features/connections/presentation/connections_screen.dart';
import '../../features/discover/presentation/discover_screen.dart';
import '../../features/discover/presentation/public_profile_screen.dart';
import '../../features/discover/presentation/search_results_screen.dart';
import '../../features/feed/presentation/home_screen.dart';
import '../../features/feed/presentation/post_detail_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/onboarding/presentation/splash_screen.dart';
import '../../features/onboarding/presentation/welcome_screen.dart';
import '../../features/post/presentation/create_post_screen.dart';
import '../../features/profile/presentation/certificate_viewer_screen.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
import '../../features/profile/presentation/my_profile_screen.dart';
import '../../features/profile_setup/presentation/student_setup_screen.dart';
import '../../features/profile_setup/presentation/teacher_setup_screen.dart';
import '../../features/settings/presentation/blocked_users_screen.dart';
import '../../features/settings/presentation/change_password_screen.dart';
import '../../features/settings/presentation/policy_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../session/session_cubit.dart';
import '../widgets/main_shell.dart';
import 'app_routes.dart';

/// Builds the app's route table, redirecting on the [session]:
/// - signed out → only Splash and the sign-in screens;
/// - signed in with a profile that is not active → that role's profile
///   setup (no Skip; resumes at every log-in);
/// - signed in → never back to the sign-in screens.
GoRouter createAppRouter(SessionCubit session) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: _SessionListenable(session),
    redirect: (context, state) {
      final location = state.matchedLocation;
      if (location == AppRoutes.splash || AppRoutes.isPolicy(location)) {
        return null;
      }
      final current = session.state;
      final user = current.user;
      if (user == null) {
        return AppRoutes.signedOut.contains(location)
            ? null
            : AppRoutes.welcome;
      }
      if (current.needsSetup) {
        final setup = AppRoutes.setupFor(user.role);
        return location == setup ? null : setup;
      }
      return AppRoutes.signedOut.contains(location) ? AppRoutes.home : null;
    },
    routes: <RouteBase>[
      GoRoute(path: AppRoutes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(
        path: AppRoutes.welcome,
        builder: (_, _) => const WelcomeScreen(),
      ),
      GoRoute(path: AppRoutes.signUp, builder: (_, _) => const SignUpScreen()),
      GoRoute(
        path: AppRoutes.signUpCode,
        builder: (_, state) =>
            EmailCodeScreen(email: state.extra as String? ?? ''),
      ),
      GoRoute(path: AppRoutes.logIn, builder: (_, _) => const LogInScreen()),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (_, _) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.newPassword,
        builder: (_, state) =>
            NewPasswordScreen(email: state.extra as String? ?? ''),
      ),
      GoRoute(
        path: AppRoutes.teacherSetup,
        builder: (_, _) => const TeacherSetupScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentSetup,
        builder: (_, _) => const StudentSetupScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.home,
                builder: (_, _) => const HomeScreen(),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'search',
                    builder: (_, _) => const SearchResultsScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.teachers,
                builder: (_, _) => const DiscoverScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.chats,
                builder: (_, _) => const ChatsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.alerts,
                builder: (_, _) => const NotificationsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.createPost,
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          fullscreenDialog: true,
          child: const CreatePostScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.postPattern,
        builder: (_, state) =>
            PostDetailScreen(postId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.profilePattern,
        builder: (_, state) =>
            PublicProfileScreen(profileId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.chatPattern,
        builder: (_, state) =>
            ChatScreen(otherId: state.pathParameters['userId']!),
      ),
      GoRoute(
        path: AppRoutes.connections,
        builder: (_, _) => const ConnectionsScreen(),
      ),
      GoRoute(
        path: AppRoutes.certificateViewer,
        builder: (_, state) => CertificateViewerScreen(
          path: state.uri.queryParameters['path'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.myProfile,
        builder: (_, _) => const MyProfileScreen(),
        routes: <RouteBase>[
          GoRoute(path: 'edit', builder: (_, _) => const EditProfileScreen()),
        ],
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (_, _) => const SettingsScreen(),
        routes: <RouteBase>[
          GoRoute(
            path: 'password',
            builder: (_, _) => const ChangePasswordScreen(),
          ),
          GoRoute(
            path: 'blocked',
            builder: (_, _) => const BlockedUsersScreen(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.policyPattern,
        builder: (_, state) => PolicyScreen(
          page: PolicyPage.values.firstWhere(
            (p) => p.name == state.pathParameters['page'],
            orElse: () => PolicyPage.terms,
          ),
        ),
      ),
    ],
  );
}

/// Notifies go_router whenever the session changes so redirects re-run.
class _SessionListenable extends ChangeNotifier {
  _SessionListenable(SessionCubit session) {
    _subscription = session.stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<Object?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
