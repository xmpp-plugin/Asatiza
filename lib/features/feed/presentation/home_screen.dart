import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/logic/profile_strength_calculator.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/session/session_cubit.dart';
import '../../../core/session/session_state.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/post_card.dart';
import '../../../core/widgets/post_card_skeleton.dart';
import '../../../core/widgets/profile_strength_card.dart';
import '../../../data/models/post.dart';
import '../../../data/models/profile.dart';
import '../../../data/repositories/feed_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../data/repositories/safety_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../safety/presentation/report_sheet.dart';
import '../bloc/feed_cubit.dart';
import '../bloc/feed_state.dart';
import 'widgets/home_top_bar.dart';

/// 08 Home: top bar, profile-strength card, and the feed (connections
/// first, then everyone, newest first).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select<SessionCubit, Profile?>((c) => c.state.user);
    if (user == null) {
      return const SizedBox.shrink();
    }
    return BlocProvider<FeedCubit>(
      key: ValueKey<String>(user.id),
      create: (context) => FeedCubit(
        context.read<FeedRepository>(),
        context.read<ProfileRepository>(),
        context.read<SafetyRepository>(),
        viewerId: user.id,
      ),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  static const ProfileStrengthCalculator _calculator =
      ProfileStrengthCalculator();

  Future<void> _report(
    BuildContext context,
    Post post,
    Profile author,
    Profile user,
  ) => ReportSheet.show(
    context,
    post: post,
    author: author,
    reporterId: user.id,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<SessionCubit, SessionState>(
      builder: (context, session) {
        final user = session.user!;
        return SafeArea(
          child: Column(
            children: <Widget>[
              HomeTopBar(
                user: user,
                // My profile and search results arrive with part 2. Until then
                // the avatar opens profile setup (where the profile is edited)
                // and search opens the Teachers tab.
                onAvatarTap: () => context.push(AppRoutes.setupFor(user.role)),
                onSearchTap: () => context.go(AppRoutes.teachers),
              ),
              Expanded(
                child: BlocBuilder<FeedCubit, FeedState>(
                  builder: (context, state) {
                    final cubit = context.read<FeedCubit>();
                    final showStrength =
                        !state.strengthCardDismissed &&
                        _calculator.percent(user) < 100;
                    final posts = state.visiblePosts;
                    final children = <Widget>[
                      if (showStrength)
                        ProfileStrengthCard(
                          profile: user,
                          onComplete: () =>
                              context.push(AppRoutes.setupFor(user.role)),
                          onDismiss: cubit.dismissStrengthCard,
                        ),
                      if (state.status == FeedStatus.loading) ...const <Widget>[
                        PostCardSkeleton(),
                        PostCardSkeleton(),
                      ] else if (posts.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(
                            top: AppSpacing.space8,
                          ),
                          child: EmptyStateView(
                            icon: AppIcon.bookOpen,
                            title: l10n.emptyFeedTitle,
                            message: l10n.emptyFeedMessage,
                            actionLabel: l10n.findTeachersAction,
                            onAction: () => context.go(AppRoutes.teachers),
                          ),
                        )
                      else
                        for (final post in posts)
                          PostCard(
                            key: ValueKey<String>(post.id),
                            post: post,
                            author: state.authors[post.authorId]!,
                            onOpen: () => context.push(AppRoutes.post(post.id)),
                            onLike: () => cubit.toggleLike(post.id),
                            onComment: () =>
                                context.push(AppRoutes.post(post.id)),
                            onReport: post.authorId == user.id
                                ? null
                                : () => _report(
                                    context,
                                    post,
                                    state.authors[post.authorId]!,
                                    user,
                                  ),
                            onMore: post.authorId == user.id
                                ? null
                                : () => _report(
                                    context,
                                    post,
                                    state.authors[post.authorId]!,
                                    user,
                                  ),
                          ),
                    ];
                    return ListView.separated(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        AppSpacing.space4,
                        AppSpacing.space1,
                        AppSpacing.space4,
                        AppSpacing.space4,
                      ),
                      itemCount: children.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.space3),
                      itemBuilder: (_, i) => children[i],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
