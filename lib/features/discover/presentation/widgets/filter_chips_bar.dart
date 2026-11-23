import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_icon.dart';

/// One chip in [FilterChipsBar]: an [active] filter shows a close icon and
/// removes itself on tap; a suggestion turns the filter on.
typedef FilterChipItem = ({String label, bool active, VoidCallback onTap});

/// Horizontal row of 36 px filter chips under the search field (artboards
/// 11 / 12): active filters first, then quick suggestions.
class FilterChipsBar extends StatelessWidget {
  const FilterChipsBar({required this.items, super.key});

  final List<FilterChipItem> items;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.space4,
        ),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.space2),
        itemBuilder: (context, i) {
          final item = items[i];
          final foreground = item.active ? colors.brand700 : colors.ink;
          return Semantics(
            button: true,
            selected: item.active,
            label: item.label,
            excludeSemantics: true,
            child: Material(
              color: item.active ? colors.brand100 : colors.surface200,
              shape: StadiumBorder(
                side: BorderSide(
                  color: item.active ? colors.brand600 : colors.surface200,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: item.onTap,
                child: Padding(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: AppSpacing.gap14,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        item.label,
                        style: AppTextStyles.label.copyWith(color: foreground),
                      ),
                      if (item.active) ...<Widget>[
                        const SizedBox(width: AppSpacing.gap6),
                        AppIcon(
                          AppIcon.close,
                          size: 14,
                          strokeWidth: 2.2,
                          color: foreground,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
