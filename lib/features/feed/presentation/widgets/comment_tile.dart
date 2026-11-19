import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/relative_time_formatter.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/verified_badge.dart';
import '../../../../data/models/comment.dart';
import '../../../../data/models/profile.dart';
import '../../../../l10n/app_localizations.dart';

/// Comment: 36 px avatar, white bubble (4 px top-start corner, 14 px
/// others) with name and text, then "1h · Like · Reply".
class CommentTile extends StatelessWidget {
  const CommentTile({
    required this.comment,
    required this.author,
    required this.onLike,
    required this.onReply,
    super.key,
  });

  final Comment comment;
  final Profile author;
  final VoidCallback onLike;
  final VoidCallback onReply;

  static const RelativeTimeFormatter _time = RelativeTimeFormatter();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context);
    final meta = AppTextStyles.caption.copyWith(
      fontWeight: FontWeight.w400,
      color: colors.inkMuted,
    );
    final metaStrong = meta.copyWith(fontWeight: FontWeight.w600);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AppAvatar(profile: author, size: 36),
        const SizedBox(width: AppSpacing.gap10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppSpacing.space3,
                  vertical: AppSpacing.gap10,
                ),
                decoration: BoxDecoration(
                  color: colors.surface000,
                  border: Border.all(color: colors.line),
                  borderRadius: const BorderRadiusDirectional.only(
                    topStart: Radius.circular(AppRadius.commentTail),
                    topEnd: Radius.circular(AppRadius.optionCard),
                    bottomStart: Radius.circular(AppRadius.optionCard),
                    bottomEnd: Radius.circular(AppRadius.optionCard),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            author.fullName,
                            style: AppTextStyles.helper.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colors.ink,
                            ),
                          ),
                        ),
                        if (author.isVerified) ...<Widget>[
                          const SizedBox(width: AppSpacing.gap6),
                          const VerifiedBadge(size: 14),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpacing.gap2),
                    Text(
                      comment.body,
                      style: AppTextStyles.body.copyWith(color: colors.ink),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.space1),
              Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: AppSpacing.space1,
                ),
                child: Row(
                  children: <Widget>[
                    Text(_time.format(comment.createdAt, l10n), style: meta),
                    const SizedBox(width: AppSpacing.space4),
                    Semantics(
                      button: true,
                      selected: comment.likedByMe,
                      child: GestureDetector(
                        onTap: onLike,
                        behavior: HitTestBehavior.opaque,
                        child: Text(
                          comment.likeCount > 0
                              ? '${l10n.likeAction} · ${comment.likeCount}'
                              : l10n.likeAction,
                          style: metaStrong.copyWith(
                            color: comment.likedByMe
                                ? colors.brand700
                                : colors.inkMuted,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space4),
                    Semantics(
                      button: true,
                      child: GestureDetector(
                        onTap: onReply,
                        behavior: HitTestBehavior.opaque,
                        child: Text(l10n.replyAction, style: metaStrong),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
