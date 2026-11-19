import '../../../l10n/app_localizations.dart';

enum FeeUnit { perClass, perMonth }

extension FeeUnitLabel on FeeUnit {
  String label(AppLocalizations l10n) => switch (this) {
    FeeUnit.perClass => l10n.feeUnitPerClass,
    FeeUnit.perMonth => l10n.feeUnitPerMonth,
  };
}
