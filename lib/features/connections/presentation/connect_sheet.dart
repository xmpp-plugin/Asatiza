import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/failures.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_text_area.dart';
import '../../../data/models/profile.dart';
import '../../../data/repositories/connection_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../bloc/connect_request_cubit.dart';
import '../bloc/connect_request_state.dart';
import '../logic/connect_note_rules.dart';

/// 15 Connect sheet: who you are connecting with, an optional note
/// (200 characters) and Send request / Cancel.
class ConnectSheet extends StatefulWidget {
  const ConnectSheet({required this.target, super.key});

  final Profile target;

  /// Opens the sheet; true when the request was sent (a snack bar confirms).
  static Future<bool> show(
    BuildContext context, {
    required Profile target,
    required String requesterId,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final repository = context.read<ConnectionRepository>();
    final sent = await AppBottomSheet.show<bool>(
      context,
      builder: (_) => BlocProvider<ConnectRequestCubit>(
        create: (_) => ConnectRequestCubit(
          repository,
          requesterId: requesterId,
          receiverId: target.id,
        ),
        child: ConnectSheet(target: target),
      ),
    );
    if (sent ?? false) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.requestSentMessage(target.fullName))),
      );
    }
    return sent ?? false;
  }

  /// "Qari Ahmed Khan" → "Qari Ahmed": the name without the family name
  /// when it has three or more words.
  static String shortName(String fullName) {
    final words = fullName.split(RegExp(r'\s+'));
    return words.length > 2 ? words.take(2).join(' ') : fullName;
  }

  @override
  State<ConnectSheet> createState() => _ConnectSheetState();
}

class _ConnectSheetState extends State<ConnectSheet> {
  final TextEditingController _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  String? _error(ValidationReason? reason, AppLocalizations l10n) =>
      switch (reason) {
        ValidationReason.connectNoteTooLong => l10n.connectNoteTooLongError,
        ValidationReason.profileIncomplete =>
          l10n.connectProfileIncompleteError,
        ValidationReason.alreadyConnected => l10n.connectAlreadyError,
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).extension<AppColors>()!;
    final target = widget.target;
    return BlocConsumer<ConnectRequestCubit, ConnectRequestState>(
      listenWhen: (a, b) => !a.sent && b.sent,
      listener: (context, _) => Navigator.of(context).pop(true),
      builder: (context, state) {
        final cubit = context.read<ConnectRequestCubit>();
        final error = _error(state.error, l10n);
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                AppAvatar(profile: target, size: 48, showVerified: true),
                const SizedBox(width: AppSpacing.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Semantics(
                        header: true,
                        child: Text(
                          l10n.connectWithTitle(
                            ConnectSheet.shortName(target.fullName),
                          ),
                          style: AppTextStyles.pageTitle.copyWith(
                            color: colors.ink,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.gap2),
                      Text(
                        l10n.connectSheetSubtitle(
                          target.gender?.name ?? 'other',
                        ),
                        style: AppTextStyles.helper.copyWith(
                          color: colors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space4),
            AppTextArea(
              label: l10n.addNoteLabel,
              controller: _note,
              maxLength: ConnectNoteRules.maxLength,
              height: 104,
              placeholder: l10n.connectNotePlaceholder,
              onChanged: cubit.noteChanged,
            ),
            if (error != null) ...<Widget>[
              const SizedBox(height: AppSpacing.space2),
              Text(
                error,
                style: AppTextStyles.helper.copyWith(color: colors.danger),
              ),
            ],
            const SizedBox(height: AppSpacing.space4),
            AppButton(
              label: l10n.sendRequestAction,
              onPressed: state.sending ? null : cubit.send,
              leading: AppIcon(
                AppIcon.send,
                size: 18,
                color: state.sending ? colors.inkMuted : colors.onBrand,
              ),
            ),
            const SizedBox(height: AppSpacing.space2),
            SizedBox(
              height: 48,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: TextButton.styleFrom(
                  foregroundColor: colors.brand700,
                  textStyle: AppTextStyles.label,
                ),
                child: Text(l10n.cancelAction),
              ),
            ),
          ],
        );
      },
    );
  }
}
