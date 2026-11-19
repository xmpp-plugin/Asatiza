import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../data/models/profile.dart';
import '../../../../l10n/app_localizations.dart';

/// Home's 64 px top bar: the user's 40 px avatar (→ My profile) and the
/// pill search field "Search teachers, posts, subjects".
class HomeTopBar extends StatelessWidget {
  const HomeTopBar({
    required this.user,
    required this.onAvatarTap,
    required this.onSearchTap,
    super.key,
  });

  final Profile user;
  final VoidCallback onAvatarTap;
  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      height: 64,
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.space4,
        ),
        child: Row(
          children: <Widget>[
            Semantics(
              button: true,
              label: l10n.myProfileAndSettings,
              excludeSemantics: true,
              child: InkWell(
                onTap: onAvatarTap,
                customBorder: const CircleBorder(),
                child: AppAvatar(profile: user, size: 40),
              ),
            ),
            const SizedBox(width: AppSpacing.space3),
            Expanded(
              child: Semantics(
                button: true,
                label: l10n.searchPlaceholder,
                excludeSemantics: true,
                child: Material(
                  color: colors.surface000,
                  shape: StadiumBorder(side: BorderSide(color: colors.line)),
                  child: InkWell(
                    onTap: onSearchTap,
                    customBorder: const StadiumBorder(),
                    child: SizedBox(
                      height: 44,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: AppSpacing.gap14,
                        ),
                        child: Row(
                          children: <Widget>[
                            AppIcon(
                              AppIcon.search,
                              size: 20,
                              color: colors.inkMuted,
                            ),
                            const SizedBox(width: AppSpacing.space2),
                            Expanded(
                              child: Text(
                                l10n.searchPlaceholder,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.bodyMd.copyWith(
                                  height: 20 / 15,
                                  color: colors.inkMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
