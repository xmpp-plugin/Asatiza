import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/failures.dart';
import '../../../data/models/enums/learner_age_group.dart';
import '../../../data/models/enums/learner_level.dart';
import '../../../data/models/enums/subject.dart';
import '../../../data/models/enums/teacher_gender_preference.dart';
import '../../../data/models/enums/teaching_language.dart';
import '../../../data/models/profile.dart';
import '../../../data/models/student_details.dart';
import '../../../data/repositories/profile_repository.dart';
import 'student_setup_state.dart';

/// Student setup (artboards 07e, 07d, 07f). Each step is saved when the
/// user continues or skips.
class StudentSetupCubit extends Cubit<StudentSetupState> {
  StudentSetupCubit(this._profiles, Profile user)
    : super(StudentSetupState(draft: user));

  final ProfileRepository _profiles;

  void _details(StudentDetails Function(StudentDetails d) update) => emit(
    state.copyWith(
      draft: state.draft.copyWith(studentDetails: update(state.details)),
    ),
  );

  List<T> _toggle<T>(List<T> list, T value) => list.contains(value)
      ? (List<T>.of(list)..remove(value))
      : <T>[...list, value];

  // Step 1
  void photoAdded() => emit(
    state.copyWith(
      draft: state.draft.copyWith(
        photoPath: 'avatars/${state.draft.id}/profile.jpg',
      ),
    ),
  );
  void ageGroupChanged(LearnerAgeGroup group) =>
      _details((d) => d.copyWith(ageGroup: group));

  // Step 2
  void goalToggled(Subject s) =>
      _details((d) => d.copyWith(goals: _toggle(d.goals, s)));
  void levelChanged(LearnerLevel level) =>
      _details((d) => d.copyWith(level: level));
  void languageToggled(TeachingLanguage l) => emit(
    state.copyWith(
      draft: state.draft.copyWith(languages: _toggle(state.draft.languages, l)),
    ),
  );

  // Step 3
  void preferenceChanged(TeacherGenderPreference p) =>
      _details((d) => d.copyWith(preferredTeacherGender: p));
  void lookingChanged(bool value) =>
      _details((d) => d.copyWith(lookingForTeacher: value));
  void noteChanged(String value) => _details(
    (d) => d.copyWith(
      note: value.length > StudentSetupState.noteMax
          ? value.substring(0, StudentSetupState.noteMax)
          : value,
    ),
  );

  Future<void> _save() async {
    emit(state.copyWith(saving: true));
    try {
      final saved = await _profiles.updateProfile(state.draft);
      emit(state.copyWith(draft: saved, saving: false));
    } on Failure {
      emit(state.copyWith(saving: false));
    }
  }

  Future<void> next() async {
    await _save();
    if (state.step < StudentSetupState.totalSteps) {
      emit(state.copyWith(step: state.step + 1));
    } else {
      emit(state.copyWith(done: true));
    }
  }

  void back() {
    if (state.step > 1) {
      emit(state.copyWith(step: state.step - 1));
    }
  }

  Future<void> skip() async {
    await _save();
    emit(state.copyWith(done: true));
  }
}
