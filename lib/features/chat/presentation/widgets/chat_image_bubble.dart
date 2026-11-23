import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../data/models/message.dart';
import '../../../../l10n/app_localizations.dart';
import 'chat_bubble.dart';

/// Image message (artboard 18): 220 px bubble with a 130 px image, optional
/// caption and the time (plus read ticks on own messages).
class ChatImageBubble extends StatelessWidget {
  const ChatImageBubble({required this.message, required this.mine, super.key});

  final Message message;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context);
    final metaColor = mine ? colors.brand100 : colors.inkMuted;
    return Align(
      alignment: mine
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(AppSpacing.gap6),
        decoration: BoxDecoration(
          color: mine ? colors.brand600 : colors.surface000,
          border: mine ? null : Border.all(color: colors.line),
          borderRadius: ChatBubble.radius(mine: mine),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Container(
                height: 130,
                color: colors.gold100,
                child: SvgPicture.asset(
                  message.imagePath!,
                  fit: BoxFit.cover,
                  semanticsLabel: l10n.chatPhotoLabel,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                AppSpacing.space2,
                AppSpacing.gap6,
                AppSpacing.space2,
                AppSpacing.gap2,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (message.body != null)
                    Text(
                      message.body!,
                      style: AppTextStyles.bodyMd.copyWith(
                        color: mine ? colors.onBrand : colors.ink,
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        ChatBubble.time(message.sentAt, l10n),
                        style: AppTextStyles.micro.copyWith(
                          fontWeight: FontWeight.w400,
                          color: metaColor,
                        ),
                      ),
                      if (mine) ...<Widget>[
                        const SizedBox(width: AppSpacing.space1),
                        Opacity(
                          opacity: message.isRead ? 1 : 0.6,
                          child: AppIcon(
                            AppIcon.readTicks,
                            size: 18,
                            height: 12,
                            strokeWidth: 2,
                            color: metaColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
