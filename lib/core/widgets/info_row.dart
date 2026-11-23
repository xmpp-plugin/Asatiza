import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_icon.dart';

/// Detail line from the profile cards: 20 px muted icon, 14 px text and an
/// optional bold gold value at the end (e.g. "Fee … $40 / month").
class InfoRow extends StatelessWidget {
  const InfoRow({
    required this.icon,
    required this.text,
    super.key,
    this.value,
  });

  final String icon;
  final String text;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return MergeSemantics(
      child: Row(
        children: <Widget>[
          AppIcon(icon, size: 20, color: colors.inkMuted),
          const SizedBox(width: AppSpacing.gap10),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body.copyWith(color: colors.ink),
            ),
          ),
          if (value != null)
            Text(
              value!,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.gold700,
              ),
            ),
        ],
      ),
    );
  }
}
