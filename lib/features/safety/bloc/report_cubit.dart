import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/failures.dart';
import '../../../data/models/enums/report_reason.dart';
import '../../../data/repositories/block_repository.dart';
import '../../../data/repositories/safety_repository.dart';
import 'report_state.dart';

/// Report a post (anonymous), optionally blocking its author.
class ReportCubit extends Cubit<ReportState> {
  ReportCubit(
    this._safety,
    this._blocks, {
    required this.postId,
    required this.authorId,
    required this.reporterId,
  }) : super(const ReportState());

  final SafetyRepository _safety;
  final BlockRepository _blocks;
  final String postId;
  final String authorId;
  final String reporterId;

  void reasonSelected(ReportReason reason) =>
      emit(state.copyWith(reason: reason));
  void alsoBlockChanged(bool value) => emit(state.copyWith(alsoBlock: value));

  Future<void> submit() async {
    final reason = state.reason;
    if (reason == null || !state.canSend) {
      return;
    }
    emit(state.copyWith(status: ReportStatus.sending));
    try {
      await _safety.reportPost(
        postId: postId,
        reporterId: reporterId,
        reason: reason,
      );
      if (state.alsoBlock) {
        await _blocks.blockUser(blockerId: reporterId, blockedId: authorId);
      }
      emit(state.copyWith(status: ReportStatus.sent));
    } on Failure {
      emit(state.copyWith(status: ReportStatus.choosing));
    }
  }
}
