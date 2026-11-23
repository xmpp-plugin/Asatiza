import 'package:flutter/material.dart';

import '../../../core/widgets/confirm_sheet.dart';
import '../../../l10n/app_localizations.dart';

/// 21g Log out sheet.
abstract final class LogOutSheet {
  /// True when the user confirmed.
  static Future<bool> show(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ConfirmSheet.show(
      context,
      title: l10n.logOutTitle,
      message: l10n.logOutMessage,
      confirmLabel: l10n.logOutAction,
      cancelLabel: l10n.cancelAction,
    );
  }
}
