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
import '../../../core/widgets/app_info_note.dart';
import '../../../core/widgets/back_header.dart';
import '../../../core/widgets/otp_input.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../bloc/otp_cubit.dart';
import '../bloc/otp_state.dart';

/// 04 Email code after sign-up: 6 boxes (auto-verify), resend timer,
/// "Wrong email? Change it" and the spam-folder note.
class EmailCodeScreen extends StatelessWidget {
  const EmailCodeScreen({required this.email, super.key});

  final String email;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OtpCubit>(
      create: (context) => OtpCubit(
        context.read<AuthRepository>(),
        purpose: OtpPurpose.signUp,
        email: email,
      ),
      child: const _EmailCodeView(),
    );
  }
}

class _EmailCodeView extends StatelessWidget {
  const _EmailCodeView();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<OtpCubit>();

    return BlocListener<OtpCubit, OtpState>(
      listenWhen: (a, b) =>
          a.status != b.status && b.status == OtpStatus.verified,
      listener: (context, state) {
        final user = state.user;
        if (user != null) {
          // The router opens profile setup for the new account.
          context.read<SessionCubit>().signedIn(user);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: <Widget>[
              BackHeader(
                onBack: () => context.canPop()
                    ? context.pop()
                    : context.go(AppRoutes.signUp),
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
                        child: BlocBuilder<OtpCubit, OtpState>(
                          builder: (context, state) => Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: Container(
                                  width: 64,
                                  height: 64,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: colors.brand100,
                                    shape: BoxShape.circle,
                                  ),
                                  child: AppIcon(
                                    AppIcon.mail,
                                    size: 30,
                                    color: colors.brand700,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.space5),
                              Semantics(
                                header: true,
                                child: Text(
                                  l10n.checkEmailTitle,
                                  style: AppTextStyles.authTitle.copyWith(
                                    color: colors.ink,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.space2),
                              Text.rich(
                                TextSpan(
                                  style: AppTextStyles.bodyMd.copyWith(
                                    color: colors.inkMuted,
                                  ),
                                  children: <InlineSpan>[
                                    TextSpan(text: l10n.codeSentPrefix),
                                    TextSpan(
                                      text: state.email,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: colors.ink,
                                      ),
                                    ),
                                    TextSpan(text: l10n.codeSentSuffix),
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppSpacing.space5),
                              OtpInput(onChanged: cubit.codeChanged),
                              if (state.failure != null) ...<Widget>[
                                const SizedBox(height: AppSpacing.space2),
                                Text(
                                  switch (state.failure) {
                                    ValidationReason.network =>
                                      l10n.errorNoConnection,
                                    ValidationReason.unexpected =>
                                      l10n.errorSomethingWentWrong,
                                    _ => l10n.errorInvalidCode,
                                  },
                                  style: AppTextStyles.caption.copyWith(
                                    color: colors.danger,
                                  ),
                                ),
                              ],
                              const SizedBox(height: AppSpacing.space5),
                              _ResendRow(
                                state: state,
                                onResend: cubit.resend,
                                onChangeEmail: () => context.canPop()
                                    ? context.pop()
                                    : context.go(AppRoutes.signUp),
                              ),
                              const SizedBox(height: AppSpacing.space5),
                              AppInfoNote(text: l10n.spamFolderNote),
                              const Spacer(),
                              const SizedBox(height: AppSpacing.space5),
                              AppButton(
                                label: l10n.verifyAction,
                                loading: state.status == OtpStatus.verifying,
                                onPressed:
                                    state.isComplete &&
                                        state.status == OtpStatus.entering
                                    ? cubit.verify
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

/// "Resend code in 0:42" (or a "Resend code" link) and "Wrong email?".
/// Shared by the sign-up and password-reset code steps.
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
