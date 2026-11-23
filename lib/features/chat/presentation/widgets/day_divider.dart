import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Centred grey pill between messages ("Today", "Connected 3 days ago").
class DayDivider extends StatelessWidget {
  const DayDivider(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.gap10,
          vertical: AppSpacing.gap2,
        ),
        decoration: BoxDecoration(
          color: colors.surface200,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(color: colors.inkMuted),
        ),
      ),
    );
  }
}
