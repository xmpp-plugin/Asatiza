import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

/// A surface-200 placeholder block for loading states.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 12,
    this.radius = AppRadius.pill,
    this.widthFactor,
  });

  final double? width;
  final double height;
  final double radius;

  /// Fraction of the available width (e.g. 0.55 for "55%").
  final double? widthFactor;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final box = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colors.surface200,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
    if (widthFactor == null) {
      return box;
    }
    return FractionallySizedBox(
      alignment: AlignmentDirectional.centerStart,
      widthFactor: widthFactor,
      child: box,
    );
  }
}
