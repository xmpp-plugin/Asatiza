import 'package:equatable/equatable.dart';

/// 21f Delete account sheet.
class DeleteAccountState extends Equatable {
  const DeleteAccountState({
    this.confirmed = false,
    this.deleting = false,
    this.deleted = false,
    this.failed = false,
  });

  /// "I understand…" is ticked.
  final bool confirmed;
  final bool deleting;
  final bool deleted;
  final bool failed;

  DeleteAccountState copyWith({
    bool? confirmed,
    bool? deleting,
    bool? deleted,
    bool? failed,
  }) {
    return DeleteAccountState(
      confirmed: confirmed ?? this.confirmed,
      deleting: deleting ?? this.deleting,
      deleted: deleted ?? this.deleted,
      failed: failed ?? this.failed,
    );
  }

  @override
  List<Object?> get props => <Object?>[confirmed, deleting, deleted, failed];
}
