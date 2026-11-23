import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_icon.dart';

/// Quiet surface-200 note with an 18 px icon, e.g. "Can’t find it? Check
/// your Spam folder…" on the email-code screen.
class AppInfoNote extends StatelessWidget {
  const AppInfoNote({required this.text, super.key, this.icon = AppIcon.info});

  final String text;
  final String icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.gap14,
        vertical: AppSpacing.space3,
      ),
      decoration: BoxDecoration(
        color: colors.surface200,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AppIcon(icon, size: 18, color: colors.inkMuted),
          const SizedBox(width: AppSpacing.gap10),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.helper.copyWith(color: colors.inkMuted),
            ),
          ),
        ],
      ),
    );
  }
}
