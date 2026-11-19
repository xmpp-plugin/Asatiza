import 'package:equatable/equatable.dart';

import '../../../data/models/enums/report_reason.dart';

enum ReportStatus { choosing, sending, sent }

class ReportState extends Equatable {
  const ReportState({
    this.reason,
    this.alsoBlock = false,
    this.status = ReportStatus.choosing,
  });

  final ReportReason? reason;

  /// "Also block" + author name.
  final bool alsoBlock;
  final ReportStatus status;

  bool get canSend => reason != null && status == ReportStatus.choosing;

  ReportState copyWith({
    ReportReason? reason,
    bool? alsoBlock,
    ReportStatus? status,
  }) {
    return ReportState(
      reason: reason ?? this.reason,
      alsoBlock: alsoBlock ?? this.alsoBlock,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => <Object?>[reason, alsoBlock, status];
}
