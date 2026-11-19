import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

/// Slide indicator: the current slide is a 24×8 brand pill, others are
/// 8×8 line-coloured dots.
class PageDots extends StatelessWidget {
  const PageDots({
    required this.count,
    required this.current,
    required this.label,
    super.key,
  });

  final int count;
  final int current;

  /// Accessibility label, e.g. "Slide 1 of 3".
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: Row(
        children: <Widget>[
          for (var i = 0; i < count; i++) ...<Widget>[
            if (i > 0) const SizedBox(width: AppSpacing.gap6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: i == current ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: i == current ? colors.brand600 : colors.line,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
