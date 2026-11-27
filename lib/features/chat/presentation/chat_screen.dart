import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/errors/failures.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/services/image_compressor.dart';
import '../../../core/services/image_picker_service.dart';
import '../../../core/session/session_cubit.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/photo_source_sheet.dart';
import '../../../core/widgets/skeleton_box.dart';
import '../../../data/models/message.dart';
import '../../../data/models/profile.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../data/repositories/media_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../bloc/chat_cubit.dart';
import '../bloc/chat_state.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/chat_header.dart';
import 'widgets/chat_image_bubble.dart';
import 'widgets/day_divider.dart';
import 'widgets/message_composer.dart';

/// 18 Chat with one connection ([otherId]).
class ChatScreen extends StatelessWidget {
  const ChatScreen({required this.otherId, super.key});

  final String otherId;

  @override
  Widget build(BuildContext context) {
    final viewer = context.select<SessionCubit, Profile?>((c) => c.state.user);
    if (viewer == null) {
      return const SizedBox.shrink();
    }
    return BlocProvider<ChatCubit>(
      create: (context) => ChatCubit(
        context.read<ChatRepository>(),
        context.read<ProfileRepository>(),
        media: context.read<MediaRepository>(),
        picker: context.read<ImagePickerService>(),
        compressor: context.read<ImageCompressor>(),
        viewerId: viewer.id,
        otherId: otherId,
      ),
      child: _ChatView(viewerId: viewer.id),
    );
  }
}

class _ChatView extends StatefulWidget {
  const _ChatView({required this.viewerId});

  final String viewerId;

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  final TextEditingController _text = TextEditingController();

  /// Reloads when the app comes back, in case a live "seen" update or
  /// message was missed while it was in the background.
  late final AppLifecycleListener _lifecycle = AppLifecycleListener(
    onResume: () => context.read<ChatCubit>().refresh(),
  );

  @override
  void initState() {
    super.initState();
    _lifecycle;
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _text.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _text.text;
    if (text.trim().isEmpty) {
      return;
    }
    final sent = await context.read<ChatCubit>().send(text: text);
    if (sent) {
      _text.clear();
    }
  }

  static String _errorText(ValidationReason reason, AppLocalizations l10n) =>
      switch (reason) {
        ValidationReason.messageTooLong => l10n.messageTooLongError,
        ValidationReason.dailyMessageLimit => l10n.dailyMessageLimitError,
        ValidationReason.dailyPhotoLimit => l10n.dailyPhotoLimitError,
        ValidationReason.notConnected => l10n.chatReadOnlyMessage,
        ValidationReason.network => l10n.errorNoConnection,
        ValidationReason.fileTooLarge ||
        ValidationReason.fileTypeNotAllowed => l10n.uploadErrorFailed,
        _ => l10n.errorSomethingWentWrong,
      };

  static DateTime _day(DateTime t) => DateTime(t.year, t.month, t.day);

  String _dayLabel(DateTime t, AppLocalizations l10n) {
    final now = DateTime.now();
    final days = _day(now).difference(_day(t)).inDays;
    if (days == 0) {
      return l10n.dayToday;
    }
    if (days == 1) {
      return l10n.timeYesterday;
    }
    return DateFormat('EEEE, d MMM', l10n.localeName).format(t);
  }

  String _connectedLabel(DateTime t, AppLocalizations l10n) {
    final days = _day(DateTime.now()).difference(_day(t)).inDays;
    return days == 0 ? l10n.connectedToday : l10n.connectedDaysAgo(days);
  }

  /// Messages with day dividers, oldest first.
  List<Widget> _items(ChatState state, AppLocalizations l10n) {
    final items = <Widget>[];
    final started = state.conversation?.startedAt;
    DateTime? previousDay = started == null ? null : _day(started);
    if (started != null) {
      items.add(DayDivider(_connectedLabel(started, l10n)));
    }
    for (final Message m in state.messages) {
      final day = _day(m.sentAt);
      if (previousDay == null || day != previousDay) {
        items.add(DayDivider(_dayLabel(m.sentAt, l10n)));
      }
      previousDay = day;
      final mine = m.senderId == widget.viewerId;
      items.add(
        m.imagePath != null || m.imageUrl != null
            ? ChatImageBubble(message: m, mine: mine)
            : ChatBubble(message: m, mine: mine),
      );
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).extension<AppColors>()!;
    return BlocConsumer<ChatCubit, ChatState>(
      listenWhen: (a, b) => b.error != null && a.error != b.error,
      listener: (context, state) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_errorText(state.error!, l10n))));
        context.read<ChatCubit>().errorShown();
      },
      builder: (context, state) {
        final cubit = context.read<ChatCubit>();
        final other = state.other;
        void openProfile() {
          if (other != null) {
            context.push(AppRoutes.profile(other.id));
          }
        }

        final items = _items(state, l10n).reversed.toList();
        final ready = state.status == ChatStatus.ready;
        return Scaffold(
          backgroundColor: colors.surface100,
          body: Column(
            children: <Widget>[
              ChatHeader(
                other: other,
                onBack: () => context.pop(),
                onProfile: openProfile,
                onOptions: openProfile,
              ),
              Expanded(
                child: state.status == ChatStatus.unavailable
                    ? Padding(
                        padding: const EdgeInsets.all(AppSpacing.space6),
                        child: Center(
                          child: EmptyStateView(
                            icon: AppIcon.chat,
                            title: l10n.chatUnavailableTitle,
                            message: l10n.chatUnavailableMessage,
                          ),
                        ),
                      )
                    : state.status == ChatStatus.loading
                    ? const _ChatSkeleton()
                    : ListView.separated(
                        reverse: true,
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: AppSpacing.gap14,
                          vertical: AppSpacing.space3,
                        ),
                        itemCount: items.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.space2),
                        itemBuilder: (_, i) => items[i],
                      ),
              ),
              if (ready && !state.canSend)
                _ReadOnlyNote(text: l10n.chatReadOnlyMessage)
              else
                MessageComposer(
                  controller: _text,
                  enabled: ready && !state.sending && !state.uploadingPhoto,
                  onSend: _send,
                  onPhoto: () async {
                    final source = await PhotoSourceSheet.show(context);
                    if (source != null) {
                      await cubit.sendPhoto(source);
                    }
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Shown instead of the composer when the two are no longer connected.
class _ReadOnlyNote extends StatelessWidget {
  const _ReadOnlyNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.space4),
        decoration: BoxDecoration(
          color: colors.surface000,
          border: Border(top: BorderSide(color: colors.line)),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: AppTextStyles.helper.copyWith(color: colors.inkMuted),
        ),
      ),
    );
  }
}

/// Placeholder bubbles while a chat loads (no blank screen).
class _ChatSkeleton extends StatelessWidget {
  const _ChatSkeleton();

  static const List<(bool, double)> _bubbles = <(bool, double)>[
    (false, 0.55),
    (true, 0.45),
    (false, 0.7),
    (true, 0.35),
    (false, 0.5),
    (true, 0.6),
  ];

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppLocalizations.of(context).loadingLabel,
      child: ListView.separated(
        reverse: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.gap14,
          vertical: AppSpacing.space3,
        ),
        itemCount: _bubbles.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.space3),
        itemBuilder: (_, i) {
          final (mine, width) = _bubbles[i];
          return Align(
            alignment: mine
                ? AlignmentDirectional.centerEnd
                : AlignmentDirectional.centerStart,
            child: FractionallySizedBox(
              widthFactor: width,
              child: const SkeletonBox(height: 40, radius: AppRadius.lg),
            ),
          );
        },
      ),
    );
  }
}
