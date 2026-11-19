import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// One Welcome slide: 330 px illustration card (24 px radius), then the
/// Fraunces title and the supporting line.
class WelcomeSlide extends StatelessWidget {
  const WelcomeSlide({
    required this.illustration,
    required this.title,
    required this.message,
    required this.indicator,
    super.key,
  });

  /// Asset path of the slide illustration.
  final String illustration;
  final String title;
  final String message;

  /// Slide dots shown 8 px under the message, as on the artboards.
  final Widget indicator;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            AppSpacing.space6,
            AppSpacing.space2,
            AppSpacing.space6,
            0,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            child: Container(
              height: 330,
              color: colors.brand600,
              child: ExcludeSemantics(
                child: SvgPicture.asset(illustration, fit: BoxFit.cover),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            AppSpacing.space6,
            28,
            AppSpacing.space6,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Semantics(
                header: true,
                child: Text(
                  title,
                  style: AppTextStyles.displayLg.copyWith(color: colors.ink),
                ),
              ),
              const SizedBox(height: AppSpacing.space3),
              Text(
                message,
                style: AppTextStyles.bodyLg.copyWith(color: colors.inkMuted),
              ),
              const SizedBox(height: AppSpacing.space3 + AppSpacing.space2),
              indicator,
            ],
          ),
        ),
      ],
    );
  }
}
