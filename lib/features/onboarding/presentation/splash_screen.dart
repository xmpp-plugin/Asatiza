import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';

/// 01 Splash: brand green, logo, "Asatiza" wordmark and the tagline. After
/// a short pause it continues to Home (the router sends signed-out users
/// to Welcome).
/// 
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const Duration delay = Duration(milliseconds: 1200);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(SplashScreen.delay, () {
      if (mounted) {
        context.go(AppRoutes.home);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: colors.brand600,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SvgPicture.asset(
                      'assets/images/logo_splash.svg',
                      width: 132,
                      height: 143,
                      semanticsLabel: l10n.logoLabel,
                    ),
                    const SizedBox(height: AppSpacing.space5),
                    Text(
                      l10n.appTitle,
                      style: AppTextStyles.splashWordmark.copyWith(
                        color: colors.onBrand,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 56),
                child: Text(
                  l10n.splashTagline,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMd.copyWith(color: colors.brand100),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
