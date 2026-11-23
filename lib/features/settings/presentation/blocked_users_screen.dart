import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/session/session_cubit.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/back_header.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../data/models/profile.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../data/repositories/safety_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../discover/presentation/widgets/person_row.dart';
import '../bloc/blocked_users_cubit.dart';
import '../bloc/blocked_users_state.dart';

/// 21b Blocked users (and its empty state).
class BlockedUsersScreen extends StatelessWidget {
  const BlockedUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select<SessionCubit, Profile?>((c) => c.state.user);
    if (user == null) {
      return const SizedBox.shrink();
    }
    return BlocProvider<BlockedUsersCubit>(
      create: (context) => BlockedUsersCubit(
        context.read<SafetyRepository>(),
        context.read<ProfileRepository>(),
        viewerId: user.id,
      ),
      child: const _BlockedUsersView(),
    );
  }
}

class _BlockedUsersView extends StatelessWidget {
  const _BlockedUsersView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      backgroundColor: colors.surface100,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            BackHeader(title: l10n.blockedUsersTitle),
            Expanded(
              child: BlocBuilder<BlockedUsersCubit, BlockedUsersState>(
                builder: (context, state) {
                  if (state.loading) {
                    return const SizedBox.shrink();
                  }
                  final items = state.visible;
                  if (items.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.space8,
                      ),
                      child: Align(
                        alignment: const Alignment(0, -0.2),
                        child: EmptyStateView(
                          icon: AppIcon.ban,
                          title: l10n.noBlockedUsersTitle,
                          message: l10n.noBlockedUsersMessage,
                        ),
                      ),
                    );
                  }
                  final cubit = context.read<BlockedUsersCubit>();
                  return ListView(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      AppSpacing.space4,
                      AppSpacing.space1,
                      AppSpacing.space4,
                      AppSpacing.space4,
                    ),
                    children: <Widget>[
                      Text(
                        l10n.blockedUsersIntro,
                        style: AppTextStyles.body.copyWith(
                          color: colors.inkMuted,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.space3),
                      for (final b in items)
                        PersonRow(
                          profile: state.people[b.userId]!,
                          subtitle: l10n.blockedOn(
                            DateFormat(
                              'd MMM y',
                              l10n.localeName,
                            ).format(b.blockedAt),
                          ),
                          trailing: AppButton(
                            label: l10n.unblockAction,
                            onPressed: () => cubit.unblock(b.userId),
                            size: AppButtonSize.small,
                            variant: AppButtonVariant.secondary,
                            expand: false,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
