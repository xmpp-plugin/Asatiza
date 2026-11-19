import '../../../l10n/app_localizations.dart';

/// Report reasons (plan section 9).
enum ReportReason {
  spam,
  inappropriate,
  hateOrHarassment,
  falseInformation,
  somethingElse,
}

extension ReportReasonLabel on ReportReason {
  String label(AppLocalizations l10n) => switch (this) {
    ReportReason.spam => l10n.reportReasonSpam,
    ReportReason.inappropriate => l10n.reportReasonInappropriate,
    ReportReason.hateOrHarassment => l10n.reportReasonHate,
    ReportReason.falseInformation => l10n.reportReasonFalseInformation,
    ReportReason.somethingElse => l10n.reportReasonSomethingElse,
  };
}
