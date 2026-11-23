import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'skeleton_box.dart';

/// Loading placeholder for a chat row (artboard 24).
class ChatRowSkeleton extends StatelessWidget {
  const ChatRowSkeleton({super.key, this.previewFactor = 0.85});

  /// Width of the preview line, as a fraction of the text column.
  final double previewFactor;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return ExcludeSemantics(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space4,
          vertical: AppSpacing.space3,
        ),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: colors.line)),
        ),
        child: Row(
          children: <Widget>[
            const SkeletonBox(width: 52, height: 52),
            const SizedBox(width: AppSpacing.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SkeletonBox(widthFactor: 0.5),
                  const SizedBox(height: AppSpacing.space2),
                  SkeletonBox(widthFactor: previewFactor, height: 10),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.space3),
            const SkeletonBox(width: 36, height: 10),
          ],
        ),
      ),
    );
  }
}
