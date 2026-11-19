import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/failures.dart';
import '../../../data/models/enums/fee_unit.dart';
import '../../../data/models/enums/gender.dart';
import '../../../data/models/enums/subject.dart';
import '../../../data/models/enums/teaching_language.dart';
import '../../../data/models/enums/weekday.dart';
import '../../../data/models/profile.dart';
import '../../../data/models/teacher_details.dart';
import '../../../data/repositories/profile_repository.dart';
import 'teacher_setup_state.dart';

/// Teacher setup (artboards 07a–07c). Every step is saved when the user
/// continues or skips, so the strength % reflects it immediately.
class TeacherSetupCubit extends Cubit<TeacherSetupState> {
  TeacherSetupCubit(this._profiles, Profile user)
    : super(TeacherSetupState(draft: user));

  final ProfileRepository _profiles;

  /// Default evening slot shown with the day picker (17:00–21:00).
  static const int defaultFrom = 17 * 60;
  static const int defaultTo = 21 * 60;

  void _details(TeacherDetails Function(TeacherDetails d) update) => emit(
    state.copyWith(
      draft: state.draft.copyWith(teacherDetails: update(state.details)),
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
  void headlineChanged(String value) {
    final text = value.length > TeacherSetupState.headlineMax
        ? value.substring(0, TeacherSetupState.headlineMax)
        : value;
    emit(state.copyWith(draft: state.draft.copyWith(headline: text)));
  }

  // Step 2
  void subjectToggled(Subject s) =>
      _details((d) => d.copyWith(subjects: _toggle(d.subjects, s)));
  void languageToggled(TeachingLanguage l) => emit(
    state.copyWith(
      draft: state.draft.copyWith(languages: _toggle(state.draft.languages, l)),
    ),
  );
  void genderChanged(Gender g) =>
      emit(state.copyWith(draft: state.draft.copyWith(gender: g)));
  void countryChanged(String c) =>
      emit(state.copyWith(draft: state.draft.copyWith(country: c)));
  void timeZoneChanged(String tz) =>
      emit(state.copyWith(draft: state.draft.copyWith(timeZone: tz)));

  // Step 3
  void bioChanged(String value) =>
      emit(state.copyWith(draft: state.draft.copyWith(bio: value)));
  void experienceChanged(String value) {
    final years = int.tryParse(value.trim());
    if (years != null) {
      _details((d) => d.copyWith(experienceYears: years));
    }
  }

  void feeChanged(String value) {
    final amount = int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), ''));
    if (amount != null) {
      _details((d) => d.copyWith(feeAmount: amount));
    }
  }

  void feeUnitChanged(FeeUnit unit) =>
      _details((d) => d.copyWith(feeUnit: unit));
  void dayToggled(Weekday day) => _details((d) {
    final days = Set<Weekday>.of(d.availableDays);
    if (!days.remove(day)) {
      days.add(day);
    }
    return d.copyWith(
      availableDays: days,
      availableFromMinutes: d.availableFromMinutes ?? defaultFrom,
      availableToMinutes: d.availableToMinutes ?? defaultTo,
    );
  });

  void certificateAdded() => _details(
    (d) => d.copyWith(
      certificatePaths: <String>[
        ...d.certificatePaths,
        'certificates/${state.draft.id}/certificate-${d.certificatePaths.length + 1}.pdf',
      ],
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
    if (state.step < TeacherSetupState.totalSteps) {
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
