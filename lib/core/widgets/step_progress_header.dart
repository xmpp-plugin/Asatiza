import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_icon.dart';

/// Profile-setup header: optional back button, "Step n of total" centred,
/// and one 6 px bar per step below. There is no Skip: setup is required.
class StepProgressHeader extends StatelessWidget {
  const StepProgressHeader({
    required this.step,
    required this.total,
    super.key,
    this.onBack,
  });

  /// 1-based current step.
  final int step;
  final int total;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.space4,
        AppSpacing.space2,
        AppSpacing.space4,
        0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            height: 44,
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 34,
                  child: onBack == null
                      ? null
                      : OverflowBox(
                          maxWidth: 44,
                          alignment: AlignmentDirectional.centerStart,
                          child: Transform.translate(
                            offset: Offset(
                              Directionality.of(context) == TextDirection.rtl
                                  ? 10
                                  : -10,
                              0,
                            ),
                            child: IconButton(
                              onPressed: onBack,
                              tooltip: l10n.backAction,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints.tightFor(
                                width: 44,
                                height: 44,
                              ),
                              icon: AppIcon(
                                AppIcon.chevronLeft,
                                color: colors.ink,
                              ),
                            ),
                          ),
                        ),
                ),
                Expanded(
                  child: Text(
                    l10n.setupStepOf(step, total),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.helperStrong.copyWith(
                      color: colors.inkMuted,
                    ),
                  ),
                ),
                // Keeps the step text centred (no Skip: setup is required).
                const SizedBox(width: 34),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.gap10),
          Row(
            children: <Widget>[
              for (var i = 1; i <= total; i++) ...<Widget>[
                if (i > 1) const SizedBox(width: AppSpacing.gap6),
                Expanded(
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: i <= step ? colors.brand600 : colors.surface200,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
