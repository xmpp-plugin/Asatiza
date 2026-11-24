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
import '../../../core/widgets/numbered_stepper.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../bloc/password_reset_cubit.dart';
import '../bloc/password_reset_state.dart';

/// 06b New password (step 3 of 3): two fields, live rule checks, then
/// "Save and log in".
class NewPasswordScreen extends StatelessWidget {
  const NewPasswordScreen({required this.email, super.key});

  final String email;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PasswordResetCubit>(
      create: (context) =>
          PasswordResetCubit(context.read<AuthRepository>(), email: email),
      child: const _NewPasswordView(),
    );
  }
}

class _NewPasswordView extends StatelessWidget {
  const _NewPasswordView();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<PasswordResetCubit>();

    Widget rule(String text, bool met) => Row(
      children: <Widget>[
        AppIcon(
          AppIcon.check,
          size: 16,
          strokeWidth: 2.4,
          color: met ? colors.brand700 : colors.inkMuted,
        ),
        const SizedBox(width: AppSpacing.space2),
        Text(
          text,
          style: AppTextStyles.helper.copyWith(
            color: met ? colors.brand700 : colors.inkMuted,
          ),
        ),
      ],
    );

    return BlocListener<PasswordResetCubit, PasswordResetState>(
      listenWhen: (a, b) =>
          a.status != b.status && b.status == PasswordResetStatus.passwordSaved,
      listener: (context, state) =>
          context.read<SessionCubit>().signedIn(state.user!),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: <Widget>[
              BackHeader(
                onBack: () => context.canPop()
                    ? context.pop()
                    : context.go(AppRoutes.forgotPassword),
              ),
              Expanded(
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          AppSpacing.space5,
                          AppSpacing.space1,
                          AppSpacing.space5,
                          28,
                        ),
                        child:
                            BlocBuilder<PasswordResetCubit, PasswordResetState>(
                              builder: (context, state) => Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  NumberedStepper(
                                    labels: <String>[
                                      l10n.resetStepEmail,
                                      l10n.resetStepCode,
                                      l10n.resetStepNewPassword,
                                    ],
                                    current: 3,
                                  ),
                                  const SizedBox(height: AppSpacing.space5),
                                  Semantics(
                                    header: true,
                                    child: Text(
                                      l10n.newPasswordTitle,
                                      style: AppTextStyles.authTitle.copyWith(
                                        color: colors.ink,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.space2),
                                  Text(
                                    l10n.newPasswordSubtitle,
                                    style: AppTextStyles.bodyMd.copyWith(
                                      color: colors.inkMuted,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.space5),
                                  AppTextField(
                                    label: l10n.newPasswordLabel,
                                    obscure: true,
                                    onChanged: cubit.passwordChanged,
                                    textInputAction: TextInputAction.next,
                                    autofillHints: const <String>[
                                      AutofillHints.newPassword,
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.space5),
                                  AppTextField(
                                    label: l10n.confirmPasswordLabel,
                                    obscure: true,
                                    onChanged: cubit.confirmationChanged,
                                    onSubmitted: (_) => cubit.savePassword(),
                                    autofillHints: const <String>[
                                      AutofillHints.newPassword,
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.space5),
                                  rule(
                                    l10n.passwordRuleLength,
                                    state.passwordLongEnough,
                                  ),
                                  const SizedBox(height: AppSpacing.gap6),
                                  rule(
                                    l10n.passwordRuleMatch,
                                    state.passwordsMatch,
                                  ),
                                  const Spacer(),
                                  const SizedBox(height: AppSpacing.space5),
                                  if (state.failure?.isGeneral ??
                                      false) ...<Widget>[
                                    Text(
                                      state.failure == ValidationReason.network
                                          ? l10n.errorNoConnection
                                          : l10n.errorSomethingWentWrong,
                                      style: AppTextStyles.caption.copyWith(
                                        color: colors.danger,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.space3),
                                  ],
                                  AppButton(
                                    label: l10n.saveAndLogInAction,
                                    loading:
                                        state.status ==
                                        PasswordResetStatus.submitting,
                                    onPressed: state.canSave
                                        ? cubit.savePassword
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
