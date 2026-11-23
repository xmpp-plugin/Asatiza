import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Segmented control from the artboards: surface-200 track (12 px radius,
/// 4 px padding); the selected segment is white with a brand label.
class AppSegmentedControl<T> extends StatelessWidget {
  const AppSegmentedControl({
    required this.values,
    required this.selected,
    required this.label,
    required this.onChanged,
    super.key,
  });

  final List<T> values;
  final T? selected;
  final String Function(T value) label;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space1),
      decoration: BoxDecoration(
        color: colors.surface200,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: <Widget>[
          for (final value in values) ...<Widget>[
            if (value != values.first) const SizedBox(width: AppSpacing.space1),
            Expanded(
              child: Semantics(
                button: true,
                selected: value == selected,
                child: GestureDetector(
                  onTap: () => onChanged(value),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: value == selected ? colors.surface000 : null,
                      borderRadius: BorderRadius.circular(AppRadius.segment),
                      boxShadow: value == selected
                          ? <BoxShadow>[
                              BoxShadow(
                                color: colors.ink.withValues(alpha: 0.12),
                                offset: const Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      label(value),
                      style: AppTextStyles.label.copyWith(
                        color: value == selected
                            ? colors.brand700
                            : colors.inkMuted,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
