import '../../../l10n/app_localizations.dart';

/// Current reading level of a learner.
enum LearnerLevel { beginner, readsWithHelp, readsFluently, memorising }

extension LearnerLevelLabel on LearnerLevel {
  String label(AppLocalizations l10n) => switch (this) {
    LearnerLevel.beginner => l10n.levelBeginner,
    LearnerLevel.readsWithHelp => l10n.levelReadsWithHelp,
    LearnerLevel.readsFluently => l10n.levelReadsFluently,
    LearnerLevel.memorising => l10n.levelMemorising,
  };

  String description(AppLocalizations l10n) => switch (this) {
    LearnerLevel.beginner => l10n.levelBeginnerDescription,
    LearnerLevel.readsWithHelp => l10n.levelReadsWithHelpDescription,
    LearnerLevel.readsFluently => l10n.levelReadsFluentlyDescription,
    LearnerLevel.memorising => l10n.levelMemorisingDescription,
  };
}
