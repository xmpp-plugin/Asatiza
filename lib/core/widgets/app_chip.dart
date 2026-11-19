import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_icon.dart';

/// 36 px selectable pill: surface-200 when off; brand-100 fill, brand
/// outline and a check icon when on.
class AppChip extends StatelessWidget {
  const AppChip({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final foreground = selected ? colors.brand700 : colors.ink;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: selected ? colors.brand100 : colors.surface200,
        shape: StadiumBorder(
          side: BorderSide(
            color: selected ? colors.brand600 : colors.surface200,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: 36,
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: AppSpacing.gap14,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (selected) ...<Widget>[
                  AppIcon(
                    AppIcon.check,
                    size: 16,
                    strokeWidth: 2.4,
                    color: foreground,
                  ),
                  const SizedBox(width: AppSpacing.gap6),
                ],
                Text(
                  label,
                  style: AppTextStyles.label.copyWith(color: foreground),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
