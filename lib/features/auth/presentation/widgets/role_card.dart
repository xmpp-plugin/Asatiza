import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_icon.dart';

/// Sign-up role card ("I am a Student / Teacher"): icon, title, one line.
class RoleCard extends StatelessWidget {
  const RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? colors.brand100 : colors.surface000,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.optionCard),
          side: BorderSide(
            color: selected ? colors.brand600 : colors.line,
            width: selected ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(
              selected ? AppSpacing.gap14 - 1 : AppSpacing.gap14,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AppIcon(
                  icon,
                  size: 26,
                  color: selected ? colors.brand700 : colors.inkMuted,
                ),
                const SizedBox(height: AppSpacing.space2),
                Text(
                  title,
                  style: AppTextStyles.bodyLg.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.ink,
                  ),
                ),
                const SizedBox(height: AppSpacing.space2),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w400,
                    color: colors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
