import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/failures.dart';
import '../../../data/models/enums/fee_unit.dart';
import '../../../data/models/enums/gender.dart';
import '../../../data/models/enums/learner_age_group.dart';
import '../../../data/models/enums/subject.dart';
import '../../../data/models/enums/teaches_audience.dart';
import '../../../data/models/enums/teaching_language.dart';
import '../../../data/models/enums/weekday.dart';
import '../../../data/models/profile.dart';
import '../../../data/models/student_details.dart';
import '../../../data/models/teacher_details.dart';
import '../../../data/repositories/profile_repository.dart';
import 'edit_profile_state.dart';

/// Edits a draft of the user's profile; [save] writes it through
/// [ProfileRepository] (role, verification and id are never changed).
class EditProfileCubit extends Cubit<EditProfileState> {
  EditProfileCubit(this._profiles, Profile profile)
    : super(EditProfileState(draft: profile));

  final ProfileRepository _profiles;

  /// Mock phase: "Change photo" attaches a sample photo path (no picker).
  void photoChanged() =>
      _set(state.draft.copyWith(photoPath: 'avatars/${state.draft.id}.jpg'));

  void _set(Profile draft) =>
      emit(state.copyWith(draft: draft, nameMissing: false));

  TeacherDetails get _t => state.draft.teacherDetails ?? const TeacherDetails();
  StudentDetails get _s => state.draft.studentDetails ?? const StudentDetails();

  void _teacher(TeacherDetails Function(TeacherDetails t) update) =>
      _set(state.draft.copyWith(teacherDetails: update(_t)));

  void _student(StudentDetails Function(StudentDetails s) update) =>
      _set(state.draft.copyWith(studentDetails: update(_s)));

  static List<T> _toggle<T>(List<T> list, T value) => list.contains(value)
      ? (List<T>.of(list)..remove(value))
      : <T>[...list, value];

  void nameChanged(String v) => _set(state.draft.copyWith(fullName: v));
  void headlineChanged(String v) => _set(state.draft.copyWith(headline: v));
  void genderChanged(Gender g) => _set(state.draft.copyWith(gender: g));
  void countryChanged(String c) => _set(state.draft.copyWith(country: c));
  void timeZoneChanged(String tz) => _set(state.draft.copyWith(timeZone: tz));
  void bioChanged(String v) => _set(state.draft.copyWith(bio: v));
  void languageToggled(TeachingLanguage l) =>
      _set(state.draft.copyWith(languages: _toggle(state.draft.languages, l)));

  // Teacher
  void experienceChanged(String v) {
    final years = int.tryParse(v.trim());
    if (years != null) {
      _teacher((t) => t.copyWith(experienceYears: years));
    }
  }

  void qualificationsChanged(String v) =>
      _teacher((t) => t.copyWith(qualifications: v));
  void subjectToggled(Subject s) =>
      _teacher((t) => t.copyWith(subjects: _toggle(t.subjects, s)));
  void feeChanged(String v) {
    final amount = int.tryParse(v.replaceAll(RegExp(r'[^0-9]'), ''));
    if (amount != null) {
      _teacher((t) => t.copyWith(feeAmount: amount));
    }
  }

  void feeUnitChanged(FeeUnit u) => _teacher((t) => t.copyWith(feeUnit: u));
  void dayToggled(Weekday d) => _teacher(
    (t) => t.copyWith(
      availableDays: t.availableDays.contains(d)
          ? (Set<Weekday>.of(t.availableDays)..remove(d))
          : <Weekday>{...t.availableDays, d},
    ),
  );
  void fromChanged(int minutes) =>
      _teacher((t) => t.copyWith(availableFromMinutes: minutes));
  void toChanged(int minutes) =>
      _teacher((t) => t.copyWith(availableToMinutes: minutes));
  void audienceToggled(TeachesAudience a) => _teacher(
    (t) => t.copyWith(
      teaches: t.teaches.contains(a)
          ? (Set<TeachesAudience>.of(t.teaches)..remove(a))
          : <TeachesAudience>{...t.teaches, a},
    ),
  );

  /// Mock phase: adds a sample certificate file (no picker).
  void certificateAdded() => _teacher(
    (t) => t.copyWith(
      certificatePaths: <String>[
        ...t.certificatePaths,
        'certificates/${state.draft.id}/certificate-${t.certificatePaths.length + 1}.pdf',
      ],
    ),
  );

  void certificateRemoved(String path) => _teacher(
    (t) => t.copyWith(
      certificatePaths: List<String>.of(t.certificatePaths)..remove(path),
    ),
  );

  // Student
  void ageGroupChanged(LearnerAgeGroup g) =>
      _student((s) => s.copyWith(ageGroup: g));
  void goalToggled(Subject g) =>
      _student((s) => s.copyWith(goals: _toggle(s.goals, g)));
  void noteChanged(String v) => _student(
    (s) => s.copyWith(
      note: v.length > EditProfileState.noteMax
          ? v.substring(0, EditProfileState.noteMax)
          : v,
    ),
  );

  Future<void> save() async {
    if (state.saving) {
      return;
    }
    if (state.draft.fullName.trim().isEmpty) {
      emit(state.copyWith(nameMissing: true));
      return;
    }
    emit(state.copyWith(saving: true));
    try {
      await _profiles.updateProfile(
        state.draft.copyWith(fullName: state.draft.fullName.trim()),
      );
      emit(state.copyWith(saving: false, saved: true));
    } on Failure {
      emit(state.copyWith(saving: false));
    }
  }
}
