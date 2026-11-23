import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import 'skeleton_box.dart';

/// Loading placeholder for a teacher / student card (artboard 24).
class TeacherCardSkeleton extends StatelessWidget {
  const TeacherCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    return ExcludeSemantics(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.gap14),
        decoration: BoxDecoration(
          color: colors.surface000,
          border: Border.all(color: colors.line),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.card(theme.brightness),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SkeletonBox(width: 52, height: 52),
                SizedBox(width: AppSpacing.space3),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: AppSpacing.space1),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SkeletonBox(widthFactor: 0.6, height: 14),
                        SizedBox(height: AppSpacing.space2),
                        SkeletonBox(widthFactor: 0.8, height: 10),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.gap14),
            Row(
              children: <Widget>[
                SkeletonBox(width: 64, height: 24, radius: AppRadius.sm),
                SizedBox(width: AppSpacing.gap6),
                SkeletonBox(width: 52, height: 24, radius: AppRadius.sm),
                SizedBox(width: AppSpacing.gap6),
                SkeletonBox(width: 90, height: 24, radius: AppRadius.sm),
              ],
            ),
            SizedBox(height: AppSpacing.gap14),
            Row(
              children: <Widget>[
                Expanded(child: SkeletonBox(height: 36)),
                SizedBox(width: AppSpacing.space2),
                Expanded(child: SkeletonBox(height: 36)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
