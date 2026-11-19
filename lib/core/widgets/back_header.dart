import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_icon.dart';

/// 56 px header with a 44 px back (or close) button, an optional page
/// title (18/24 bold) and optional trailing widgets.
class BackHeader extends StatelessWidget {
  const BackHeader({
    super.key,
    this.title,
    this.onBack,
    this.useClose = false,
    this.trailing = const <Widget>[],
  });

  final String? title;

  /// Defaults to popping the current route.
  final VoidCallback? onBack;

  /// Close (×) instead of back (‹), e.g. on New post.
  final bool useClose;
  final List<Widget> trailing;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.space4,
        ),
        child: Row(
          children: <Widget>[
            Transform.translate(
              offset: Offset(
                useClose
                    ? 0
                    : (Directionality.of(context) == TextDirection.rtl
                          ? 10
                          : -10),
                0,
              ),
              child: IconButton(
                onPressed: onBack ?? () => context.pop(),
                tooltip: useClose ? l10n.closeAction : l10n.backAction,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 44,
                  height: 44,
                ),
                icon: AppIcon(
                  useClose ? AppIcon.close : AppIcon.chevronLeft,
                  size: useClose ? 22 : 24,
                  color: colors.ink,
                ),
              ),
            ),
            SizedBox(width: useClose ? AppSpacing.space2 : AppSpacing.space1),
            Expanded(
              child: title == null
                  ? const SizedBox.shrink()
                  : Semantics(
                      header: true,
                      child: Text(
                        title!,
                        style: AppTextStyles.pageTitle.copyWith(
                          color: colors.ink,
                        ),
                      ),
                    ),
            ),
            ...trailing,
          ],
        ),
      ),
    );
  }
}
