import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
import '../../../data/repositories/auth_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../bloc/login_cubit.dart';
import '../bloc/login_state.dart';

/// 05 Log in: email + password only (no code at log-in).
class LogInScreen extends StatelessWidget {
  const LogInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginCubit>(
      create: (context) => LoginCubit(context.read<AuthRepository>()),
      child: const _LogInView(),
    );
  }
}

class _LogInView extends StatelessWidget {
  const _LogInView();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<LoginCubit>();

    return BlocListener<LoginCubit, LoginState>(
      listenWhen: (a, b) =>
          a.status != b.status &&
          (b.status == LoginStatus.signedIn ||
              b.status == LoginStatus.needsCode),
      listener: (context, state) {
        if (state.status == LoginStatus.needsCode) {
          context.push(AppRoutes.signUpCode, extra: state.email);
        } else {
          context.read<SessionCubit>().signedIn(state.user!);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: <Widget>[
              BackHeader(onBack: () => context.go(AppRoutes.welcome)),
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
                        child: BlocBuilder<LoginCubit, LoginState>(
                          builder: (context, state) => Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: SvgPicture.asset(
                                  'assets/images/logo_mark.svg',
                                  width: 56,
                                  height: 61,
                                  excludeFromSemantics: true,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.space5),
                              Semantics(
                                header: true,
                                child: Text(
                                  l10n.logInTitle,
                                  style: AppTextStyles.authTitle.copyWith(
                                    color: colors.ink,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.space2),
                              Text(
                                l10n.logInSubtitle,
                                style: AppTextStyles.bodyMd.copyWith(
                                  color: colors.inkMuted,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.space5),
                              AppTextField(
                                label: l10n.emailLabel,
                                leadingIcon: AppIcon.mail,
                                onChanged: cubit.emailChanged,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                autofillHints: const <String>[
                                  AutofillHints.email,
                                ],
                                errorText:
                                    state.failure ==
                                        ValidationReason.invalidEmail
                                    ? l10n.errorInvalidEmail
                                    : null,
                              ),
                              const SizedBox(height: AppSpacing.space5),
                              AppTextField(
                                label: l10n.passwordLabel,
                                leadingIcon: AppIcon.lock,
                                obscure: true,
                                onChanged: cubit.passwordChanged,
                                onSubmitted: (_) => cubit.submit(),
                                autofillHints: const <String>[
                                  AutofillHints.password,
                                ],
                                errorText: switch (state.failure) {
                                  ValidationReason.passwordTooShort =>
                                    l10n.passwordRuleLength,
                                  ValidationReason.wrongCredentials =>
                                    l10n.errorWrongCredentials,
                                  _ => null,
                                },
                              ),
                              const SizedBox(height: AppSpacing.space3),
                              Align(
                                alignment: AlignmentDirectional.centerEnd,
                                child: GestureDetector(
                                  onTap: () =>
                                      context.push(AppRoutes.forgotPassword),
                                  child: Text(
                                    l10n.forgotPasswordAction,
                                    style: AppTextStyles.label.copyWith(
                                      color: colors.brand700,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.space5),
                              AppButton(
                                label: l10n.logInAction,
                                onPressed: state.canSubmit
                                    ? cubit.submit
                                    : null,
                              ),
                              const Spacer(),
                              const SizedBox(height: AppSpacing.space5),
                              Center(
                                child: Text.rich(
                                  TextSpan(
                                    style: AppTextStyles.body.copyWith(
                                      color: colors.inkMuted,
                                    ),
                                    children: <InlineSpan>[
                                      TextSpan(text: l10n.newToAsatiza),
                                      WidgetSpan(
                                        alignment: PlaceholderAlignment.middle,
                                        child: GestureDetector(
                                          onTap: () =>
                                              context.go(AppRoutes.signUp),
                                          child: Text(
                                            l10n.createAccountAction,
                                            style: AppTextStyles.label.copyWith(
                                              color: colors.brand700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
