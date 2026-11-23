import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../data/models/message.dart';
import '../../../../l10n/app_localizations.dart';

/// Text bubble (artboard 18): own messages are brand with read ticks on the
/// end side; received ones are white with a line border. Links (e.g. a Zoom
/// link) are bold brand and copy on tap.
class ChatBubble extends StatelessWidget {
  const ChatBubble({required this.message, required this.mine, super.key});

  final Message message;
  final bool mine;

  static final RegExp _link = RegExp(
    r'((https?:\/\/)?[a-z0-9-]+(\.[a-z0-9-]+)+(\/[^\s]*)?)',
    caseSensitive: false,
  );

  /// Bubble shape: 18 px corners, 6 px on the sender's bottom corner.
  static BorderRadiusDirectional radius({required bool mine}) =>
      BorderRadiusDirectional.only(
        topStart: const Radius.circular(18),
        topEnd: const Radius.circular(18),
        bottomStart: Radius.circular(mine ? 18 : 6),
        bottomEnd: Radius.circular(mine ? 6 : 18),
      );

  /// "4:02 pm".
  static String time(DateTime t, AppLocalizations l10n) =>
      DateFormat('h:mm a', l10n.localeName).format(t).toLowerCase();

  Future<void> _copy(BuildContext context, String link) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    await Clipboard.setData(ClipboardData(text: link));
    messenger.showSnackBar(SnackBar(content: Text(l10n.linkCopiedMessage)));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context);
    final foreground = mine ? colors.onBrand : colors.ink;
    final body = message.body ?? '';
    final spans = <InlineSpan>[];
    var index = 0;
    for (final match in _link.allMatches(body)) {
      if (match.start > index) {
        spans.add(TextSpan(text: body.substring(index, match.start)));
      }
      final link = match.group(0)!;
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
          child: GestureDetector(
            onTap: () => _copy(context, link),
            child: Text(
              link,
              style: AppTextStyles.bodyMd.copyWith(
                fontWeight: FontWeight.w600,
                color: mine ? colors.onBrand : colors.brand700,
              ),
            ),
          ),
        ),
      );
      index = match.end;
    }
    if (index < body.length) {
      spans.add(TextSpan(text: body.substring(index)));
    }
    return Align(
      alignment: mine
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: FractionallySizedBox(
        widthFactor: 0.78,
        alignment: mine
            ? AlignmentDirectional.centerEnd
            : AlignmentDirectional.centerStart,
        child: Align(
          alignment: mine
              ? AlignmentDirectional.centerEnd
              : AlignmentDirectional.centerStart,
          child: Container(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: AppSpacing.gap14,
              vertical: AppSpacing.gap10,
            ),
            decoration: BoxDecoration(
              color: mine ? colors.brand600 : colors.surface000,
              border: mine ? null : Border.all(color: colors.line),
              borderRadius: radius(mine: mine),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text.rich(
                  TextSpan(children: spans),
                  style: AppTextStyles.bodyMd.copyWith(color: foreground),
                ),
                const SizedBox(height: AppSpacing.gap2),
                _MessageMeta(message: message, mine: mine, l10n: l10n),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Time (and read ticks on own messages) under a bubble.
class _MessageMeta extends StatelessWidget {
  const _MessageMeta({
    required this.message,
    required this.mine,
    required this.l10n,
  });

  final Message message;
  final bool mine;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final color = mine ? colors.brand100 : colors.inkMuted;
    return Semantics(
      label: mine && message.isRead ? l10n.messageReadLabel : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            ChatBubble.time(message.sentAt, l10n),
            style: AppTextStyles.micro.copyWith(
              fontWeight: FontWeight.w400,
              color: color,
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
                color: color,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
