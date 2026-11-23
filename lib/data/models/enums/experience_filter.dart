import '../../../l10n/app_localizations.dart';

/// Teacher filter "Experience": Any / 2+ / 5+ / 10+ years.
enum ExperienceFilter {
  any(0),
  twoPlus(2),
  fivePlus(5),
  tenPlus(10);

  const ExperienceFilter(this.minYears);

  /// Minimum years of experience this option requires.
  final int minYears;
}

extension ExperienceFilterLabel on ExperienceFilter {
  String label(AppLocalizations l10n) => switch (this) {
    ExperienceFilter.any => l10n.genderAny,
    ExperienceFilter.twoPlus => l10n.experienceYearsPlus(2),
    ExperienceFilter.fivePlus => l10n.experienceYearsPlus(5),
    ExperienceFilter.tenPlus => l10n.experienceYearsPlus(10),
  };
}
