import 'package:flutter/material.dart';

import '../../data/models/enums/post_tag.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// 24 px post tag label: brand tint, or gold tint for achievements and
/// class announcements.
class TagChip extends StatelessWidget {
  const TagChip({required this.tag, super.key});

  final PostTag tag;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final gold = tag.isGold;
    return Container(
      height: 24,
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.space2,
      ),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: gold ? colors.gold100 : colors.brand100,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        tag.label(AppLocalizations.of(context)),
        style: AppTextStyles.caption.copyWith(
          fontWeight: FontWeight.w600,
          color: gold ? colors.gold700 : colors.brand700,
        ),
      ),
    );
  }
}
