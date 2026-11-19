import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../data/models/enums/subject.dart';
import '../../data/models/post.dart';
import '../../data/models/profile.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/relative_time_formatter.dart';
import 'app_avatar.dart';
import 'app_icon.dart';
import 'tag_chip.dart';
import 'verified_badge.dart';

/// Feed post card: author row, text (4 lines in the feed), optional Arabic
/// verse and photo, tag + counts, and Like / Comment / Report actions.
class PostCard extends StatelessWidget {
  const PostCard({
    required this.post,
    required this.author,
    required this.onLike,
    required this.onComment,
    super.key,
    this.onReport,
    this.onOpen,
    this.onMore,
    this.clampText = true,
  });

  final Post post;
  final Profile author;
  final VoidCallback onLike;
  final VoidCallback onComment;

  /// Null hides "Report" (the viewer's own posts).
  final VoidCallback? onReport;

  /// Opens post detail when the text is tapped (feed only).
  final VoidCallback? onOpen;
  final VoidCallback? onMore;

  /// Feed shows 4 lines; post detail shows everything.
  final bool clampText;

  static const RelativeTimeFormatter _time = RelativeTimeFormatter();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final l10n = AppLocalizations.of(context);
    final subject = author.teacherDetails?.subjects.firstOrNull;
    final role = author.isTeacher
        ? (subject == null
              ? l10n.roleTeacher
              : l10n.postMetaTeacher(subject.label(l10n)))
        : l10n.roleStudent;
    final meta = '$role · ${_time.format(post.createdAt, l10n)}';

    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(
            top: AppSpacing.space3,
            bottom: AppSpacing.space2,
          ),
          child: Text(
            post.body,
            maxLines: clampText ? 4 : null,
            overflow: clampText ? TextOverflow.ellipsis : null,
            style: AppTextStyles.bodyMd.copyWith(color: colors.ink),
          ),
        ),
        if (post.arabicVerse != null)
          Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.space1,
              bottom: AppSpacing.space2,
            ),
            child: Text(
              post.arabicVerse!,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              locale: const Locale('ar'),
              style: AppTextStyles.quran.copyWith(color: colors.brand700),
            ),
          ),
      ],
    );
    if (onOpen != null) {
      content = InkWell(onTap: onOpen, child: content);
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: colors.surface000,
        border: Border.all(color: colors.line),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card(theme.brightness),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              AppAvatar(profile: author),
              const SizedBox(width: AppSpacing.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            author.fullName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.nameMd.copyWith(
                              color: colors.ink,
                            ),
                          ),
                        ),
                        if (author.isVerified) ...<Widget>[
                          const SizedBox(width: AppSpacing.gap6),
                          const VerifiedBadge(),
                        ],
                      ],
                    ),
                    Text(
                      meta,
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w400,
                        color: colors.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (onMore != null)
                IconButton(
                  onPressed: onMore,
                  tooltip: l10n.postOptionsAction,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 44,
                    height: 44,
                  ),
                  icon: AppIcon(AppIcon.more, size: 22, color: colors.inkMuted),
                ),
            ],
          ),
          content,
          if (post.imagePath != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.space3),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Container(
                  height: 150,
                  color: colors.brand100,
                  child: SvgPicture.asset(
                    post.imagePath!,
                    fit: BoxFit.cover,
                    alignment: Alignment.bottomCenter,
                    semanticsLabel: l10n.postPhotoLabel,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.space2),
            child: Row(
              children: <Widget>[
                TagChip(tag: post.tag),
                const Spacer(),
                Text(
                  l10n.postCounts(post.likeCount, post.commentCount),
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w400,
                    color: colors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: colors.line)),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.space1),
              child: Row(
                children: <Widget>[
                  _Action(
                    icon: AppIcon(
                      AppIcon.heart,
                      size: 20,
                      color: post.likedByMe ? colors.brand700 : colors.inkMuted,
                      fillColor: post.likedByMe ? colors.brand600 : null,
                    ),
                    label: post.likedByMe ? l10n.likedAction : l10n.likeAction,
                    color: post.likedByMe ? colors.brand700 : colors.inkMuted,
                    selected: post.likedByMe,
                    onTap: onLike,
                  ),
                  _Action(
                    icon: AppIcon(
                      AppIcon.comment,
                      size: 20,
                      color: colors.inkMuted,
                    ),
                    label: l10n.commentAction,
                    color: colors.inkMuted,
                    onTap: onComment,
                  ),
                  if (onReport != null)
                    _Action(
                      icon: AppIcon(
                        AppIcon.flag,
                        size: 20,
                        color: colors.inkMuted,
                      ),
                      label: l10n.reportAction,
                      color: colors.inkMuted,
                      onTap: onReport!,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.selected,
  });

  final Widget icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool? selected;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        excludeSemantics: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                icon,
                const SizedBox(width: AppSpacing.gap6),
                Text(label, style: AppTextStyles.label.copyWith(color: color)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
