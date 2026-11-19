import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Section heading (15/20, bold) with optional trailing text, e.g.
/// "Choose a tag … Required" or "Available days … 5:00–9:00 pm".
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.trailing});

  final String text;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Row(
      children: <Widget>[
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              text,
              style: AppTextStyles.sectionTitle.copyWith(color: colors.ink),
            ),
          ),
        ),
        if (trailing != null)
          Text(
            trailing!,
            style: AppTextStyles.helper.copyWith(color: colors.inkMuted),
          ),
      ],
    );
  }
}
