import '../../../l10n/app_localizations.dart';

enum Gender { male, female }

extension GenderLabel on Gender {
  String label(AppLocalizations l10n) => switch (this) {
    Gender.male => l10n.genderMale,
    Gender.female => l10n.genderFemale,
  };
}
