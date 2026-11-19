import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';

/// Chats tab placeholder with the designed title header. The chat list and
/// search come with the chat phase.
class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: AlignmentDirectional.topStart,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            AppSpacing.space4,
            AppSpacing.space3,
            AppSpacing.space4,
            AppSpacing.space2,
          ),
          child: Semantics(
            header: true,
            child: Text(
              AppLocalizations.of(context).chatsTitle,
              style: AppTextStyles.screenTitle,
            ),
          ),
        ),
      ),
    );
  }
}
