import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// "① Email — ② Code — ③ New password": done and current steps are brand
/// filled circles, later steps are outlined.
class NumberedStepper extends StatelessWidget {
  const NumberedStepper({
    required this.labels,
    required this.current,
    super.key,
  });

  final List<String> labels;

  /// 1-based current step.
  final int current;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final children = <Widget>[];
    for (var i = 0; i < labels.length; i++) {
      final active = i < current;
      if (i > 0) {
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space2),
            child: Container(width: 16, height: 1, color: colors.line),
          ),
        );
      }
      children.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active ? colors.brand600 : null,
                border: active ? null : Border.all(color: colors.line),
              ),
              child: Text(
                '${i + 1}',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: active ? colors.onBrand : colors.inkMuted,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.gap6),
            Text(
              labels[i],
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: active ? colors.brand700 : colors.inkMuted,
              ),
            ),
          ],
        ),
      );
    }
    return Semantics(
      label: '${labels[current - 1]} ($current/${labels.length})',
      excludeSemantics: true,
      child: Row(children: children),
    );
  }
}
