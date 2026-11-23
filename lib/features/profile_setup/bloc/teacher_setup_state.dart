import 'package:equatable/equatable.dart';

import '../../../data/models/profile.dart';
import '../../../data/models/teacher_details.dart';

/// Three-step teacher setup over a draft copy of the user's profile.
class TeacherSetupState extends Equatable {
  const TeacherSetupState({
    required this.draft,
    this.step = 1,
    this.saving = false,
    this.done = false,
  });

  static const int totalSteps = 3;

  /// Max headline length (artboard 07a: "60 characters max").
  static const int headlineMax = 60;

  /// Max bio length (artboard 07c: "142 / 600").
  static const int bioMax = 600;

  /// Longest qualifications text, in characters.
  static const int qualificationsMax = 300;

  final Profile draft;

  /// 1-based.
  final int step;
  final bool saving;

  /// Setup finished or skipped; the screen leaves for Home.
  final bool done;

  TeacherDetails get details => draft.teacherDetails ?? const TeacherDetails();

  TeacherSetupState copyWith({
    Profile? draft,
    int? step,
    bool? saving,
    bool? done,
  }) {
    return TeacherSetupState(
      draft: draft ?? this.draft,
      step: step ?? this.step,
      saving: saving ?? this.saving,
      done: done ?? this.done,
    );
  }

  @override
  List<Object?> get props => <Object?>[draft, step, saving, done];
}
