import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../data/models/enums/fee_unit.dart';
import '../../../../data/models/enums/subject.dart';
import '../../../../data/models/enums/teaches_audience.dart';
import '../../../../data/models/enums/teaching_language.dart';
import '../../../../data/models/profile.dart';
import '../../../../l10n/app_localizations.dart';

/// Teacher card on the Teachers tab (artboard 11): avatar, name, headline,
/// subject / language / audience chips, location, experience, fee, and the
/// [connectButton] next to "View profile".
class TeacherCard extends StatelessWidget {
  const TeacherCard({
    required this.profile,
    required this.connectButton,
    required this.onOpen,
    super.key,
  });

  final Profile profile;
  final Widget connectButton;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final l10n = AppLocalizations.of(context);
    final t = profile.teacherDetails;
    final fee = t?.feeAmount;
    final meta = AppTextStyles.helper.copyWith(color: colors.inkMuted);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.gap14),
      decoration: BoxDecoration(
        color: colors.surface000,
        border: Border.all(color: colors.line),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card(theme.brightness),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          InkWell(
            onTap: onOpen,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AppAvatar(profile: profile, size: 52, showVerified: true),
                const SizedBox(width: AppSpacing.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        profile.fullName,
                        style: AppTextStyles.cardTitle.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.ink,
                        ),
                      ),
                      if (profile.headline != null)
                        Text(
                          profile.headline!,
                          style: AppTextStyles.body.copyWith(
                            color: colors.inkMuted,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
          Wrap(
            spacing: AppSpacing.gap6,
            runSpacing: AppSpacing.gap6,
            children: <Widget>[
              for (final s in (t?.subjects ?? const <Subject>[]).take(2))
                _Chip(s.label(l10n), brand: true),
              if (profile.languages.isNotEmpty)
                _Chip(profile.languages.map((l) => l.label(l10n)).join(' · ')),
              if (t?.teaches.contains(TeachesAudience.children) ?? false)
                _Chip(l10n.teachesChildrenLabel),
            ],
          ),
          const SizedBox(height: AppSpacing.space3),
          Row(
            children: <Widget>[
              AppIcon(AppIcon.mapPin, size: 16, color: colors.inkMuted),
              const SizedBox(width: AppSpacing.space1),
              Flexible(
                child: Text(
                  l10n.cityAndTimeZone(
                    profile.city ?? '',
                    profile.timeZone ?? '',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: meta,
                ),
              ),
              if (t?.experienceYears != null) ...<Widget>[
                const SizedBox(width: AppSpacing.space3),
                AppIcon(
                  AppIcon.graduationCap,
                  size: 16,
                  color: colors.inkMuted,
                ),
                const SizedBox(width: AppSpacing.space1),
                Text(l10n.yearsShort(t!.experienceYears!), style: meta),
              ],
              const Spacer(),
              if (fee != null)
                Text(
                  t!.feeUnit == FeeUnit.perClass
                      ? l10n.feePerClassShort(fee)
                      : l10n.feePerMonthShort(fee),
                  style: AppTextStyles.label.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.gold700,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.space3),
          Row(
            children: <Widget>[
              Expanded(child: connectButton),
              const SizedBox(width: AppSpacing.space2),
              Expanded(
                child: AppButton(
                  label: l10n.viewProfileAction,
                  onPressed: onOpen,
                  variant: AppButtonVariant.secondary,
                  size: AppButtonSize.small,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 24 px detail chip: brand for subjects, grey for languages / audience.
class _Chip extends StatelessWidget {
  const _Chip(this.label, {this.brand = false});

  final String label;
  final bool brand;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Container(
      height: 24,
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.space2,
      ),
      decoration: BoxDecoration(
        color: brand ? colors.brand100 : colors.surface200,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: brand ? colors.brand700 : colors.inkMuted,
            ),
          ),
        ],
      ),
    );
  }
}
