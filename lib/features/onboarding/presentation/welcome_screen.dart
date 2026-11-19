import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../l10n/app_localizations.dart';
import '../bloc/welcome_cubit.dart';
import '../bloc/welcome_state.dart';
import 'widgets/page_dots.dart';
import 'widgets/welcome_slide.dart';

/// 02 / 02b / 02c Welcome: three swipeable slides, Skip, and the two
/// account buttons.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<WelcomeCubit>(
      create: (_) => WelcomeCubit(),
      child: const _WelcomeView(),
    );
  }
}

class _WelcomeView extends StatelessWidget {
  const _WelcomeView();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context);
    final content = <(String, String, String)>[
      (
        'assets/illustrations/welcome_hero_1.svg',
        l10n.welcomeTitle1,
        l10n.welcomeMessage1,
      ),
      (
        'assets/illustrations/welcome_hero_2.svg',
        l10n.welcomeTitle2,
        l10n.welcomeMessage2,
      ),
      (
        'assets/illustrations/welcome_hero_3.svg',
        l10n.welcomeTitle3,
        l10n.welcomeMessage3,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(
              height: 56,
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(
                    end: AppSpacing.space3,
                  ),
                  child: TextButton(
                    onPressed: () => context.go(AppRoutes.signUp),
                    style: TextButton.styleFrom(
                      foregroundColor: colors.brand700,
                      textStyle: AppTextStyles.label,
                    ),
                    child: Text(l10n.skipAction),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                itemCount: WelcomeState.pageCount,
                onPageChanged: context.read<WelcomeCubit>().pageChanged,
                itemBuilder: (context, i) => SingleChildScrollView(
                  child: WelcomeSlide(
                    illustration: content[i].$1,
                    title: content[i].$2,
                    message: content[i].$3,
                    indicator: PageDots(
                      count: WelcomeState.pageCount,
                      current: i,
                      label: l10n.slideOf(i + 1, WelcomeState.pageCount),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                AppSpacing.space6,
                AppSpacing.space3,
                AppSpacing.space6,
                AppSpacing.space8,
              ),
              child: Column(
                children: <Widget>[
                  AppButton(
                    label: l10n.createAccountAction,
                    onPressed: () => context.go(AppRoutes.signUp),
                  ),
                  const SizedBox(height: AppSpacing.space3),
                  AppButton(
                    label: l10n.haveAccountAction,
                    variant: AppButtonVariant.secondary,
                    onPressed: () => context.go(AppRoutes.logIn),
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
