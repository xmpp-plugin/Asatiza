import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../l10n/app_localizations.dart';

/// Chat composer (artboard 18): photo button, 44 px pill field and the
/// round brand send button.
class MessageComposer extends StatelessWidget {
  const MessageComposer({
    required this.controller,
    required this.onSend,
    required this.onPhoto,
    super.key,
    this.enabled = true,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onPhoto;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface000,
        border: Border(top: BorderSide(color: colors.line)),
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: AppSpacing.space3),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            AppSpacing.space3,
            AppSpacing.gap10,
            AppSpacing.space3,
            0,
          ),
          child: Row(
            children: <Widget>[
              IconButton(
                tooltip: l10n.sendPhotoAction,
                onPressed: enabled ? onPhoto : null,
                icon: AppIcon(AppIcon.image, color: colors.brand700),
              ),
              const SizedBox(width: AppSpacing.space1),
              Expanded(
                child: Container(
                  height: 44,
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: AppSpacing.gap14,
                  ),
                  alignment: AlignmentDirectional.centerStart,
                  decoration: BoxDecoration(
                    color: colors.surface100,
                    border: Border.all(color: colors.line),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: TextField(
                    controller: controller,
                    enabled: enabled,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => onSend(),
                    style: AppTextStyles.bodyMd.copyWith(color: colors.ink),
                    cursorColor: colors.brand600,
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: l10n.messageFieldHint,
                      hintStyle: AppTextStyles.bodyMd.copyWith(
                        color: colors.inkMuted,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.space2),
              Tooltip(
                message: l10n.sendAction,
                child: Material(
                  color: enabled ? colors.brand600 : colors.surface200,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: enabled ? onSend : null,
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: Center(
                        child: AppIcon(
                          AppIcon.send,
                          size: 20,
                          color: enabled ? colors.onBrand : colors.inkMuted,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
