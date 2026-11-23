import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_checkbox.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/confirm_sheet.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../bloc/delete_account_cubit.dart';
import '../bloc/delete_account_state.dart';

/// 21f Delete account sheet: what is deleted, the "I understand" box and
/// Cancel / Delete account.
class DeleteAccountSheet extends StatelessWidget {
  const DeleteAccountSheet({super.key});

  /// True when the account was deleted.
  static Future<bool> show(BuildContext context, {required String userId}) {
    final auth = context.read<AuthRepository>();
    return AppBottomSheet.show<bool>(
      context,
      builder: (_) => BlocProvider<DeleteAccountCubit>(
        create: (_) => DeleteAccountCubit(auth, userId: userId),
        child: const DeleteAccountSheet(),
      ),
    ).then((deleted) => deleted ?? false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).extension<AppColors>()!;
    return BlocConsumer<DeleteAccountCubit, DeleteAccountState>(
      listenWhen: (a, b) => !a.deleted && b.deleted,
      listener: (context, _) => Navigator.of(context).pop(true),
      builder: (context, state) {
        final cubit = context.read<DeleteAccountCubit>();
        return ConfirmSheet(
          icon: AppIcon.trash,
          danger: true,
          title: l10n.deleteAccountTitle,
          message: l10n.deleteAccountMessage,
          confirmLabel: l10n.deleteAccountAction,
          cancelLabel: l10n.cancelAction,
          onConfirm: state.confirmed && !state.deleting ? cubit.delete : null,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              for (final item in <String>[
                l10n.deleteItemProfile,
                l10n.deleteItemPosts,
                l10n.deleteItemChats,
                l10n.deleteItemConnections,
              ]) ...<Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: AppIcon(
                        AppIcon.close,
                        size: 18,
                        strokeWidth: 2.2,
                        color: colors.danger,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space2),
                    Expanded(
                      child: Text(
                        item,
                        style: AppTextStyles.body.copyWith(color: colors.ink),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.gap6),
              ],
              const SizedBox(height: AppSpacing.space2),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.gap14,
                  vertical: AppSpacing.space3,
                ),
                decoration: BoxDecoration(
                  color: colors.danger100,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: AppCheckbox(
                  value: state.confirmed,
                  onChanged: cubit.confirmedChanged,
                  label: Text(
                    l10n.deleteAccountConfirm,
                    style: AppTextStyles.body.copyWith(color: colors.ink),
                  ),
                ),
              ),
              if (state.failed) ...<Widget>[
                const SizedBox(height: AppSpacing.space2),
                Text(
                  l10n.deleteAccountFailed,
                  style: AppTextStyles.helper.copyWith(color: colors.danger),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
