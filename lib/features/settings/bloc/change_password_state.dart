import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';

/// 21a Change password: fields, live rules and the save result.
class ChangePasswordState extends Equatable {
  const ChangePasswordState({
    this.current = '',
    this.next = '',
    this.confirmation = '',
    this.saving = false,
    this.saved = false,
    this.error,
  });

  final String current;
  final String next;
  final String confirmation;
  final bool saving;
  final bool saved;
  final ValidationReason? error;

  ChangePasswordState copyWith({
    String? current,
    String? next,
    String? confirmation,
    bool? saving,
    bool? saved,
    ValidationReason? Function()? error,
  }) {
    return ChangePasswordState(
      current: current ?? this.current,
      next: next ?? this.next,
      confirmation: confirmation ?? this.confirmation,
      saving: saving ?? this.saving,
      saved: saved ?? this.saved,
      error: error != null ? error() : this.error,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    current,
    next,
    confirmation,
    saving,
    saved,
    error,
  ];
}
