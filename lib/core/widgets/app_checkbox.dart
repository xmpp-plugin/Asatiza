import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import 'app_icon.dart';

/// 22 px checkbox (6 px radius) with a label beside it; the whole row is
/// tappable. Checked = brand fill with a white check.
class AppCheckbox extends StatelessWidget {
  const AppCheckbox({
    required this.value,
    required this.onChanged,
    required this.label,
    super.key,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  /// Usually a [Text] or [Text.rich].
  final Widget label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return MergeSemantics(
      child: Semantics(
        checked: value,
        child: InkWell(
          onTap: () => onChanged(!value),
          borderRadius: BorderRadius.circular(AppRadius.checkbox),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: value ? colors.brand600 : null,
                  borderRadius: BorderRadius.circular(AppRadius.checkbox),
                  border: value
                      ? null
                      : Border.all(color: colors.inkMuted, width: 2),
                ),
                child: value
                    ? AppIcon(
                        AppIcon.check,
                        size: 15,
                        strokeWidth: 3,
                        color: colors.onBrand,
                      )
                    : null,
              ),
              const SizedBox(width: AppSpacing.gap10),
              Expanded(child: label),
            ],
          ),
        ),
      ),
    );
  }
}
