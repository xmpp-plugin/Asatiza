import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/session/session_cubit.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../data/models/app_notification.dart';
import '../../../data/models/enums/notification_type.dart';
import '../../../data/models/profile.dart';
import '../../../data/repositories/connection_repository.dart';
import '../../../data/repositories/notification_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../data/repositories/block_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../bloc/notifications_cubit.dart';
import '../bloc/notifications_state.dart';
import 'widgets/notification_tile.dart';
import 'widgets/request_notification_tile.dart';

/// 19 Notifications: New / Earlier, Accept / Decline, Mark all read.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select<SessionCubit, Profile?>((c) => c.state.user);
    if (user == null) {
      return const SizedBox.shrink();
    }
    return BlocProvider<NotificationsCubit>(
      key: ValueKey<String>(user.id),
      create: (context) => NotificationsCubit(
        context.read<NotificationRepository>(),
        context.read<ConnectionRepository>(),
        context.read<ProfileRepository>(),
        context.read<BlockRepository>(),
        viewerId: user.id,
      ),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatelessWidget {
  const _NotificationsView();

  InlineSpan _message(
    AppNotification n,
    Profile? actor,
    AppLocalizations l10n,
  ) {
    const bold = TextStyle(fontWeight: FontWeight.w700);
    final name = TextSpan(text: actor?.fullName ?? '', style: bold);
    TextSpan rest(String text) => TextSpan(text: ' $text');
    return switch (n.type) {
      NotificationType.connectionRequest => TextSpan(
        children: <InlineSpan>[name, rest(l10n.notifWantsToConnect)],
      ),
      NotificationType.requestAccepted => TextSpan(
        children: <InlineSpan>[name, rest(l10n.notifAccepted)],
      ),
      NotificationType.comment => TextSpan(
        children: <InlineSpan>[name, rest(l10n.notifCommented(n.text ?? ''))],
      ),
      NotificationType.likes => TextSpan(
        children: <InlineSpan>[name, rest(l10n.notifLiked(n.othersCount))],
      ),
      NotificationType.teacherApproved => TextSpan(
        children: <InlineSpan>[
          TextSpan(text: l10n.notifApprovedPrefix),
          TextSpan(text: l10n.notifApprovedWord, style: bold),
          TextSpan(text: l10n.notifApprovedSuffix),
        ],
      ),
      NotificationType.teacherNeedsChanges => TextSpan(
        text: l10n.notifNeedsChanges,
      ),
    };
  }

  Future<void> _open(BuildContext context, AppNotification n) async {
    final cubit = context.read<NotificationsCubit>();
    await cubit.open(n);
    if (!context.mounted) {
      return;
    }
    switch (n.type) {
      case NotificationType.comment || NotificationType.likes:
        if (n.postId != null) {
          await context.push(AppRoutes.post(n.postId!));
        }
      case NotificationType.requestAccepted:
        await context.push(AppRoutes.chat(n.actorId!));
      case NotificationType.connectionRequest:
        await context.push(AppRoutes.profile(n.actorId!));
      case NotificationType.teacherApproved ||
          NotificationType.teacherNeedsChanges:
        break;
    }
  }

  Future<void> _respond(
    BuildContext context,
    AppNotification n, {
    required bool accept,
  }) async {
    final accepted = await context.read<NotificationsCubit>().respond(
      n,
      accept: accept,
    );
    if (accepted && context.mounted) {
      await context.push(AppRoutes.chat(n.actorId!));
    }
  }

  Widget _tile(
    BuildContext context,
    NotificationsState state,
    AppNotification n,
    AppLocalizations l10n,
    AppColors colors,
  ) {
    final actor = n.actorId == null ? null : state.people[n.actorId];
    final Widget leading = actor != null
        ? AppAvatar(profile: actor, size: 48, showVerified: true)
        : Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.gold100,
              shape: BoxShape.circle,
            ),
            child: AppIcon(AppIcon.shield, color: colors.gold700),
          );
    return NotificationTile(
      leading: leading,
      message: _message(n, actor, l10n),
      time: n.createdAt,
      unread: !n.read,
      onTap: () => _open(context, n),
      footer: n.type == NotificationType.connectionRequest
          ? RequestNotificationTile(
              note: n.text,
              open: state.isOpenRequest(n),
              onAccept: () => _respond(context, n, accept: true),
              onDecline: () => _respond(context, n, accept: false),
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).extension<AppColors>()!;
    return BlocBuilder<NotificationsCubit, NotificationsState>(
      builder: (context, state) {
        final cubit = context.read<NotificationsCubit>();
        final unread = state.unread;
        final earlier = state.earlier;
        Widget heading(String text, {double top = AppSpacing.space2}) =>
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                AppSpacing.space4,
                top,
                AppSpacing.space4,
                AppSpacing.space2,
              ),
              child: Semantics(
                header: true,
                child: Text(
                  text,
                  style: AppTextStyles.helper.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.inkMuted,
                  ),
                ),
              ),
            );
        return SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  AppSpacing.space4,
                  AppSpacing.space3,
                  AppSpacing.space4,
                  AppSpacing.space3,
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(
                          l10n.notificationsTitle,
                          style: AppTextStyles.screenTitle.copyWith(
                            color: colors.ink,
                          ),
                        ),
                      ),
                    ),
                    if (unread.isNotEmpty)
                      TextButton(
                        onPressed: cubit.markAllRead,
                        style: TextButton.styleFrom(
                          foregroundColor: colors.brand700,
                          textStyle: AppTextStyles.label,
                        ),
                        child: Text(l10n.markAllReadAction),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: state.loading
                    ? const SizedBox.shrink()
                    : unread.isEmpty && earlier.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(AppSpacing.space6),
                        child: Align(
                          alignment: const Alignment(0, -0.4),
                          child: EmptyStateView(
                            icon: AppIcon.bell,
                            title: l10n.emptyNotificationsTitle,
                            message: l10n.emptyNotificationsMessage,
                          ),
                        ),
                      )
                    : ListView(
                        children: <Widget>[
                          if (unread.isNotEmpty) ...<Widget>[
                            heading(l10n.notificationsNew),
                            for (final n in unread)
                              _tile(context, state, n, l10n, colors),
                          ],
                          if (earlier.isNotEmpty) ...<Widget>[
                            heading(
                              l10n.notificationsEarlier,
                              top: unread.isEmpty
                                  ? AppSpacing.space2
                                  : AppSpacing.gap14,
                            ),
                            for (final n in earlier)
                              _tile(context, state, n, l10n, colors),
                          ],
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
