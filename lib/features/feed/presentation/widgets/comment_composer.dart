import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../data/models/profile.dart';
import '../../../../l10n/app_localizations.dart';

/// Bottom composer on post detail: user avatar, pill field "Write a
/// comment…" and a 44 px brand send button.
class CommentComposer extends StatelessWidget {
  const CommentComposer({
    required this.user,
    required this.controller,
    required this.focusNode,
    required this.onSend,
    super.key,
  });

  final Profile user;
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback? onSend;

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
            AppSpacing.space3,
          ),
          child: Row(
            children: <Widget>[
              AppAvatar(profile: user, size: 36),
              const SizedBox(width: AppSpacing.gap10),
              Expanded(
                child: Container(
                  height: 44,
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: AppSpacing.gap14,
                  ),
                  alignment: AlignmentDirectional.centerStart,
                  decoration: ShapeDecoration(
                    color: colors.surface100,
                    shape: StadiumBorder(side: BorderSide(color: colors.line)),
                  ),
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => onSend?.call(),
                    cursorColor: colors.brand600,
                    style: AppTextStyles.bodyMd.copyWith(
                      height: 20 / 15,
                      color: colors.ink,
                    ),
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: l10n.writeCommentPlaceholder,
                      hintStyle: AppTextStyles.bodyMd.copyWith(
                        height: 20 / 15,
                        color: colors.inkMuted,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.gap10),
              Material(
                color: onSend == null ? colors.surface200 : colors.brand600,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onSend,
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: Center(
                      child: AppIcon(
                        AppIcon.send,
                        size: 20,
                        color: onSend == null
                            ? colors.inkMuted
                            : colors.onBrand,
                        semanticLabel: l10n.sendCommentAction,
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
