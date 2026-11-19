import '../../../l10n/app_localizations.dart';

/// Languages a teacher teaches in or a student speaks.
enum TeachingLanguage { urdu, english, arabic, punjabi, pashto, hindi }

extension TeachingLanguageLabel on TeachingLanguage {
  String label(AppLocalizations l10n) => switch (this) {
    TeachingLanguage.urdu => l10n.languageUrdu,
    TeachingLanguage.english => l10n.languageEnglish,
    TeachingLanguage.arabic => l10n.languageArabic,
    TeachingLanguage.punjabi => l10n.languagePunjabi,
    TeachingLanguage.pashto => l10n.languagePashto,
    TeachingLanguage.hindi => l10n.languageHindi,
  };
}
