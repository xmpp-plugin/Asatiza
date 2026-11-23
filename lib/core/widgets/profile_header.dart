import 'package:flutter/material.dart';

import '../../data/models/profile.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_avatar.dart';
import 'app_icon.dart';
import 'verified_badge.dart';

/// Centred profile header: 88 px avatar, 26 px display name, muted subtitle
/// and an optional pill — gold "Verified teacher" ([goldBadge]) or brand
/// with [badgeIcon] (e.g. "Looking for a teacher").
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    required this.profile,
    required this.subtitle,
    super.key,
    this.badge,
    this.goldBadge = false,
    this.badgeIcon = AppIcon.search,
  });

  final Profile profile;
  final String subtitle;
  final String? badge;
  final bool goldBadge;
  final String badgeIcon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final foreground = goldBadge ? colors.gold700 : colors.brand700;
    return Column(
      children: <Widget>[
        AppAvatar(profile: profile, size: 88, showVerified: true),
        const SizedBox(height: AppSpacing.space2 + AppSpacing.gap6),
        Semantics(
          header: true,
          child: Text(
            profile.fullName,
            textAlign: TextAlign.center,
            style: AppTextStyles.displayMd.copyWith(color: colors.ink),
          ),
        ),
        const SizedBox(height: AppSpacing.gap6),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMd.copyWith(color: colors.inkMuted),
        ),
        if (badge != null) ...<Widget>[
          const SizedBox(height: AppSpacing.gap6),
          Container(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: AppSpacing.gap10,
              vertical: AppSpacing.space1,
            ),
            decoration: BoxDecoration(
              color: goldBadge ? colors.gold100 : colors.brand100,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (goldBadge)
                  const VerifiedBadge()
                else
                  AppIcon(badgeIcon, size: 16, color: foreground),
                const SizedBox(width: AppSpacing.gap6),
                Text(
                  badge!,
                  style: AppTextStyles.helperStrong.copyWith(color: foreground),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
