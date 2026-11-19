import '../../../l10n/app_localizations.dart';

/// Age group of the learner on a student account.
enum LearnerAgeGroup { child, teen, adult }

extension LearnerAgeGroupLabel on LearnerAgeGroup {
  String label(AppLocalizations l10n) => switch (this) {
    LearnerAgeGroup.child => l10n.ageGroupChild,
    LearnerAgeGroup.teen => l10n.ageGroupTeen,
    LearnerAgeGroup.adult => l10n.ageGroupAdult,
  };

  /// Age range shown under the label, e.g. "6–12".
  String range(AppLocalizations l10n) => switch (this) {
    LearnerAgeGroup.child => l10n.ageGroupChildRange,
    LearnerAgeGroup.teen => l10n.ageGroupTeenRange,
    LearnerAgeGroup.adult => l10n.ageGroupAdultRange,
  };
}
