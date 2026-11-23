import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../data/models/enums/gender.dart';
import '../../../../data/models/enums/learner_age_group.dart';
import '../../../../data/models/enums/learner_level.dart';
import '../../../../data/models/enums/subject.dart';
import '../../../../data/models/enums/teaching_language.dart';
import '../../../../data/models/profile.dart';
import '../../../../l10n/app_localizations.dart';

/// Student card on the Students tab (artboard 12): initials avatar (photos
/// are never shown here), name, age group / gender, "Looking" pill, goal /
/// level / language chips, the student's note, location and
/// [connectButton].
class StudentCard extends StatelessWidget {
  const StudentCard({
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
    final s = profile.studentDetails;
    final group = s?.ageGroup;
    final facts = <String>[
      if (group != null) group.label(l10n),
      if (group != null && group != LearnerAgeGroup.adult) group.range(l10n),
      if (profile.gender != null) profile.gender!.label(l10n),
    ].join(' · ');
    final radius = BorderRadius.circular(AppRadius.lg);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface000,
        border: Border.all(color: colors.line),
        borderRadius: radius,
        boxShadow: AppShadows.card(theme.brightness),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onOpen,
          borderRadius: radius,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.gap14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    AppAvatar(profile: profile, size: 48),
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
                          if (facts.isNotEmpty)
                            Text(
                              facts,
                              style: AppTextStyles.helper.copyWith(
                                color: colors.inkMuted,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (s?.lookingForTeacher ?? false)
                      Container(
                        height: 24,
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: AppSpacing.space2,
                        ),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: colors.brand100,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text(
                          l10n.lookingPill,
                          style: AppTextStyles.micro.copyWith(
                            color: colors.brand700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space3),
                Wrap(
                  spacing: AppSpacing.gap6,
                  runSpacing: AppSpacing.gap6,
                  children: <Widget>[
                    for (final g in s?.goals ?? const <Subject>[])
                      _Chip(g.label(l10n), brand: true),
                    if (s?.level != null) _Chip(s!.level!.label(l10n)),
                    for (final language in profile.languages.take(1))
                      _Chip(language.label(l10n)),
                  ],
                ),
                const SizedBox(height: AppSpacing.gap10),
                if (s?.note != null) ...<Widget>[
                  Text(
                    l10n.quotedNote(s!.note!),
                    style: AppTextStyles.body.copyWith(color: colors.ink),
                  ),
                  const SizedBox(height: AppSpacing.gap10),
                ],
                Row(
                  children: <Widget>[
                    AppIcon(AppIcon.mapPin, size: 16, color: colors.inkMuted),
                    const SizedBox(width: AppSpacing.space1),
                    Expanded(
                      child: Text(
                        l10n.cityAndTimeZone(
                          profile.city ?? '',
                          profile.timeZone ?? '',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.helper.copyWith(
                          color: colors.inkMuted,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space3),
                    connectButton,
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 24 px detail chip: brand for goals, grey for level / language.
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
