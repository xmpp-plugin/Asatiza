import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/models/enums/weekday.dart';
import '../../../../l10n/app_localizations.dart';

/// Seven 42 px day circles (M T W T F S S); selected days are brand filled.
class WeekdayPicker extends StatelessWidget {
  const WeekdayPicker({
    required this.selected,
    required this.onToggle,
    super.key,
  });

  final Set<Weekday> selected;
  final ValueChanged<Weekday> onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        for (final day in Weekday.values)
          Semantics(
            button: true,
            selected: selected.contains(day),
            label: day.label(l10n),
            excludeSemantics: true,
            child: Material(
              color: selected.contains(day)
                  ? colors.brand600
                  : colors.surface000,
              shape: CircleBorder(
                side: selected.contains(day)
                    ? BorderSide.none
                    : BorderSide(color: colors.line),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => onToggle(day),
                child: SizedBox(
                  width: 42,
                  height: 42,
                  child: Center(
                    child: Text(
                      day.initial(l10n),
                      style: AppTextStyles.helperStrong.copyWith(
                        color: selected.contains(day)
                            ? colors.onBrand
                            : colors.ink,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
