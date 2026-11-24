import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_checkbox.dart';
import '../../../data/models/enums/report_reason.dart';
import '../../../data/models/post.dart';
import '../../../data/models/profile.dart';
import '../../../data/repositories/safety_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../bloc/report_cubit.dart';
import '../bloc/report_state.dart';

/// 22 Report sheet: five reasons, "Also block" + author, Cancel / Report.
class ReportSheet extends StatelessWidget {
  const ReportSheet({required this.author, super.key});

  final Profile author;

  /// Opens the sheet; completes with true when a report was sent. Shows a
  /// confirmation snackbar.
  static Future<bool> show(
    BuildContext context, {
    required Post post,
    required Profile author,
    required String reporterId,
  }) async {
    final safety = context.read<SafetyRepository>();
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final sent = await AppBottomSheet.show<bool>(
      context,
      builder: (_) => BlocProvider<ReportCubit>(
        create: (_) => ReportCubit(
          safety,
          postId: post.id,
          authorId: author.id,
          reporterId: reporterId,
        ),
        child: ReportSheet(author: author),
      ),
    );
    if (sent ?? false) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.reportSentMessage)));
    }
    return sent ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<ReportCubit>();

    return BlocConsumer<ReportCubit, ReportState>(
      listenWhen: (a, b) =>
          a.status != b.status && b.status == ReportStatus.sent,
      listener: (context, _) => Navigator.of(context).pop(true),
      builder: (context, state) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Semantics(
            header: true,
            child: Text(
              l10n.reportTitle,
              style: AppTextStyles.titleLg.copyWith(color: colors.ink),
            ),
          ),
          const SizedBox(height: AppSpacing.space2),
          Text(
            l10n.reportSubtitle,
            style: AppTextStyles.body.copyWith(color: colors.inkMuted),
          ),
          const SizedBox(height: AppSpacing.gap14),
          for (final reason in ReportReason.values) ...<Widget>[
            if (reason != ReportReason.values.first)
              const SizedBox(height: AppSpacing.space2),
            _ReasonTile(
              label: reason.label(l10n),
              selected: state.reason == reason,
              onTap: () => cubit.reasonSelected(reason),
            ),
          ],
          const SizedBox(height: AppSpacing.gap14),
          AppCheckbox(
            value: state.alsoBlock,
            onChanged: cubit.alsoBlockChanged,
            label: Text.rich(
              TextSpan(
                style: AppTextStyles.body.copyWith(color: colors.ink),
                children: <InlineSpan>[
                  TextSpan(text: l10n.alsoBlockPrefix),
                  TextSpan(
                    text: author.fullName,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: l10n.alsoBlockSuffix),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.gap14),
          Row(
            children: <Widget>[
              Expanded(
                child: AppButton(
                  label: l10n.cancelAction,
                  variant: AppButtonVariant.secondary,
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ),
              const SizedBox(width: AppSpacing.gap10),
              Expanded(
                child: AppButton(
                  label: l10n.reportAction,
                  variant: AppButtonVariant.danger,
                  loading: state.status == ReportStatus.sending,
                  onPressed: state.canSend ? cubit.submit : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Radio option row: 22 px ring and label.
class _ReasonTile extends StatelessWidget {
  const _ReasonTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      child: Material(
        color: selected ? colors.brand100 : colors.surface000,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(
            color: selected ? colors.brand600 : colors.line,
            width: selected ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: AppSpacing.gap14,
              vertical: AppSpacing.space3,
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? colors.brand600 : colors.inkMuted,
                      width: 2,
                    ),
                  ),
                  child: selected
                      ? Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: colors.brand600,
                            shape: BoxShape.circle,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: AppSpacing.space3),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.nameMd.copyWith(color: colors.ink),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
