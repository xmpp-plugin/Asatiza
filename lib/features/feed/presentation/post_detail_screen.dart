import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/failures.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/session/session_cubit.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/confirm_sheet.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/back_header.dart';
import '../../../core/widgets/post_card.dart';
import '../../../core/widgets/post_card_skeleton.dart';
import '../../../core/widgets/section_label.dart';
import '../../../data/models/profile.dart';
import '../../../data/repositories/feed_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../safety/presentation/report_sheet.dart';
import '../bloc/post_detail_cubit.dart';
import '../bloc/post_detail_state.dart';
import 'widgets/comment_composer.dart';
import 'widgets/comment_tile.dart';

/// 09 Post detail: the full post, its comments and the comment composer.
class PostDetailScreen extends StatelessWidget {
  const PostDetailScreen({required this.postId, super.key});

  final String postId;

  @override
  Widget build(BuildContext context) {
    final user = context.read<SessionCubit>().state.user!;
    return BlocProvider<PostDetailCubit>(
      create: (context) => PostDetailCubit(
        context.read<FeedRepository>(),
        context.read<ProfileRepository>(),
        postId: postId,
        viewerId: user.id,
      ),
      child: _PostDetailView(user: user),
    );
  }
}

class _PostDetailView extends StatefulWidget {
  const _PostDetailView({required this.user});

  final Profile user;

  @override
  State<_PostDetailView> createState() => _PostDetailViewState();
}

class _PostDetailViewState extends State<_PostDetailView> {
  final TextEditingController _comment = TextEditingController();
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _comment.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _comment.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _leave() =>
      context.canPop() ? context.pop() : context.go(AppRoutes.home);

  Future<void> _report(PostDetailState state) async {
    final sent = await ReportSheet.show(
      context,
      post: state.post!,
      author: state.author!,
      reporterId: widget.user.id,
    );
    if (sent && mounted) {
      _leave();
    }
  }

  Future<void> _deletePost() async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<PostDetailCubit>();
    final confirmed = await ConfirmSheet.show(
      context,
      title: l10n.deletePostTitle,
      message: l10n.deletePostMessage,
      confirmLabel: l10n.deleteAction,
      cancelLabel: l10n.cancelAction,
      danger: true,
    );
    if (confirmed && await cubit.deletePost() && mounted) {
      _leave();
    }
  }

  Future<void> _deleteComment(String commentId) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<PostDetailCubit>();
    final confirmed = await ConfirmSheet.show(
      context,
      title: l10n.deleteCommentTitle,
      message: l10n.deleteCommentMessage,
      confirmLabel: l10n.deleteAction,
      cancelLabel: l10n.cancelAction,
      danger: true,
    );
    if (confirmed) {
      await cubit.deleteComment(commentId);
    }
  }

  Future<void> _reportComment(PostDetailState state, String commentId) =>
      ReportSheet.show(
        context,
        post: state.post!,
        author:
            state.people[state.comments
                .firstWhere((c) => c.id == commentId)
                .authorId]!,
        reporterId: widget.user.id,
        commentId: commentId,
      );

  String _errorText(ValidationReason reason, AppLocalizations l10n) =>
      switch (reason) {
        ValidationReason.dailyCommentLimit => l10n.dailyCommentLimitError,
        ValidationReason.network => l10n.errorNoConnection,
        _ => l10n.errorSomethingWentWrong,
      };

  Future<void> _send() async {
    final ok = await context.read<PostDetailCubit>().addComment(_comment.text);
    if (ok) {
      _comment.clear();
      _focus.unfocus();
    }
  }

  void _reply(Profile author) {
    _comment.text = '@${author.fullName} ';
    _comment.selection = TextSelection.collapsed(offset: _comment.text.length);
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context);
    return BlocConsumer<PostDetailCubit, PostDetailState>(
      listenWhen: (a, b) =>
          (a.status != b.status && b.status == PostDetailStatus.notFound) ||
          (b.error != null && a.error != b.error),
      listener: (context, state) {
        final error = state.error;
        if (error != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(_errorText(error, l10n))));
          context.read<PostDetailCubit>().errorShown();
          return;
        }
        _leave();
      },
      builder: (context, state) {
        final cubit = context.read<PostDetailCubit>();
        final post = state.post;
        final author = state.author;
        final isOwn = post?.authorId == widget.user.id;
        return Scaffold(
          body: SafeArea(
            bottom: false,
            child: Column(
              children: <Widget>[
                BackHeader(
                  title: l10n.postTitle,
                  onBack: _leave,
                  trailing: <Widget>[
                    if (post != null && author != null)
                      IconButton(
                        onPressed: isOwn ? _deletePost : () => _report(state),
                        tooltip: l10n.postOptionsAction,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints.tightFor(
                          width: 44,
                          height: 44,
                        ),
                        icon: AppIcon(
                          AppIcon.more,
                          size: 22,
                          color: colors.ink,
                        ),
                      ),
                  ],
                ),
                Expanded(
                  child: post == null || author == null
                      ? ListView(
                          padding: const EdgeInsets.all(AppSpacing.space4),
                          children: const <Widget>[PostCardSkeleton()],
                        )
                      : ListView(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                            AppSpacing.space4,
                            AppSpacing.space1,
                            AppSpacing.space4,
                            AppSpacing.space3,
                          ),
                          children: <Widget>[
                            PostCard(
                              post: post,
                              author: author,
                              clampText: false,
                              onLike: cubit.toggleLike,
                              onComment: _focus.requestFocus,
                              onReport: isOwn ? null : () => _report(state),
                              onMore: isOwn
                                  ? _deletePost
                                  : () => _report(state),
                            ),
                            const SizedBox(height: AppSpacing.gap14),
                            SectionLabel(
                              l10n.commentsHeading(state.comments.length),
                            ),
                            for (final comment in state.comments)
                              if (state.people[comment.authorId] !=
                                  null) ...<Widget>[
                                const SizedBox(height: AppSpacing.gap14),
                                CommentTile(
                                  comment: comment,
                                  author: state.people[comment.authorId]!,
                                  onLike: () =>
                                      cubit.toggleCommentLike(comment.id),
                                  onReply: () =>
                                      _reply(state.people[comment.authorId]!),
                                  onDelete: comment.authorId == widget.user.id
                                      ? () => _deleteComment(comment.id)
                                      : null,
                                  onReport: comment.authorId == widget.user.id
                                      ? null
                                      : () => _reportComment(state, comment.id),
                                ),
                              ],
                          ],
                        ),
                ),
                CommentComposer(
                  user: widget.user,
                  controller: _comment,
                  focusNode: _focus,
                  onSend: _comment.text.trim().isEmpty || state.sending
                      ? null
                      : _send,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
