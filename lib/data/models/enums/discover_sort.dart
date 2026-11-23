import '../../../l10n/app_localizations.dart';

/// List order on the Teachers / Students tabs: [recommended] is verified and
/// most complete first; [newest] is the newest profile first.
enum DiscoverSort { recommended, newest }

extension DiscoverSortLabel on DiscoverSort {
  String label(AppLocalizations l10n) => switch (this) {
    DiscoverSort.recommended => l10n.sortMostComplete,
    DiscoverSort.newest => l10n.sortNewestFirst,
  };
}
