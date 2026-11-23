import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';

/// Notification row (artboard 19): 48 px [leading], rich [message], relative
/// time and an optional [footer] (request note and buttons). Unread rows
/// have the brand-100 background.
class NotificationTile extends StatelessWidget {
  const NotificationTile({
    required this.leading,
    required this.message,
    required this.time,
    required this.unread,
    super.key,
    this.onTap,
    this.footer,
    this.now,
  });

  final Widget leading;
  final InlineSpan message;
  final DateTime time;
  final bool unread;
  final VoidCallback? onTap;
  final Widget? footer;

  /// Clock for tests; defaults to now.
  final DateTime? now;

  /// "Just now", "10 min ago", "1h ago", "Yesterday", "2 days ago", "12 Nov".
  static String ago(DateTime time, AppLocalizations l10n, DateTime now) {
    final diff = now.difference(time);
    if (diff.inMinutes < 1) {
      return l10n.timeJustNow;
    }
    if (diff.inMinutes < 60) {
      return l10n.timeMinutesAgo(diff.inMinutes);
    }
    if (diff.inHours < 24) {
      return l10n.timeHoursAgo(diff.inHours);
    }
    final today = DateTime(now.year, now.month, now.day);
    final days = today
        .difference(DateTime(time.year, time.month, time.day))
        .inDays;
    if (days <= 1) {
      return l10n.timeYesterday;
    }
    if (days < 7) {
      return l10n.timeDaysAgo(days);
    }
    return DateFormat('d MMM', l10n.localeName).format(time);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context);
    return Material(
      color: unread ? colors.brand100 : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space4,
            vertical: AppSpacing.gap14,
          ),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: colors.line)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              leading,
              const SizedBox(width: AppSpacing.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text.rich(
                      message,
                      style: AppTextStyles.body.copyWith(color: colors.ink),
                    ),
                    const SizedBox(height: AppSpacing.gap2),
                    Text(
                      ago(time, l10n, now ?? DateTime.now()),
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w400,
                        color: colors.inkMuted,
                      ),
                    ),
                    ?footer,
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
