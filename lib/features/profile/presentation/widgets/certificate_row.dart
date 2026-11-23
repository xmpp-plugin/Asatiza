import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../l10n/app_localizations.dart';

/// Uploaded certificate in Edit profile (artboard 20d): document icon, file
/// name and a remove button.
class CertificateRow extends StatelessWidget {
  const CertificateRow({required this.path, required this.onRemove, super.key});

  /// Storage path; the file name is shown.
  final String path;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsetsDirectional.only(
        start: AppSpacing.gap14,
        top: AppSpacing.space1,
        bottom: AppSpacing.space1,
      ),
      decoration: BoxDecoration(
        color: colors.surface000,
        border: Border.all(color: colors.line),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: <Widget>[
          AppIcon(AppIcon.document, size: 20, color: colors.brand700),
          const SizedBox(width: AppSpacing.space3),
          Expanded(
            child: Text(
              path.split('/').last,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body.copyWith(color: colors.ink),
            ),
          ),
          IconButton(
            tooltip: l10n.removeCertificateAction,
            onPressed: onRemove,
            icon: AppIcon(AppIcon.close, size: 20, color: colors.inkMuted),
          ),
        ],
      ),
    );
  }
}
