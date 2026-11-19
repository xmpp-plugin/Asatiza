import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';

/// Teachers tab placeholder with the designed title header. Search, filters
/// and the role-aware Students view come with the discover phase.
class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

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
              AppLocalizations.of(context).teachersTitle,
              style: AppTextStyles.screenTitle,
            ),
          ),
        ),
      ),
    );
  }
}
