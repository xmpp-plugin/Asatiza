import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../l10n/app_localizations.dart';

/// Footer of a connection-request notification: the quoted note in a white
/// box, then Accept / Decline while the request is open.
class RequestNotificationTile extends StatelessWidget {
  const RequestNotificationTile({
    required this.open,
    required this.onAccept,
    required this.onDecline,
    super.key,
    this.note,
  });

  final String? note;

  /// False once the request was answered (buttons hidden).
  final bool open;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (note != null) ...<Widget>[
          const SizedBox(height: AppSpacing.space2),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space3,
              vertical: AppSpacing.space2,
            ),
            decoration: BoxDecoration(
              color: colors.surface000,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(
              l10n.quotedNote(note!),
              style: AppTextStyles.body.copyWith(color: colors.inkMuted),
            ),
          ),
        ],
        if (open) ...<Widget>[
          const SizedBox(height: AppSpacing.gap10),
          Row(
            children: <Widget>[
              AppButton(
                label: l10n.acceptAction,
                onPressed: onAccept,
                size: AppButtonSize.small,
                expand: false,
              ),
              const SizedBox(width: AppSpacing.space2),
              AppButton(
                label: l10n.declineAction,
                onPressed: onDecline,
                size: AppButtonSize.small,
                variant: AppButtonVariant.secondary,
                expand: false,
              ),
            ],
          ),
        ],
      ],
    );
  }
}
