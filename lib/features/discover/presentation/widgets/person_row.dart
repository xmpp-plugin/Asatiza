import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../data/models/profile.dart';

/// List row with a 48 px avatar, name, one-line subtitle, an optional gold
/// [detail] line (e.g. the fee) and a [trailing] action; 1 px divider
/// below (My connections, search results).
class PersonRow extends StatelessWidget {
  const PersonRow({
    required this.profile,
    required this.subtitle,
    super.key,
    this.detail,
    this.trailing,
    this.onTap,
  });

  final Profile profile;
  final String subtitle;
  final String? detail;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.space3),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: colors.line)),
        ),
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
                  if (detail != null)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.gap2),
                      child: Text(
                        detail!,
                        style: AppTextStyles.captionBold.copyWith(
                          color: colors.gold700,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null) ...<Widget>[
              const SizedBox(width: AppSpacing.space3),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}
