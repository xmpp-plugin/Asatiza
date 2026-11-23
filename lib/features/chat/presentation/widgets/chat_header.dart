import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../data/models/enums/subject.dart';
import '../../../../data/models/profile.dart';
import '../../../../l10n/app_localizations.dart';

/// Chat top bar (artboard 18): back, 40 px avatar with name and role line
/// (opens the profile), and the options button.
class ChatHeader extends StatelessWidget {
  const ChatHeader({
    required this.other,
    required this.onBack,
    required this.onProfile,
    required this.onOptions,
    super.key,
  });

  final Profile? other;
  final VoidCallback onBack;
  final VoidCallback onProfile;
  final VoidCallback onOptions;

  /// "Tajweed teacher · Lahore" / "Student · Manchester".
  static String subtitle(Profile p, AppLocalizations l10n) {
    final subjects = p.teacherDetails?.subjects ?? const <Subject>[];
    final role = p.isTeacher
        ? (subjects.isEmpty
              ? l10n.roleTeacher
              : l10n.subjectTeacher(subjects.first.label(l10n)))
        : l10n.roleStudent;
    return p.city == null ? role : '$role · ${p.city}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context);
    final p = other;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface000,
        border: Border(bottom: BorderSide(color: colors.line)),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 64,
          child: Padding(
            padding: const EdgeInsetsDirectional.only(
              start: AppSpacing.gap6,
              end: AppSpacing.space3,
            ),
            child: Row(
              children: <Widget>[
                IconButton(
                  tooltip: l10n.backAction,
                  onPressed: onBack,
                  icon: AppIcon(
                    AppIcon.chevronLeft,
                    size: 22,
                    color: colors.ink,
                  ),
                ),
                const SizedBox(width: AppSpacing.gap10),
                Expanded(
                  child: p == null
                      ? const SizedBox.shrink()
                      : InkWell(
                          onTap: onProfile,
                          child: Row(
                            children: <Widget>[
                              AppAvatar(
                                profile: p,
                                size: 40,
                                showVerified: true,
                              ),
                              const SizedBox(width: AppSpacing.gap10),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      p.fullName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.nameMd.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: colors.ink,
                                      ),
                                    ),
                                    Text(
                                      subtitle(p, l10n),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.caption.copyWith(
                                        fontWeight: FontWeight.w400,
                                        color: colors.inkMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
                IconButton(
                  tooltip: l10n.chatOptionsAction,
                  onPressed: onOptions,
                  icon: AppIcon(AppIcon.more, size: 22, color: colors.ink),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
