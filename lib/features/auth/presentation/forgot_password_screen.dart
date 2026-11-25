import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/failures.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/back_header.dart';
import '../../../core/widgets/numbered_stepper.dart';
import '../../../core/widgets/otp_input.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../bloc/otp_cubit.dart';
import '../bloc/otp_state.dart';
import '../bloc/password_reset_cubit.dart';
import '../bloc/password_reset_state.dart';

/// 06 / 06a Forgot password: step 1 (email) and step 2 (code). Step 3 is
/// [NewPasswordScreen].
class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PasswordResetCubit>(
      create: (context) => PasswordResetCubit(context.read<AuthRepository>()),
      child: BlocBuilder<PasswordResetCubit, PasswordResetState>(
        buildWhen: (a, b) =>
            (a.status == PasswordResetStatus.codeSent) !=
            (b.status == PasswordResetStatus.codeSent),
        builder: (context, state) =>
            state.status == PasswordResetStatus.codeSent
            ? BlocProvider<OtpCubit>(
                create: (context) => OtpCubit(
                  context.read<AuthRepository>(),
                  purpose: OtpPurpose.passwordReset,
                  email: state.email,
                ),
                child: const _CodeStep(),
              )
            : const _EmailStep(),
      ),
    );
  }
}

List<String> _steps(AppLocalizations l10n) => <String>[
  l10n.resetStepEmail,
  l10n.resetStepCode,
  l10n.resetStepNewPassword,
];

class _Frame extends StatelessWidget {
  const _Frame({required this.onBack, required this.children});

  final VoidCallback onBack;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            BackHeader(onBack: onBack),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: children,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmailStep extends StatelessWidget {
  const _EmailStep();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<PasswordResetCubit>();
    return BlocBuilder<PasswordResetCubit, PasswordResetState>(
      builder: (context, state) => _Frame(
        onBack: () =>
            context.canPop() ? context.pop() : context.go(AppRoutes.logIn),
        children: <Widget>[
          NumberedStepper(labels: _steps(l10n), current: 1),
          const SizedBox(height: AppSpacing.gap22),
          Semantics(
            header: true,
            child: Text(
              l10n.resetTitle,
              style: AppTextStyles.authTitle.copyWith(color: colors.ink),
            ),
          ),
          const SizedBox(height: AppSpacing.space2),
          Text(
            l10n.resetSubtitle,
            style: AppTextStyles.bodyMd.copyWith(color: colors.inkMuted),
          ),
          const SizedBox(height: AppSpacing.gap22),
          AppTextField(
            label: l10n.emailLabel,
            leadingIcon: AppIcon.mail,
            initialValue: state.email,
            onChanged: cubit.emailChanged,
            onSubmitted: (_) => cubit.sendCode(),
            keyboardType: TextInputType.emailAddress,
            autofillHints: const <String>[AutofillHints.email],
            errorText: state.failure == ValidationReason.invalidEmail
                ? l10n.errorInvalidEmail
                : null,
          ),
          const Spacer(),
          const SizedBox(height: AppSpacing.gap22),
          if (state.failure?.isGeneral ?? false) ...<Widget>[
            Text(
              state.failure == ValidationReason.network
                  ? l10n.errorNoConnection
                  : l10n.errorSomethingWentWrong,
              style: AppTextStyles.caption.copyWith(color: colors.danger),
            ),
            const SizedBox(height: AppSpacing.space3),
          ],
          AppButton(
            label: l10n.sendCodeAction,
            loading: state.status == PasswordResetStatus.submitting,
            onPressed:
                state.emailValid &&
                    state.status != PasswordResetStatus.submitting
                ? cubit.sendCode
                : null,
          ),
        ],
      ),
    );
  }
}

class _CodeStep extends StatelessWidget {
  const _CodeStep();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context);
    final otp = context.read<OtpCubit>();
    final reset = context.read<PasswordResetCubit>();
    return BlocConsumer<OtpCubit, OtpState>(
      listenWhen: (a, b) =>
          a.status != b.status && b.status == OtpStatus.verified,
      listener: (context, state) =>
          context.pushReplacement(AppRoutes.newPassword, extra: state.email),
      builder: (context, state) => _Frame(
        onBack: reset.editEmail,
        children: <Widget>[
          NumberedStepper(labels: _steps(l10n), current: 2),
          const SizedBox(height: AppSpacing.gap22),
          Semantics(
            header: true,
            child: Text(
              l10n.enterCodeTitle,
              style: AppTextStyles.authTitle.copyWith(color: colors.ink),
            ),
          ),
          const SizedBox(height: AppSpacing.space2),
          Text.rich(
            TextSpan(
              style: AppTextStyles.bodyMd.copyWith(color: colors.inkMuted),
              children: <InlineSpan>[
                // Never confirms that the email has an account (Supabase
                // sends no code for unknown emails but reports success).
                TextSpan(text: l10n.resetCodeSentPrefix),
                TextSpan(
                  text: state.email,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: colors.ink,
                  ),
                ),
                TextSpan(text: l10n.resetCodeSentSuffix),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.gap22),
          OtpInput(onChanged: otp.codeChanged),
          if (state.failure != null) ...<Widget>[
            const SizedBox(height: AppSpacing.space2),
            Text(switch (state.failure) {
              ValidationReason.network => l10n.errorNoConnection,
              ValidationReason.unexpected => l10n.errorSomethingWentWrong,
              _ => l10n.errorInvalidCode,
            }, style: AppTextStyles.caption.copyWith(color: colors.danger)),
          ],
          const SizedBox(height: AppSpacing.gap22),
          _ResendRow(
            state: state,
            onResend: otp.resend,
            onChangeEmail: reset.editEmail,
          ),
          const Spacer(),
          const SizedBox(height: AppSpacing.gap22),
          AppButton(
            label: l10n.continueAction,
            loading: state.status == OtpStatus.verifying,
            onPressed: state.isComplete && state.status == OtpStatus.entering
                ? otp.verify
                : null,
          ),
        ],
      ),
    );
  }
}

/// "Resend code in 0:38" (or a link) and "Wrong email? Change it".
class _ResendRow extends StatelessWidget {
  const _ResendRow({
    required this.state,
    required this.onResend,
    required this.onChangeEmail,
  });

  final OtpState state;
  final VoidCallback onResend;
  final VoidCallback onChangeEmail;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context);
    final seconds = state.secondsLeft;
    final clock =
        '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
    final link = AppTextStyles.label.copyWith(color: colors.brand700);
    return Row(
      children: <Widget>[
        Expanded(
          child: state.canResend
              ? Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: GestureDetector(
                    onTap: onResend,
                    child: Text(l10n.resendCodeAction, style: link),
                  ),
                )
              : Text.rich(
                  TextSpan(
                    style: AppTextStyles.body.copyWith(color: colors.inkMuted),
                    children: <InlineSpan>[
                      TextSpan(text: l10n.resendCodeIn),
                      TextSpan(
                        text: clock,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: colors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
        GestureDetector(
          onTap: onChangeEmail,
          child: Text(l10n.wrongEmailAction, style: link),
        ),
      ],
    );
  }
}
