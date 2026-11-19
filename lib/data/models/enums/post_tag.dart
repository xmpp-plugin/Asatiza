import '../../../l10n/app_localizations.dart';

/// The one tag every post carries (plan section 4).
enum PostTag {
  reminder,
  tajweedTip,
  hifz,
  question,
  classAnnouncement,
  achievement;

  /// Achievement and class announcement tags use the gold tint.
  bool get isGold =>
      this == PostTag.achievement || this == PostTag.classAnnouncement;
}

extension PostTagLabel on PostTag {
  String label(AppLocalizations l10n) => switch (this) {
    PostTag.reminder => l10n.tagReminder,
    PostTag.tajweedTip => l10n.tagTajweedTip,
    PostTag.hifz => l10n.tagHifz,
    PostTag.question => l10n.tagQuestion,
    PostTag.classAnnouncement => l10n.tagClassAnnouncement,
    PostTag.achievement => l10n.tagAchievement,
  };
}
