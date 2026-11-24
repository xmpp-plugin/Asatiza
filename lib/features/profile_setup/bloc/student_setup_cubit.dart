import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/failures.dart';
import '../../../core/services/image_compressor.dart';
import '../../../core/services/image_picker_service.dart';
import '../../../core/services/image_source_kind.dart';
import '../../../data/models/enums/media_bucket.dart';
import '../../../data/repositories/media_repository.dart';
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
  StudentSetupCubit(
    this._profiles,
    Profile user, {
    required MediaRepository media,
    required ImagePickerService picker,
    required ImageCompressor compressor,
  }) : _media = media,
       _picker = picker,
       _compressor = compressor,
       _savedMedia = _mediaOf(user),
       super(StudentSetupState(draft: user));

  final ProfileRepository _profiles;
  final MediaRepository _media;
  final ImagePickerService _picker;
  final ImageCompressor _compressor;

  // Decision 3: files upload when picked and are saved with the profile.
  // After a successful save, files no longer referenced are deleted; files
  // uploaded but never saved are deleted when the screen closes.

  /// Media referenced by the last saved profile.
  Map<String, MediaBucket> _savedMedia;

  /// Uploaded since the last save.
  final Map<String, MediaBucket> _uploaded = <String, MediaBucket>{};

  static Map<String, MediaBucket> _mediaOf(Profile p) => <String, MediaBucket>{
    if (p.photoPath != null) p.photoPath!: MediaBucket.avatars,
  };

  Future<void> _cleanUpAfterSave() {
    final current = _mediaOf(state.draft);
    final stale = <String, MediaBucket>{..._savedMedia, ..._uploaded}
      ..removeWhere((path, _) => current.containsKey(path));
    _savedMedia = current;
    _uploaded.clear();
    return _deleteQuietly(stale);
  }

  /// Best effort: a file that cannot be removed stays as an orphan
  /// (recorded limitation), the user's flow is never blocked by it.
  Future<void> _deleteQuietly(Map<String, MediaBucket> files) async {
    for (final bucket in MediaBucket.values) {
      final paths = <String>[
        for (final entry in files.entries)
          if (entry.value == bucket) entry.key,
      ];
      if (paths.isEmpty) {
        continue;
      }
      try {
        await _media.deleteFiles(bucket, paths);
      } on Failure {
        // Left in Storage; see the phase's known limitations.
      }
    }
  }

  /// Takes or chooses a photo, compresses and uploads it, and puts its path
  /// in the draft (saved with the profile).
  Future<void> photoPicked(ImageSourceKind source) async {
    if (state.uploadingPhoto) {
      return;
    }
    emit(state.copyWith(clearMediaError: true));
    try {
      final picked = await _picker.pickImage(source);
      if (picked == null || isClosed) {
        return;
      }
      emit(state.copyWith(uploadingPhoto: true));
      final jpeg = await _compressor.compressAvatar(picked);
      final path = await _media.uploadAvatar(state.draft.id, jpeg);
      if (isClosed) {
        unawaited(
          _deleteQuietly(<String, MediaBucket>{path: MediaBucket.avatars}),
        );
        return;
      }
      _uploaded[path] = MediaBucket.avatars;
      emit(
        state.copyWith(
          draft: state.draft.copyWith(photoPath: path),
          photoPreview: jpeg,
          uploadingPhoto: false,
        ),
      );
    } on Failure catch (failure) {
      if (!isClosed) {
        emit(
          state.copyWith(
            uploadingPhoto: false,
            mediaError: failure.displayReason,
          ),
        );
      }
    }
  }

  @override
  Future<void> close() {
    final unsaved = Map<String, MediaBucket>.of(_uploaded)
      ..removeWhere((path, _) => _savedMedia.containsKey(path));
    if (unsaved.isNotEmpty) {
      unawaited(_deleteQuietly(unsaved));
    }
    return super.close();
  }

  void _details(StudentDetails Function(StudentDetails d) update) => emit(
    state.copyWith(
      draft: state.draft.copyWith(studentDetails: update(state.details)),
    ),
  );

  List<T> _toggle<T>(List<T> list, T value) => list.contains(value)
      ? (List<T>.of(list)..remove(value))
      : <T>[...list, value];

  // Step 1
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
      await _cleanUpAfterSave();
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
