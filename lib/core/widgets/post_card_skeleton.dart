import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import 'skeleton_box.dart';

/// Loading version of a post card (artboard "24 Loading states").
class PostCardSkeleton extends StatelessWidget {
  const PostCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    return Semantics(
      label: AppLocalizations.of(context).loadingLabel,
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.space4),
        decoration: BoxDecoration(
          color: colors.surface000,
          border: Border.all(color: colors.line),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.card(theme.brightness),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                SkeletonBox(width: 44, height: 44),
                SizedBox(width: AppSpacing.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SkeletonBox(widthFactor: 0.55),
                      SizedBox(height: AppSpacing.space2),
                      SkeletonBox(widthFactor: 0.35, height: 10),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.space4),
            SkeletonBox(widthFactor: 1),
            SizedBox(height: AppSpacing.space2),
            SkeletonBox(widthFactor: 0.92),
            SizedBox(height: AppSpacing.space2),
            SkeletonBox(widthFactor: 0.7),
            SizedBox(height: AppSpacing.space4),
            SkeletonBox(height: 120, radius: AppRadius.md),
            SizedBox(height: AppSpacing.gap14),
            Row(
              children: <Widget>[
                Expanded(child: SkeletonBox(height: 28, radius: AppRadius.sm)),
                SizedBox(width: AppSpacing.space3),
                Expanded(child: SkeletonBox(height: 28, radius: AppRadius.sm)),
                SizedBox(width: AppSpacing.space3),
                Expanded(child: SkeletonBox(height: 28, radius: AppRadius.sm)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
