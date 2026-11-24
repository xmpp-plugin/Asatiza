import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/failures.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/session/session_cubit.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/back_header.dart';
import '../../../core/widgets/confirm_sheet.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../bloc/change_password_cubit.dart';
import '../bloc/change_password_state.dart';

/// 21a Change password.
class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ChangePasswordCubit>(
      create: (context) => ChangePasswordCubit(context.read<AuthRepository>()),
      child: const _ChangePasswordView(),
    );
  }
}

class _ChangePasswordView extends StatelessWidget {
  const _ChangePasswordView();

  /// The reset flow is for signed-out users: confirm, log out, then open it.
  Future<void> _forgot(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final session = context.read<SessionCubit>();
    final router = GoRouter.of(context);
    final ok = await ConfirmSheet.show(
      context,
      title: l10n.resetByEmailTitle,
      message: l10n.resetByEmailMessage,
      confirmLabel: l10n.continueAction,
      cancelLabel: l10n.cancelAction,
    );
    if (ok) {
      await session.logOut();
      router.go(AppRoutes.forgotPassword);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).extension<AppColors>()!;
    return BlocConsumer<ChangePasswordCubit, ChangePasswordState>(
      listenWhen: (a, b) => !a.saved && b.saved,
      listener: (context, _) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.passwordChangedMessage)));
        context.pop();
      },
      builder: (context, state) {
        final cubit = context.read<ChangePasswordCubit>();
        Widget rule(bool ok, String text) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.gap6),
          child: MergeSemantics(
            child: Row(
              children: <Widget>[
                AppIcon(
                  ok ? AppIcon.check : AppIcon.close,
                  size: 16,
                  strokeWidth: 2.4,
                  color: ok ? colors.brand700 : colors.inkMuted,
                ),
                const SizedBox(width: AppSpacing.space2),
                Text(
                  text,
                  style: AppTextStyles.helper.copyWith(
                    color: ok ? colors.brand700 : colors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
        );
        return Scaffold(
          backgroundColor: colors.surface100,
          body: SafeArea(
            child: Column(
              children: <Widget>[
                BackHeader(title: l10n.changePasswordTitle),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      AppSpacing.space5,
                      AppSpacing.space1,
                      AppSpacing.space5,
                      AppSpacing.space6,
                    ),
                    children: <Widget>[
                      Text(
                        l10n.changePasswordIntro,
                        style: AppTextStyles.bodyMd.copyWith(
                          color: colors.inkMuted,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.gap18),
                      AppTextField(
                        label: l10n.currentPasswordLabel,
                        obscure: true,
                        onChanged: cubit.currentChanged,
                        errorText:
                            state.error == ValidationReason.wrongCredentials
                            ? l10n.currentPasswordWrong
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.gap18),
                      AppTextField(
                        label: l10n.newPasswordLabel,
                        obscure: true,
                        onChanged: cubit.nextChanged,
                      ),
                      const SizedBox(height: AppSpacing.gap18),
                      AppTextField(
                        label: l10n.confirmNewPasswordLabel,
                        obscure: true,
                        onChanged: cubit.confirmationChanged,
                      ),
                      const SizedBox(height: AppSpacing.gap18),
                      rule(cubit.hasMinLength, l10n.passwordRuleLength),
                      rule(cubit.differs, l10n.passwordRuleDifferent),
                      rule(cubit.matches, l10n.passwordRuleMatch),
                      const SizedBox(height: AppSpacing.space3),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: TextButton(
                          onPressed: () => _forgot(context),
                          style: TextButton.styleFrom(
                            foregroundColor: colors.brand700,
                            padding: EdgeInsets.zero,
                            textStyle: AppTextStyles.label,
                          ),
                          child: Text(l10n.forgotCurrentPasswordAction),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    AppSpacing.space5,
                    0,
                    AppSpacing.space5,
                    28,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      if (state.error?.isGeneral ?? false) ...<Widget>[
                        Text(
                          state.error == ValidationReason.network
                              ? l10n.errorNoConnection
                              : l10n.errorSomethingWentWrong,
                          style: AppTextStyles.caption.copyWith(
                            color: colors.danger,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.space3),
                      ],
                      AppButton(
                        label: l10n.savePasswordAction,
                        loading: state.saving,
                        onPressed: cubit.canSave && !state.saving
                            ? cubit.save
                            : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
