import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/session/session_cubit.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/chat_row_skeleton.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/search_field.dart';
import '../../../data/models/profile.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../bloc/chats_cubit.dart';
import '../bloc/chats_state.dart';
import 'widgets/conversation_tile.dart';

/// 17 Chats: search and the conversation list.
class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select<SessionCubit, Profile?>((c) => c.state.user);
    if (user == null) {
      return const SizedBox.shrink();
    }
    return BlocProvider<ChatsCubit>(
      key: ValueKey<String>(user.id),
      create: (context) => ChatsCubit(
        context.read<ChatRepository>(),
        context.read<ProfileRepository>(),
        viewerId: user.id,
      ),
      child: _ChatsView(viewer: user),
    );
  }
}

class _ChatsView extends StatefulWidget {
  const _ChatsView({required this.viewer});

  final Profile viewer;

  @override
  State<_ChatsView> createState() => _ChatsViewState();
}

class _ChatsViewState extends State<_ChatsView> {
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).extension<AppColors>()!;
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppSpacing.space4,
              AppSpacing.space3,
              AppSpacing.space4,
              AppSpacing.space2,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Semantics(
                  header: true,
                  child: Text(
                    l10n.chatsTitle,
                    style: AppTextStyles.screenTitle.copyWith(
                      color: colors.ink,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.space3),
                SearchField(
                  controller: _search,
                  placeholder: l10n.searchChatsLabel,
                  semanticLabel: l10n.searchChatsLabel,
                  onChanged: context.read<ChatsCubit>().queryChanged,
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<ChatsCubit, ChatsState>(
              builder: (context, state) {
                if (state.loading) {
                  return ListView(
                    children: const <Widget>[
                      ChatRowSkeleton(previewFactor: 0.85),
                      ChatRowSkeleton(previewFactor: 0.7),
                      ChatRowSkeleton(previewFactor: 0.85),
                    ],
                  );
                }
                final items = state.visible;
                if (items.isEmpty) {
                  final searching = state.query.trim().isNotEmpty;
                  return Padding(
                    padding: const EdgeInsets.all(AppSpacing.space6),
                    child: Align(
                      alignment: const Alignment(0, -0.4),
                      child: EmptyStateView(
                        icon: searching ? AppIcon.search : AppIcon.chat,
                        title: searching
                            ? l10n.noResultsTitle(state.query.trim())
                            : l10n.emptyChatsTitle,
                        message: searching
                            ? l10n.noChatResultsMessage
                            : (widget.viewer.isTeacher
                                  ? l10n.emptyChatsMessageTeacher
                                  : l10n.emptyChatsMessage),
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final c = items[i];
                    final other = state.people[c.otherId(widget.viewer.id)]!;
                    return ConversationTile(
                      conversation: c,
                      other: other,
                      viewerId: widget.viewer.id,
                      onTap: () => context.push(AppRoutes.chat(other.id)),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
