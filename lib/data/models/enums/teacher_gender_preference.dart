import '../../../l10n/app_localizations.dart';

/// A student's preferred teacher gender.
enum TeacherGenderPreference { any, male, female }

extension TeacherGenderPreferenceLabel on TeacherGenderPreference {
  String label(AppLocalizations l10n) => switch (this) {
    TeacherGenderPreference.any => l10n.genderAny,
    TeacherGenderPreference.male => l10n.genderMale,
    TeacherGenderPreference.female => l10n.genderFemale,
  };
}
