import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_bottom_sheet.dart';
import 'app_button.dart';
import 'app_icon.dart';

/// Confirmation sheet (artboards 21f / 21g): optional 56 px icon circle,
/// 20 px title, muted message, optional [body], then Cancel and the confirm
/// button side by side. [danger] makes the icon and button red.
class ConfirmSheet extends StatelessWidget {
  const ConfirmSheet({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.onConfirm,
    super.key,
    this.icon,
    this.danger = false,
    this.body,
    this.loading = false,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;

  /// Null disables the confirm button (e.g. until a box is ticked).
  final VoidCallback? onConfirm;
  final String? icon;
  final bool danger;
  final Widget? body;

  /// The confirmed action is running: spinner on the confirm button and
  /// Cancel disabled.
  final bool loading;

  /// Shows a simple sheet; true when confirmed.
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required String cancelLabel,
    String? icon,
    bool danger = false,
  }) async {
    final confirmed = await AppBottomSheet.show<bool>(
      context,
      builder: (context) => ConfirmSheet(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        icon: icon,
        danger: danger,
        onConfirm: () => Navigator.of(context).pop(true),
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (icon != null) ...<Widget>[
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: danger ? colors.danger100 : colors.brand100,
                shape: BoxShape.circle,
              ),
              child: AppIcon(
                icon!,
                size: 26,
                color: danger ? colors.danger : colors.brand700,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.gap14),
        ],
        Semantics(
          header: true,
          child: Text(
            title,
            style: AppTextStyles.titleLg.copyWith(color: colors.ink),
          ),
        ),
        const SizedBox(height: AppSpacing.space2),
        Text(
          message,
          style: AppTextStyles.body.copyWith(color: colors.inkMuted),
        ),
        if (body != null) ...<Widget>[
          const SizedBox(height: AppSpacing.gap14),
          body!,
        ],
        const SizedBox(height: AppSpacing.gap14),
        Row(
          children: <Widget>[
            Expanded(
              child: AppButton(
                label: cancelLabel,
                variant: AppButtonVariant.secondary,
                onPressed: loading
                    ? null
                    : () => Navigator.of(context).pop(false),
              ),
            ),
            const SizedBox(width: AppSpacing.gap10),
            Expanded(
              child: AppButton(
                label: confirmLabel,
                variant: danger
                    ? AppButtonVariant.danger
                    : AppButtonVariant.primary,
                loading: loading,
                onPressed: onConfirm,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
