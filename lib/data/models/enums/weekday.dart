import '../../../l10n/app_localizations.dart';

/// Days of the week, Monday first, as in the availability picker.
enum Weekday { monday, tuesday, wednesday, thursday, friday, saturday, sunday }

extension WeekdayLabel on Weekday {
  /// One-letter label used in the day picker ("M", "T"…).
  String initial(AppLocalizations l10n) => switch (this) {
    Weekday.monday => l10n.weekdayMondayInitial,
    Weekday.tuesday => l10n.weekdayTuesdayInitial,
    Weekday.wednesday => l10n.weekdayWednesdayInitial,
    Weekday.thursday => l10n.weekdayThursdayInitial,
    Weekday.friday => l10n.weekdayFridayInitial,
    Weekday.saturday => l10n.weekdaySaturdayInitial,
    Weekday.sunday => l10n.weekdaySundayInitial,
  };

  /// Full name used for accessibility.
  String label(AppLocalizations l10n) => switch (this) {
    Weekday.monday => l10n.weekdayMonday,
    Weekday.tuesday => l10n.weekdayTuesday,
    Weekday.wednesday => l10n.weekdayWednesday,
    Weekday.thursday => l10n.weekdayThursday,
    Weekday.friday => l10n.weekdayFriday,
    Weekday.saturday => l10n.weekdaySaturday,
    Weekday.sunday => l10n.weekdaySunday,
  };
}
