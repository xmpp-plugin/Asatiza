import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../data/models/profile.dart';
import '../../../../l10n/app_localizations.dart';

/// Received connection request: avatar, name, subtitle, the optional note
/// and Accept / Decline (My connections → Requests).
class RequestTile extends StatelessWidget {
  const RequestTile({
    required this.profile,
    required this.subtitle,
    required this.onAccept,
    required this.onDecline,
    super.key,
    this.note,
    this.onOpen,
  });

  final Profile profile;
  final String subtitle;
  final String? note;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space3),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.line)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          InkWell(
            onTap: onOpen,
            child: Row(
              children: <Widget>[
                AppAvatar(profile: profile, size: 48, showVerified: true),
                const SizedBox(width: AppSpacing.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        profile.fullName,
                        style: AppTextStyles.nameMd.copyWith(color: colors.ink),
                      ),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.helper.copyWith(
                          color: colors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (note != null) ...<Widget>[
            const SizedBox(height: AppSpacing.space2),
            Text(
              l10n.quotedNote(note!),
              style: AppTextStyles.body.copyWith(color: colors.ink),
            ),
          ],
          const SizedBox(height: AppSpacing.gap10),
          Row(
            children: <Widget>[
              Expanded(
                child: AppButton(
                  label: l10n.acceptAction,
                  onPressed: onAccept,
                  size: AppButtonSize.small,
                ),
              ),
              const SizedBox(width: AppSpacing.space2),
              Expanded(
                child: AppButton(
                  label: l10n.declineAction,
                  onPressed: onDecline,
                  size: AppButtonSize.small,
                  variant: AppButtonVariant.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
