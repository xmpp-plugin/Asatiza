import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import 'app_icon.dart';

/// Gold circle with a dark check: the "Verified teacher" badge.
class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key, this.size = 16});

  /// 16 next to names, 14 in comments, 18 on avatars.
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Tooltip(
      message: AppLocalizations.of(context).verifiedTeacher,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.gold500,
          shape: BoxShape.circle,
        ),
        child: AppIcon(
          AppIcon.check,
          size: size * 0.69,
          strokeWidth: 3.2,
          color: colors.onGold,
          semanticLabel: AppLocalizations.of(context).verifiedTeacher,
        ),
      ),
    );
  }
}
