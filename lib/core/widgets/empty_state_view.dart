import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_button.dart';
import 'app_icon.dart';

/// Empty state: icon in a 52 px brand-100 circle, title, one line of text
/// and an optional small action button (artboard "23 Empty states").
class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    required this.icon,
    required this.title,
    required this.message,
    super.key,
    this.actionLabel,
    this.onAction,
  });

  final String icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 52,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.brand100,
            shape: BoxShape.circle,
          ),
          child: AppIcon(icon, color: colors.brand700),
        ),
        const SizedBox(height: AppSpacing.gap10),
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTextStyles.sectionTitle.copyWith(color: colors.ink),
        ),
        const SizedBox(height: AppSpacing.gap6),
        Text(
          message,
          textAlign: TextAlign.center,
          style: AppTextStyles.helper.copyWith(color: colors.inkMuted),
        ),
        if (actionLabel != null && onAction != null) ...<Widget>[
          const SizedBox(height: AppSpacing.gap10),
          AppButton(
            label: actionLabel!,
            onPressed: onAction,
            size: AppButtonSize.small,
            expand: false,
          ),
        ],
      ],
    );
  }
}
