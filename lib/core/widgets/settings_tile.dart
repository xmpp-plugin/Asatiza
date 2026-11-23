import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_icon.dart';

/// Settings row (artboard 21): 22 px icon, 15 px label, optional muted
/// [value] below, and a chevron when it opens a screen. [danger] tints the
/// row red (Delete account). The 1 px divider sits under every row.
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
    this.value,
    this.chevron = true,
    this.danger = false,
  });

  final String icon;
  final String label;
  final String? value;
  final VoidCallback? onTap;
  final bool chevron;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final foreground = danger ? colors.danger : colors.ink;
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 52),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space4,
          vertical: AppSpacing.gap6,
        ),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: colors.line)),
        ),
        child: Row(
          children: <Widget>[
            AppIcon(
              icon,
              size: 22,
              color: danger ? colors.danger : colors.inkMuted,
            ),
            const SizedBox(width: AppSpacing.gap14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    label,
                    style: AppTextStyles.bodyMd.copyWith(
                      fontWeight: FontWeight.w500,
                      color: foreground,
                    ),
                  ),
                  if (value != null)
                    Text(
                      value!,
                      style: AppTextStyles.helper.copyWith(
                        color: colors.inkMuted,
                      ),
                    ),
                ],
              ),
            ),
            if (chevron && onTap != null)
              AppIcon(AppIcon.chevronRight, size: 20, color: colors.inkMuted),
          ],
        ),
      ),
    );
  }
}
