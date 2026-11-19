import '../../../l10n/app_localizations.dart';

/// Who a teacher teaches (plan section 7).
enum TeachesAudience { children, women, men, all }

extension TeachesAudienceLabel on TeachesAudience {
  String label(AppLocalizations l10n) => switch (this) {
    TeachesAudience.children => l10n.audienceChildren,
    TeachesAudience.women => l10n.audienceWomen,
    TeachesAudience.men => l10n.audienceMen,
    TeachesAudience.all => l10n.audienceAll,
  };
}
