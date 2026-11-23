import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/failures.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_checkbox.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/back_header.dart';
import '../../../data/models/enums/user_role.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../bloc/sign_up_cubit.dart';
import '../bloc/sign_up_state.dart';
import 'widgets/role_card.dart';

/// 03 Sign up: role, name, email, password and the 18+ / Terms consent.
class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SignUpCubit>(
      create: (context) => SignUpCubit(context.read<AuthRepository>()),
      child: const _SignUpView(),
    );
  }
}

class _SignUpView extends StatelessWidget {
  const _SignUpView();

  String? _error(
    ValidationReason? reason,
    AppLocalizations l10n,
    Set<ValidationReason> mine,
  ) {
    if (reason == null || !mine.contains(reason)) {
      return null;
    }
    return switch (reason) {
      ValidationReason.invalidEmail => l10n.errorInvalidEmail,
      ValidationReason.emailAlreadyRegistered => l10n.errorEmailRegistered,
      ValidationReason.passwordTooShort => l10n.passwordRuleLength,
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<SignUpCubit>();

    return BlocListener<SignUpCubit, SignUpState>(
      listenWhen: (a, b) =>
          a.status != b.status && b.status == SignUpStatus.codeSent,
      listener: (context, state) =>
          context.push(AppRoutes.signUpCode, extra: state.email),
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
                        child: BlocBuilder<SignUpCubit, SignUpState>(
                          builder: (context, state) => Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Semantics(
                                header: true,
                                child: Text(
                                  l10n.signUpTitle,
                                  style: AppTextStyles.authTitle.copyWith(
                                    color: colors.ink,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.space2),
                              Text(
                                l10n.signUpSubtitle,
                                style: AppTextStyles.bodyMd.copyWith(
                                  color: colors.inkMuted,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.gap18),
                              Text(
                                l10n.iAmA,
                                style: AppTextStyles.label.copyWith(
                                  color: colors.ink,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.space2),
                              IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    Expanded(
                                      child: RoleCard(
                                        icon: AppIcon.graduationCap,
                                        title: l10n.roleStudent,
                                        subtitle: l10n.roleStudentDescription,
                                        selected:
                                            state.role == UserRole.student,
                                        onTap: () =>
                                            cubit.roleChanged(UserRole.student),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.space3),
                                    Expanded(
                                      child: RoleCard(
                                        icon: AppIcon.bookOpen,
                                        title: l10n.roleTeacher,
                                        subtitle: l10n.roleTeacherDescription,
                                        selected:
                                            state.role == UserRole.teacher,
                                        onTap: () =>
                                            cubit.roleChanged(UserRole.teacher),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppSpacing.gap18),
                              AppTextField(
                                label: l10n.fullNameLabel,
                                onChanged: cubit.nameChanged,
                                textInputAction: TextInputAction.next,
                                autofillHints: const <String>[
                                  AutofillHints.name,
                                ],
                              ),
                              const SizedBox(height: AppSpacing.gap18),
                              AppTextField(
                                label: l10n.emailLabel,
                                onChanged: cubit.emailChanged,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                autofillHints: const <String>[
                                  AutofillHints.email,
                                ],
                                errorText: _error(state.failure, l10n, const {
                                  ValidationReason.invalidEmail,
                                  ValidationReason.emailAlreadyRegistered,
                                }),
                              ),
                              const SizedBox(height: AppSpacing.gap18),
                              AppTextField(
                                label: l10n.passwordLabel,
                                obscure: true,
                                onChanged: cubit.passwordChanged,
                                autofillHints: const <String>[
                                  AutofillHints.newPassword,
                                ],
                                helper: l10n.passwordRuleLength,
                                errorText: _error(state.failure, l10n, const {
                                  ValidationReason.passwordTooShort,
                                }),
                              ),
                              const SizedBox(height: AppSpacing.gap18),
                              AppCheckbox(
                                value: state.consent,
                                onChanged: cubit.consentChanged,
                                label: Text.rich(
                                  TextSpan(
                                    style: AppTextStyles.body.copyWith(
                                      color: colors.ink,
                                    ),
                                    children: <InlineSpan>[
                                      TextSpan(text: l10n.consentPrefix),
                                      WidgetSpan(
                                        alignment:
                                            PlaceholderAlignment.baseline,
                                        baseline: TextBaseline.alphabetic,
                                        child: GestureDetector(
                                          onTap: () => context.push(
                                            AppRoutes.policy('terms'),
                                          ),
                                          child: Text(
                                            l10n.termsLink,
                                            style: AppTextStyles.body.copyWith(
                                              color: colors.brand700,
                                            ),
                                          ),
                                        ),
                                      ),
                                      TextSpan(text: l10n.consentAnd),
                                      WidgetSpan(
                                        alignment:
                                            PlaceholderAlignment.baseline,
                                        baseline: TextBaseline.alphabetic,
                                        child: GestureDetector(
                                          onTap: () => context.push(
                                            AppRoutes.policy('privacy'),
                                          ),
                                          child: Text(
                                            l10n.privacyLink,
                                            style: AppTextStyles.body.copyWith(
                                              color: colors.brand700,
                                            ),
                                          ),
                                        ),
                                      ),
                                      TextSpan(text: l10n.consentSuffix),
                                    ],
                                  ),
                                ),
                              ),
                              const Spacer(),
                              const SizedBox(height: AppSpacing.gap18),
                              AppButton(
                                label: l10n.createAccountAction,
                                onPressed: state.canSubmit
                                    ? cubit.submit
                                    : null,
                              ),
                              const SizedBox(height: AppSpacing.space3),
                              Center(
                                child: Text.rich(
                                  TextSpan(
                                    style: AppTextStyles.body.copyWith(
                                      color: colors.inkMuted,
                                    ),
                                    children: <InlineSpan>[
                                      TextSpan(text: l10n.haveAccountQuestion),
                                      WidgetSpan(
                                        alignment: PlaceholderAlignment.middle,
                                        child: GestureDetector(
                                          onTap: () =>
                                              context.go(AppRoutes.logIn),
                                          child: Text(
                                            l10n.logInAction,
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
