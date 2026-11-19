import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';

/// Short relative times as in the design: "now", "20m", "2h", "Yesterday",
/// "Mon", "12 Nov".
class RelativeTimeFormatter {
  const RelativeTimeFormatter();

  String format(DateTime time, AppLocalizations l10n, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final diff = current.difference(time);
    if (diff.inMinutes < 1) {
      return l10n.timeNow;
    }
    if (diff.inMinutes < 60) {
      return l10n.timeMinutes(diff.inMinutes);
    }
    if (diff.inHours < 24) {
      return l10n.timeHours(diff.inHours);
    }
    final today = DateTime(current.year, current.month, current.day);
    final day = DateTime(time.year, time.month, time.day);
    final days = today.difference(day).inDays;
    if (days <= 1) {
      return l10n.timeYesterday;
    }
    if (days < 7) {
      return DateFormat.E(l10n.localeName).format(time);
    }
    return DateFormat('d MMM', l10n.localeName).format(time);
  }
}
