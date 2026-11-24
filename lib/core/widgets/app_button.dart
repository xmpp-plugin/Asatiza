import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

enum AppButtonVariant { primary, secondary, danger }

enum AppButtonSize {
  /// 48 px, 12 px radius (forms, sheets).
  large,

  /// 36 px pill (cards, headers).
  small,
}

/// The design's buttons: primary (brand fill), secondary (white with brand
/// outline) and danger. A null [onPressed] shows the disabled style
/// (surface-200 fill, muted text). [loading] keeps the variant's colours,
/// shows a small spinner left of the label and ignores taps.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.large,
    this.expand = true,
    this.leading,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;

  /// Full width (large buttons in forms) or hug the label.
  final bool expand;
  final Widget? leading;

  /// A call is running: spinner in place of [leading], taps ignored.
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final enabled = onPressed != null || loading;
    final (Color background, Color foreground, Color border) = !enabled
        ? (colors.surface200, colors.inkMuted, colors.surface200)
        : switch (variant) {
            AppButtonVariant.primary => (
              colors.brand600,
              colors.onBrand,
              colors.brand600,
            ),
            AppButtonVariant.secondary => (
              colors.surface000,
              colors.brand700,
              colors.brand600,
            ),
            AppButtonVariant.danger => (
              colors.danger,
              colors.onDanger,
              colors.danger,
            ),
          };
    final large = size == AppButtonSize.large;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(
        large ? AppRadius.md : AppRadius.pill,
      ),
      side: BorderSide(color: border),
    );

    final child = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (loading) ...<Widget>[
          SizedBox.square(
            dimension: large ? 18 : 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: foreground,
              semanticsLabel: label,
            ),
          ),
          const SizedBox(width: AppSpacing.space2),
        ] else if (leading != null) ...<Widget>[
          IconTheme.merge(
            data: IconThemeData(color: foreground),
            child: DefaultTextStyle.merge(
              style: TextStyle(color: foreground),
              child: leading!,
            ),
          ),
          const SizedBox(width: AppSpacing.space2),
        ],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.label.copyWith(color: foreground),
          ),
        ),
      ],
    );

    return Semantics(
      button: true,
      enabled: enabled && !loading,
      child: Material(
        color: background,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: loading ? null : onPressed,
          child: SizedBox(
            height: large ? 48 : 36,
            width: expand ? double.infinity : null,
            child: Padding(
              padding: EdgeInsetsDirectional.symmetric(
                horizontal: large ? AppSpacing.space5 : AppSpacing.space4,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
