import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/session/session_cubit.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/back_header.dart';
import '../../../core/widgets/section_label.dart';
import '../../../data/models/enums/post_tag.dart';
import '../../../data/models/profile.dart';
import '../../../data/repositories/feed_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../bloc/create_post_cubit.dart';
import '../bloc/create_post_state.dart';
import '../logic/post_rules.dart';

/// 10 Create post: text (max 1,500), one photo, one required tag and the
/// content-policy note.
class CreatePostScreen extends StatelessWidget {
  const CreatePostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<SessionCubit>().state.user!;
    return BlocProvider<CreatePostCubit>(
      create: (context) =>
          CreatePostCubit(context.read<FeedRepository>(), authorId: user.id),
      child: _CreatePostView(user: user),
    );
  }
}

class _CreatePostView extends StatelessWidget {
  const _CreatePostView({required this.user});

  final Profile user;

  void _close(BuildContext context) =>
      context.canPop() ? context.pop() : context.go(AppRoutes.home);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<CreatePostCubit>();
    final count = NumberFormat.decimalPattern(l10n.localeName);

    return BlocConsumer<CreatePostCubit, CreatePostState>(
      listenWhen: (a, b) =>
          a.status != b.status && b.status == CreatePostStatus.posted,
      listener: (context, _) => _close(context),
      builder: (context, state) => Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            children: <Widget>[
              BackHeader(
                title: l10n.newPostTitle,
                useClose: true,
                onBack: () => _close(context),
                trailing: <Widget>[
                  AppButton(
                    label: l10n.postAction,
                    size: AppButtonSize.small,
                    expand: false,
                    loading: state.status == CreatePostStatus.posting,
                    onPressed: state.canPost ? cubit.submit : null,
                  ),
                ],
              ),
              Expanded(
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          AppSpacing.space4,
                          AppSpacing.space2,
                          AppSpacing.space4,
                          AppSpacing.space3,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                AppAvatar(profile: user, size: 40),
                                const SizedBox(width: AppSpacing.gap10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      user.fullName,
                                      style: AppTextStyles.nameMd.copyWith(
                                        color: colors.ink,
                                      ),
                                    ),
                                    Text(
                                      l10n.postingToEveryone,
                                      style: AppTextStyles.caption.copyWith(
                                        fontWeight: FontWeight.w400,
                                        color: colors.inkMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.space4),
                            SizedBox(
                              height: 150,
                              child: TextField(
                                onChanged: cubit.bodyChanged,
                                autofocus: true,
                                maxLines: null,
                                expands: true,
                                maxLength: PostRules.maxLength,
                                textAlignVertical: TextAlignVertical.top,
                                cursorColor: colors.brand600,
                                style: AppTextStyles.composer.copyWith(
                                  color: colors.ink,
                                ),
                                decoration: InputDecoration(
                                  isCollapsed: true,
                                  border: InputBorder.none,
                                  counterText: '',
                                  hintText: l10n.postPlaceholder,
                                  hintStyle: AppTextStyles.composer.copyWith(
                                    color: colors.inkMuted,
                                  ),
                                ),
                              ),
                            ),
                            if (state.hasPhoto) ...<Widget>[
                              const SizedBox(height: AppSpacing.space4),
                              Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: SizedBox(
                                  width: 140,
                                  height: 110,
                                  child: Stack(
                                    children: <Widget>[
                                      Positioned.fill(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            AppRadius.md,
                                          ),
                                          child: ColoredBox(
                                            color: colors.gold100,
                                            child: SvgPicture.asset(
                                              CreatePostCubit.sampleAttachment,
                                              fit: BoxFit.cover,
                                              semanticsLabel:
                                                  l10n.postPhotoLabel,
                                            ),
                                          ),
                                        ),
                                      ),
                                      PositionedDirectional(
                                        top: AppSpacing.gap6,
                                        end: AppSpacing.gap6,
                                        child: Material(
                                          color: colors.ink.withValues(
                                            alpha: 0.7,
                                          ),
                                          shape: const CircleBorder(),
                                          child: InkWell(
                                            onTap: cubit.photoRemoved,
                                            customBorder: const CircleBorder(),
                                            child: SizedBox(
                                              width: 28,
                                              height: 28,
                                              child: Center(
                                                child: AppIcon(
                                                  AppIcon.close,
                                                  size: 16,
                                                  strokeWidth: 2.4,
                                                  color: colors.surface000,
                                                  semanticLabel:
                                                      l10n.removePhotoAction,
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
                            ],
                            const SizedBox(height: AppSpacing.space4),
                            SectionLabel(
                              l10n.chooseTagLabel,
                              trailing: l10n.requiredLabel,
                            ),
                            const SizedBox(height: AppSpacing.gap10),
                            Wrap(
                              spacing: AppSpacing.space2,
                              runSpacing: AppSpacing.space2,
                              children: <Widget>[
                                for (final tag in PostTag.values)
                                  AppChip(
                                    label: tag.label(l10n),
                                    selected: state.tag == tag,
                                    onTap: () => cubit.tagSelected(tag),
                                  ),
                              ],
                            ),
                            const Spacer(),
                            const SizedBox(height: AppSpacing.space4),
                            Container(
                              padding: const EdgeInsetsDirectional.symmetric(
                                horizontal: AppSpacing.gap14,
                                vertical: AppSpacing.space3,
                              ),
                              decoration: BoxDecoration(
                                color: colors.surface200,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.md,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  AppIcon(
                                    AppIcon.shield,
                                    size: 18,
                                    color: colors.inkMuted,
                                  ),
                                  const SizedBox(width: AppSpacing.gap10),
                                  Expanded(
                                    child: Text(
                                      l10n.contentPolicyNote,
                                      style: AppTextStyles.helper.copyWith(
                                        color: colors.inkMuted,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              DecoratedBox(
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
                      AppSpacing.space2,
                      AppSpacing.space3,
                      AppSpacing.space3,
                    ),
                    child: Row(
                      children: <Widget>[
                        TextButton.icon(
                          onPressed: state.hasPhoto ? null : cubit.photoAdded,
                          style: TextButton.styleFrom(
                            minimumSize: const Size(0, 44),
                            foregroundColor: colors.brand700,
                            textStyle: AppTextStyles.label,
                          ),
                          icon: AppIcon(
                            AppIcon.image,
                            size: 22,
                            color: state.hasPhoto
                                ? colors.inkMuted
                                : colors.brand700,
                          ),
                          label: Text(l10n.photoAction),
                        ),
                        const Spacer(),
                        Text(
                          l10n.postCounter(
                            count.format(state.length),
                            count.format(PostRules.maxLength),
                          ),
                          style: AppTextStyles.helper.copyWith(
                            color: state.length > PostRules.maxLength
                                ? colors.danger
                                : colors.inkMuted,
                          ),
                        ),
                      ],
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
