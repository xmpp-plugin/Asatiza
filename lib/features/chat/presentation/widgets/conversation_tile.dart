import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../data/models/conversation.dart';
import '../../../../data/models/profile.dart';
import '../../../../l10n/app_localizations.dart';

/// Chat list row (artboard 17): 52 px avatar, name, time and last message.
/// Unread rows are white with a bold name, brand time and a count bubble.
class ConversationTile extends StatelessWidget {
  const ConversationTile({
    required this.conversation,
    required this.other,
    required this.viewerId,
    required this.onTap,
    super.key,
    this.now,
  });

  final Conversation conversation;
  final Profile other;
  final String viewerId;
  final VoidCallback onTap;

  /// Clock for tests; defaults to now.
  final DateTime? now;

  /// "4:16 pm" today, "Yesterday", "Mon" this week, otherwise "12 Nov".
  static String timeLabel(DateTime time, AppLocalizations l10n, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(time.year, time.month, time.day);
    final days = today.difference(day).inDays;
    if (days == 0) {
      return DateFormat('h:mm a', l10n.localeName).format(time).toLowerCase();
    }
    if (days == 1) {
      return l10n.timeYesterday;
    }
    if (days < 7) {
      return DateFormat.E(l10n.localeName).format(time);
    }
    return DateFormat('d MMM', l10n.localeName).format(time);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context);
    final last = conversation.lastMessage;
    final unread = conversation.unreadCount > 0;
    final mine = last?.senderId == viewerId;
    final text = last == null
        ? ''
        : (last.body?.split('\n').first ?? l10n.sentAPhoto);
    final preview = mine ? l10n.youPrefix(text) : text;
    return Material(
      color: unread ? colors.surface000 : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space4,
            vertical: AppSpacing.space3,
          ),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: colors.line)),
          ),
          child: Row(
            children: <Widget>[
              AppAvatar(profile: other, size: 52, showVerified: true),
              const SizedBox(width: AppSpacing.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            other.fullName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.nameMd.copyWith(
                              fontWeight: unread
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: colors.ink,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.space2),
                        if (last != null)
                          Text(
                            timeLabel(last.sentAt, l10n, now ?? DateTime.now()),
                            style:
                                (unread
                                        ? AppTextStyles.captionBold
                                        : AppTextStyles.caption.copyWith(
                                            fontWeight: FontWeight.w400,
                                          ))
                                    .copyWith(
                                      color: unread
                                          ? colors.brand700
                                          : colors.inkMuted,
                                    ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.gap2),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            preview,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.body.copyWith(
                              color: unread ? colors.ink : colors.inkMuted,
                            ),
                          ),
                        ),
                        if (unread) ...<Widget>[
                          const SizedBox(width: AppSpacing.space2),
                          Container(
                            constraints: const BoxConstraints(minWidth: 20),
                            height: 20,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.gap6,
                            ),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: colors.brand600,
                              borderRadius: BorderRadius.circular(
                                AppRadius.pill,
                              ),
                            ),
                            child: Text(
                              '${conversation.unreadCount}',
                              style: AppTextStyles.micro.copyWith(
                                height: 1,
                                color: colors.onBrand,
                              ),
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
      ),
    );
  }
}
