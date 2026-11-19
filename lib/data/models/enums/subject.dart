import '../../../l10n/app_localizations.dart';

/// Quran-learning subjects (plan section 7).
enum Subject {
  nooraniQaida,
  nazra,
  tajweed,
  hifz,
  tafsir,
  arabic,
  islamicStudies,
}

extension SubjectLabel on Subject {
  String label(AppLocalizations l10n) => switch (this) {
    Subject.nooraniQaida => l10n.subjectNooraniQaida,
    Subject.nazra => l10n.subjectNazra,
    Subject.tajweed => l10n.subjectTajweed,
    Subject.hifz => l10n.subjectHifz,
    Subject.tafsir => l10n.subjectTafsir,
    Subject.arabic => l10n.subjectArabic,
    Subject.islamicStudies => l10n.subjectIslamicStudies,
  };
}
