import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/session/session_cubit.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_switch_tile.dart';
import '../../../core/widgets/back_header.dart';
import '../../../core/widgets/settings_tile.dart';
import '../../../data/models/profile.dart';
import '../../../data/repositories/notification_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../bloc/settings_cubit.dart';
import '../bloc/settings_state.dart';
import 'delete_account_sheet.dart';
import 'log_out_sheet.dart';
import 'policy_screen.dart';

/// 21 Settings: account, notification switches, privacy & safety, log out
/// and delete account.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  /// Shown under the list.
  static const String appVersion = '1.0.0';

  @override
  Widget build(BuildContext context) {
    final user = context.select<SessionCubit, Profile?>((c) => c.state.user);
    if (user == null) {
      return const SizedBox.shrink();
    }
    return BlocProvider<SettingsCubit>(
      create: (context) => SettingsCubit(
        context.read<NotificationRepository>(),
        viewerId: user.id,
      ),
      child: _SettingsView(user: user),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView({required this.user});

  final Profile user;

  Future<void> _logOut(BuildContext context) async {
    final session = context.read<SessionCubit>();
    if (await LogOutSheet.show(context)) {
      await session.logOut();
    }
  }

  Future<void> _delete(BuildContext context) async {
    final session = context.read<SessionCubit>();
    if (await DeleteAccountSheet.show(context, userId: user.id)) {
      await session.logOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).extension<AppColors>()!;
    Widget section(String? title, List<Widget> tiles) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (title != null)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppSpacing.space1,
              0,
              AppSpacing.space1,
              AppSpacing.space2,
            ),
            child: Semantics(
              header: true,
              child: Text(
                title,
                style: AppTextStyles.helper.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.inkMuted,
                ),
              ),
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surface000,
              border: Border.all(color: colors.line),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Material(
              type: MaterialType.transparency,
              child: Column(children: tiles),
            ),
          ),
        ),
      ],
    );
    return Scaffold(
      backgroundColor: colors.surface100,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            BackHeader(title: l10n.settingsTitle),
            Expanded(
              child: BlocBuilder<SettingsCubit, SettingsState>(
                builder: (context, state) {
                  final cubit = context.read<SettingsCubit>();
                  final n = state.notifications;
                  const gap = SizedBox(height: AppSpacing.gap18);
                  return ListView(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      AppSpacing.space4,
                      AppSpacing.space1,
                      AppSpacing.space4,
                      AppSpacing.space6,
                    ),
                    children: <Widget>[
                      section(l10n.settingsAccount, <Widget>[
                        SettingsTile(
                          icon: AppIcon.keyIcon,
                          label: l10n.changePasswordTitle,
                          onTap: () => context.push(AppRoutes.changePassword),
                        ),
                        SettingsTile(
                          icon: AppIcon.mail,
                          label: l10n.emailLabel,
                          value: user.email,
                          onTap: null,
                        ),
                      ]),
                      gap,
                      section(l10n.settingsNotifications, <Widget>[
                        AppSwitchTile(
                          label: l10n.settingConnectionRequests,
                          value: n.connectionRequests,
                          onChanged: (v) =>
                              cubit.update(n.copyWith(connectionRequests: v)),
                        ),
                        AppSwitchTile(
                          label: l10n.settingNewMessages,
                          value: n.newMessages,
                          onChanged: (v) =>
                              cubit.update(n.copyWith(newMessages: v)),
                        ),
                        AppSwitchTile(
                          label: l10n.settingComments,
                          value: n.comments,
                          onChanged: (v) =>
                              cubit.update(n.copyWith(comments: v)),
                        ),
                        AppSwitchTile(
                          label: l10n.settingLikes,
                          value: n.likes,
                          onChanged: (v) => cubit.update(n.copyWith(likes: v)),
                        ),
                      ]),
                      gap,
                      section(l10n.settingsPrivacySafety, <Widget>[
                        SettingsTile(
                          icon: AppIcon.ban,
                          label: l10n.blockedUsersTitle,
                          onTap: () => context.push(AppRoutes.blockedUsers),
                        ),
                        SettingsTile(
                          icon: AppIcon.shield,
                          label: l10n.contentPolicyTitle,
                          onTap: () => context.push(
                            AppRoutes.policy(PolicyPage.content.name),
                          ),
                        ),
                        SettingsTile(
                          icon: AppIcon.document,
                          label: l10n.privacyPolicyTitle,
                          onTap: () => context.push(
                            AppRoutes.policy(PolicyPage.privacy.name),
                          ),
                        ),
                        SettingsTile(
                          icon: AppIcon.document,
                          label: l10n.termsTitle,
                          onTap: () => context.push(
                            AppRoutes.policy(PolicyPage.terms.name),
                          ),
                        ),
                      ]),
                      gap,
                      section(null, <Widget>[
                        SettingsTile(
                          icon: AppIcon.logOut,
                          label: l10n.logOutAction,
                          chevron: false,
                          onTap: () => _logOut(context),
                        ),
                        SettingsTile(
                          icon: AppIcon.trash,
                          label: l10n.deleteAccountAction,
                          chevron: false,
                          danger: true,
                          onTap: () => _delete(context),
                        ),
                      ]),
                      gap,
                      Text(
                        l10n.appVersionLabel(SettingsScreen.appVersion),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.w400,
                          color: colors.inkMuted,
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
