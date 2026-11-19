import 'package:flutter/material.dart';

import '../../data/models/profile.dart';
import '../../l10n/app_localizations.dart';
import '../logic/profile_strength_calculator.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_button.dart';
import 'app_icon.dart';

/// Brand-tinted card: "Your profile is n% complete", a hint for the next
/// missing item, an 8 px progress bar, "Complete profile" and steps left.
class ProfileStrengthCard extends StatelessWidget {
  const ProfileStrengthCard({
    required this.profile,
    required this.onComplete,
    required this.onDismiss,
    super.key,
  });

  final Profile profile;
  final VoidCallback onComplete;
  final VoidCallback onDismiss;

  static const ProfileStrengthCalculator _calculator =
      ProfileStrengthCalculator();

  static String hintFor(ProfileStrengthItem item, AppLocalizations l10n) =>
      switch (item) {
        ProfileStrengthItem.photo => l10n.strengthHintPhoto,
        ProfileStrengthItem.headline => l10n.strengthHintHeadline,
        ProfileStrengthItem.subjects => l10n.strengthHintSubjects,
        ProfileStrengthItem.teachingLanguages ||
        ProfileStrengthItem.studentLanguages => l10n.strengthHintLanguages,
        ProfileStrengthItem.bio => l10n.strengthHintBio,
        ProfileStrengthItem.experience => l10n.strengthHintExperience,
        ProfileStrengthItem.feeAndAvailability => l10n.strengthHintFee,
        ProfileStrengthItem.certificate => l10n.strengthHintCertificate,
        ProfileStrengthItem.learningGoals => l10n.strengthHintGoals,
        ProfileStrengthItem.ageGroup => l10n.strengthHintAgeGroup,
        ProfileStrengthItem.level => l10n.strengthHintLevel,
        ProfileStrengthItem.location => l10n.strengthHintLocation,
        ProfileStrengthItem.preferredTeacherGender =>
          l10n.strengthHintPreferredGender,
        ProfileStrengthItem.photoOrNote => l10n.strengthHintPhotoOrNote,
      };

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context);
    final percent = _calculator.percent(profile);
    final missing = _calculator.missing(profile);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: colors.brand100,
        borderRadius: BorderRadius.circular(AppRadius.strengthCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      l10n.strengthTitle(percent),
                      style: AppTextStyles.cardTitle.copyWith(
                        color: colors.ink,
                      ),
                    ),
                    if (missing.isNotEmpty) ...<Widget>[
                      const SizedBox(height: AppSpacing.gap2),
                      Text(
                        hintFor(missing.first, l10n),
                        style: AppTextStyles.helper.copyWith(
                          color: colors.brand700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.space2),
              IconButton(
                onPressed: onDismiss,
                tooltip: l10n.hideAction,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 44,
                  height: 44,
                ),
                icon: AppIcon(AppIcon.close, size: 22, color: colors.brand700),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.gap10),
          Semantics(
            value: '$percent%',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: SizedBox(
                height: 8,
                child: LinearProgressIndicator(
                  value: percent / 100,
                  backgroundColor: colors.surface000,
                  color: colors.brand600,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.gap10),
          Row(
            children: <Widget>[
              AppButton(
                label: l10n.completeProfileAction,
                onPressed: onComplete,
                size: AppButtonSize.small,
                expand: false,
              ),
              const Spacer(),
              Text(
                l10n.stepsLeft(missing.length),
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.brand700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
