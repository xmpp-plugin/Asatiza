import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_icon.dart';

/// Search input from the artboards: 44 px, 20 px search icon, 15 px text.
///
/// The list style ([pill] false) is a 12 px-radius white field with a 1 px
/// line border (Teachers / Students tabs). The [pill] style has a 2 px brand
/// border and a 32 px clear button while there is text (search results).
class SearchField extends StatelessWidget {
  const SearchField({
    required this.controller,
    required this.placeholder,
    required this.onChanged,
    super.key,
    this.pill = false,
    this.autofocus = false,
    this.semanticLabel,
  });

  final TextEditingController controller;
  final String placeholder;
  final ValueChanged<String> onChanged;
  final bool pill;
  final bool autofocus;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context);
    return Container(
      height: 44,
      padding: EdgeInsetsDirectional.only(
        start: pill ? 13 : AppSpacing.space3,
        end: pill ? AppSpacing.gap6 : AppSpacing.space3,
      ),
      decoration: BoxDecoration(
        color: colors.surface000,
        borderRadius: BorderRadius.circular(
          pill ? AppRadius.pill : AppRadius.md,
        ),
        border: Border.all(
          color: pill ? colors.brand600 : colors.line,
          width: pill ? 2 : 1,
        ),
      ),
      child: Row(
        children: <Widget>[
          AppIcon(AppIcon.search, size: 20, color: colors.inkMuted),
          const SizedBox(width: AppSpacing.space2),
          Expanded(
            child: Semantics(
              label: semanticLabel,
              textField: true,
              child: TextField(
                controller: controller,
                autofocus: autofocus,
                onChanged: onChanged,
                textInputAction: TextInputAction.search,
                style: AppTextStyles.bodyMd.copyWith(color: colors.ink),
                cursorColor: colors.brand600,
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: placeholder,
                  hintStyle: AppTextStyles.bodyMd.copyWith(
                    color: colors.inkMuted,
                  ),
                ),
              ),
            ),
          ),
          if (pill)
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, _) => value.text.isEmpty
                  ? const SizedBox.shrink()
                  : Semantics(
                      button: true,
                      label: l10n.clearSearchAction,
                      excludeSemantics: true,
                      child: Material(
                        color: colors.surface200,
                        shape: const CircleBorder(),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () {
                            controller.clear();
                            onChanged('');
                          },
                          child: SizedBox(
                            width: 32,
                            height: 32,
                            child: Center(
                              child: AppIcon(
                                AppIcon.close,
                                size: 16,
                                strokeWidth: 2.2,
                                color: colors.inkMuted,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
        ],
      ),
    );
  }
}
