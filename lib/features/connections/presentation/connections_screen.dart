import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/session/session_cubit.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_segmented_control.dart';
import '../../../core/widgets/back_header.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../data/models/connection.dart';
import '../../../data/models/enums/subject.dart';
import '../../../data/models/profile.dart';
import '../../../data/repositories/connection_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../data/repositories/block_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../discover/presentation/widgets/person_row.dart';
import '../bloc/connections_cubit.dart';
import '../bloc/connections_state.dart';
import 'widgets/request_tile.dart';

/// 16 My connections: Connected / Requests / Sent.
class ConnectionsScreen extends StatelessWidget {
  const ConnectionsScreen({super.key, this.initialTab});

  /// Tab to open on; Connected when null.
  final ConnectionsTab? initialTab;

  @override
  Widget build(BuildContext context) {
    final viewer = context.select<SessionCubit, Profile?>((c) => c.state.user);
    if (viewer == null) {
      return const SizedBox.shrink();
    }
    return BlocProvider<ConnectionsCubit>(
      create: (context) => ConnectionsCubit(
        context.read<ConnectionRepository>(),
        context.read<ProfileRepository>(),
        context.read<BlockRepository>(),
        viewerId: viewer.id,
        initialTab: initialTab ?? ConnectionsTab.connected,
      ),
      child: _ConnectionsView(viewer: viewer),
    );
  }
}

class _ConnectionsView extends StatelessWidget {
  const _ConnectionsView({required this.viewer});

  final Profile viewer;

  static String subtitleOf(Profile p, AppLocalizations l10n) {
    if (p.isTeacher) {
      return p.headline ?? l10n.roleTeacher;
    }
    final goals = p.studentDetails?.goals ?? const <Subject>[];
    return goals.isEmpty
        ? l10n.roleStudent
        : l10n.studentLearningSubtitle(goals.first.label(l10n));
  }

  Future<void> _more(BuildContext context, Connection c, Profile p) async {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).extension<AppColors>()!;
    final cubit = context.read<ConnectionsCubit>();
    final choice = await AppBottomSheet.show<String>(
      context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            p.fullName,
            style: AppTextStyles.pageTitle.copyWith(color: colors.ink),
          ),
          const SizedBox(height: AppSpacing.space2),
          Text(
            l10n.blockUserMessage,
            style: AppTextStyles.body.copyWith(color: colors.inkMuted),
          ),
          const SizedBox(height: AppSpacing.space5),
          AppButton(
            label: l10n.removeConnectionAction,
            variant: AppButtonVariant.secondary,
            onPressed: () => Navigator.of(context).pop('remove'),
          ),
          const SizedBox(height: AppSpacing.space2),
          AppButton(
            label: l10n.blockAction,
            variant: AppButtonVariant.danger,
            onPressed: () => Navigator.of(context).pop('block'),
          ),
          const SizedBox(height: AppSpacing.space2),
          SizedBox(
            height: 48,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: colors.brand700,
                textStyle: AppTextStyles.label,
              ),
              child: Text(l10n.cancelAction),
            ),
          ),
        ],
      ),
    );
    switch (choice) {
      case 'remove':
        await cubit.remove(c);
      case 'block':
        await cubit.block(c);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      backgroundColor: colors.surface100,
      body: SafeArea(
        child: BlocBuilder<ConnectionsCubit, ConnectionsState>(
          builder: (context, state) {
            final cubit = context.read<ConnectionsCubit>();
            final counts = <ConnectionsTab, int>{
              ConnectionsTab.connected: state.connected.length,
              ConnectionsTab.requests: state.requests.length,
              ConnectionsTab.sent: state.sent.length,
            };
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                BackHeader(title: l10n.connectionsTitle),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    AppSpacing.space4,
                    AppSpacing.space1,
                    AppSpacing.space4,
                    AppSpacing.space1,
                  ),
                  child: AppSegmentedControl<ConnectionsTab>(
                    values: ConnectionsTab.values,
                    selected: state.tab,
                    label: (t) => switch (t) {
                      ConnectionsTab.connected => l10n.connectedTab(counts[t]!),
                      ConnectionsTab.requests => l10n.requestsTab(counts[t]!),
                      ConnectionsTab.sent => l10n.sentTab(counts[t]!),
                    },
                    onChanged: cubit.tabChanged,
                  ),
                ),
                Expanded(
                  child: state.loading
                      ? const SizedBox.shrink()
                      : _list(context, state, l10n),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _list(
    BuildContext context,
    ConnectionsState state,
    AppLocalizations l10n,
  ) {
    final cubit = context.read<ConnectionsCubit>();
    final items = state.visible;
    if (items.isEmpty) {
      final (String title, String message) = switch (state.tab) {
        ConnectionsTab.connected => (
          l10n.emptyConnectionsTitle,
          l10n.emptyConnectionsMessage,
        ),
        ConnectionsTab.requests => (
          l10n.emptyRequestsTitle,
          l10n.emptyRequestsMessage,
        ),
        ConnectionsTab.sent => (l10n.emptySentTitle, l10n.emptySentMessage),
      };
      final findTeachers =
          state.tab == ConnectionsTab.connected && !viewer.isTeacher;
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.space6),
        child: Align(
          alignment: const Alignment(0, -0.5),
          child: EmptyStateView(
            icon: AppIcon.people,
            title: title,
            message: message,
            actionLabel: findTeachers ? l10n.findTeachersAction : null,
            onAction: findTeachers
                ? () => context.go(AppRoutes.teachers)
                : null,
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.space4,
        AppSpacing.space2,
        AppSpacing.space4,
        AppSpacing.space4,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final c = items[i];
        final p = state.people[c.otherId(viewer.id)]!;
        void open() => context.push(AppRoutes.profile(p.id));
        final subtitle = subtitleOf(p, l10n);
        return switch (state.tab) {
          ConnectionsTab.requests => RequestTile(
            profile: p,
            subtitle: subtitle,
            note: c.note,
            onOpen: open,
            onAccept: () => cubit.respond(c, accept: true),
            onDecline: () => cubit.respond(c, accept: false),
          ),
          ConnectionsTab.sent => PersonRow(
            profile: p,
            subtitle: subtitle,
            onTap: open,
            trailing: AppButton(
              label: l10n.cancelRequestAction,
              onPressed: () => cubit.remove(c),
              size: AppButtonSize.small,
              variant: AppButtonVariant.secondary,
              expand: false,
            ),
          ),
          ConnectionsTab.connected => PersonRow(
            profile: p,
            subtitle: subtitle,
            onTap: open,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                AppButton(
                  label: l10n.messageAction,
                  // Chat becomes real in the Chat phase (PHASE_008).
                  onPressed: () => ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(l10n.chatComingSoon))),
                  size: AppButtonSize.small,
                  variant: AppButtonVariant.secondary,
                  expand: false,
                ),
                IconButton(
                  tooltip: l10n.removeOrBlockAction,
                  onPressed: () => _more(context, c, p),
                  icon: AppIcon(
                    AppIcon.more,
                    size: 22,
                    color: Theme.of(context).extension<AppColors>()!.ink,
                  ),
                ),
              ],
            ),
          ),
        };
      },
    );
  }
}
