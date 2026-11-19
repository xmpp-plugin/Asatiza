import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';

/// Alerts tab placeholder titled "Notifications", as in the design. The
/// list and "Mark all read" come with the notifications phase.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: AlignmentDirectional.topStart,
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.space4,
            vertical: AppSpacing.space3,
          ),
          child: Semantics(
            header: true,
            child: Text(
              AppLocalizations.of(context).notificationsTitle,
              style: AppTextStyles.screenTitle,
            ),
          ),
        ),
      ),
    );
  }
}
