import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_text_styles.dart';

/// Small count bubble with a 2 px ring in the surface behind it.
///
/// [gold] is the 20 px filter-count badge (gold fill); otherwise it is the
/// 18 px red unread badge on the bottom bar. Counts over 99 show "99+".
class CountBadge extends StatelessWidget {
  const CountBadge({
    required this.count,
    required this.ringColor,
    super.key,
    this.gold = false,
  });

  final int count;
  final Color ringColor;
  final bool gold;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final size = gold ? 20.0 : 18.0;
    return Container(
      constraints: BoxConstraints(minWidth: size),
      height: size,
      padding: EdgeInsets.symmetric(horizontal: gold ? 0 : 5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: gold ? colors.gold500 : colors.danger,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: <BoxShadow>[BoxShadow(color: ringColor, spreadRadius: 2)],
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: AppTextStyles.micro.copyWith(
          height: 1,
          color: gold ? colors.onGold : colors.onDanger,
        ),
      ),
    );
  }
}
