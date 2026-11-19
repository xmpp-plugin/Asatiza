import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Multi-line field with an optional label above and a "n / max" counter
/// below on the end side (bio, notes).
class AppTextArea extends StatelessWidget {
  const AppTextArea({
    required this.controller,
    required this.maxLength,
    super.key,
    this.label,
    this.placeholder,
    this.height = 96,
    this.onChanged,
  });

  final TextEditingController controller;
  final int maxLength;
  final String? label;
  final String? placeholder;
  final double height;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (label != null) ...<Widget>[
          Text(label!, style: AppTextStyles.label.copyWith(color: colors.ink)),
          const SizedBox(height: AppSpacing.gap6),
        ],
        Container(
          height: height,
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.space4,
            vertical: AppSpacing.space3,
          ),
          decoration: BoxDecoration(
            color: colors.surface000,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: colors.line),
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            maxLines: null,
            expands: true,
            maxLength: maxLength,
            textAlignVertical: TextAlignVertical.top,
            cursorColor: colors.brand600,
            style: AppTextStyles.bodyLg.copyWith(color: colors.ink),
            decoration: InputDecoration(
              isCollapsed: true,
              border: InputBorder.none,
              counterText: '',
              hintText: placeholder,
              hintStyle: AppTextStyles.bodyLg.copyWith(color: colors.inkMuted),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.gap6),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) => Text(
              l10n.characterCounter(value.text.characters.length, maxLength),
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w400,
                color: colors.inkMuted,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
