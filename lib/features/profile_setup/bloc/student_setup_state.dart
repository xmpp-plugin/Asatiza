import 'package:equatable/equatable.dart';

import '../../../data/models/profile.dart';
import '../../../data/models/student_details.dart';

/// Three-step student setup over a draft copy of the user's profile.
class StudentSetupState extends Equatable {
  const StudentSetupState({
    required this.draft,
    this.step = 1,
    this.saving = false,
    this.done = false,
  });

  static const int totalSteps = 3;

  /// Short note limit (artboard 07f: "0 / 200").
  static const int noteMax = 200;

  final Profile draft;

  /// 1-based.
  final int step;
  final bool saving;
  final bool done;

  StudentDetails get details => draft.studentDetails ?? const StudentDetails();

  StudentSetupState copyWith({
    Profile? draft,
    int? step,
    bool? saving,
    bool? done,
  }) {
    return StudentSetupState(
      draft: draft ?? this.draft,
      step: step ?? this.step,
      saving: saving ?? this.saving,
      done: done ?? this.done,
    );
  }

  @override
  List<Object?> get props => <Object?>[draft, step, saving, done];
}
