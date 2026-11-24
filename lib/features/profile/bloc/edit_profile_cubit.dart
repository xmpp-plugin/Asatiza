import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/failures.dart';
import '../../../core/logic/certificate_file_rules.dart';
import '../../../core/services/document_picker_service.dart';
import '../../../core/services/image_compressor.dart';
import '../../../core/services/image_picker_service.dart';
import '../../../core/services/image_source_kind.dart';
import '../../../data/models/enums/media_bucket.dart';
import '../../../data/repositories/media_repository.dart';
import '../../../data/models/enums/fee_unit.dart';
import '../../../data/models/enums/gender.dart';
import '../../../data/models/enums/learner_age_group.dart';
import '../../../data/models/enums/learner_level.dart';
import '../../../data/models/enums/subject.dart';
import '../../../data/models/enums/teacher_gender_preference.dart';
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
  EditProfileCubit(
    this._profiles,
    Profile profile, {
    required MediaRepository media,
    required ImagePickerService picker,
    required ImageCompressor compressor,
    required DocumentPickerService documents,
  }) : _media = media,
       _picker = picker,
       _compressor = compressor,
       _documents = documents,
       _savedMedia = _mediaOf(profile),
       super(EditProfileState(draft: profile));

  final ProfileRepository _profiles;
  final MediaRepository _media;
  final ImagePickerService _picker;
  final ImageCompressor _compressor;
  final DocumentPickerService _documents;

  // Decision 3: files upload when picked and are saved with the profile.
  // After a successful save, files no longer referenced are deleted; files
  // uploaded but never saved are deleted when the screen closes.

  /// Media referenced by the last saved profile.
  Map<String, MediaBucket> _savedMedia;

  /// Uploaded since the last save.
  final Map<String, MediaBucket> _uploaded = <String, MediaBucket>{};

  static Map<String, MediaBucket> _mediaOf(Profile p) => <String, MediaBucket>{
    if (p.photoPath != null) p.photoPath!: MediaBucket.avatars,
    for (final c in p.teacherDetails?.certificatePaths ?? const <String>[])
      c: MediaBucket.certificates,
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

  static const CertificateFileRules _certificateRules = CertificateFileRules();

  /// Chooses a PDF (decision 2: one, up to 3 MB), checks it, uploads it and
  /// adds its path to the draft (saved with the profile).
  Future<void> certificatePicked() async {
    if (state.uploadingCertificate) {
      return;
    }
    emit(state.copyWith(clearMediaError: true));
    final existing = _certificates.length;
    if (!_certificateRules.canAdd(existing)) {
      emit(
        state.copyWith(mediaError: ValidationReason.certificateLimitReached),
      );
      return;
    }
    try {
      final document = await _documents.pickPdf(
        maxReadBytes: CertificateFileRules.maxBytes,
      );
      if (document == null || isClosed) {
        return;
      }
      final refused = _certificateRules.check(
        sizeBytes: document.sizeBytes,
        bytes: document.bytes,
        existingCount: existing,
      );
      if (refused != null) {
        emit(state.copyWith(mediaError: refused));
        return;
      }
      emit(state.copyWith(uploadingCertificate: true));
      final path = await _media.uploadCertificate(
        state.draft.id,
        document.bytes,
        document.name,
      );
      if (isClosed) {
        unawaited(
          _deleteQuietly(<String, MediaBucket>{path: MediaBucket.certificates}),
        );
        return;
      }
      _uploaded[path] = MediaBucket.certificates;
      emit(state.copyWith(uploadingCertificate: false));
      _addCertificate(path);
    } on Failure catch (failure) {
      if (!isClosed) {
        emit(
          state.copyWith(
            uploadingCertificate: false,
            mediaError: failure.displayReason,
          ),
        );
      }
    }
  }

  List<String> get _certificates => _t.certificatePaths;

  void _addCertificate(String path) => _teacher(
    (t) => t.copyWith(certificatePaths: <String>[...t.certificatePaths, path]),
  );

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

  /// Removes a certificate from the draft; the file is deleted after a
  /// successful save.
  void certificateRemoved(String path) => _teacher(
    (t) => t.copyWith(
      certificatePaths: List<String>.of(t.certificatePaths)..remove(path),
    ),
  );

  // Student
  void ageGroupChanged(LearnerAgeGroup g) =>
      _student((s) => s.copyWith(ageGroup: g));

  /// Level and preferred teacher gender were only set in student setup;
  /// Edit profile now offers them too (PHASE_005 fix), together with the
  /// shared [languageToggled].
  void levelChanged(LearnerLevel level) =>
      _student((s) => s.copyWith(level: level));
  void preferenceChanged(TeacherGenderPreference p) =>
      _student((s) => s.copyWith(preferredTeacherGender: p));
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
      // Bookkeeping runs now; `saved` is emitted before the deletions are
      // awaited so the screen closes at once (the files go in background).
      final cleanup = _cleanUpAfterSave();
      emit(state.copyWith(saving: false, saved: true));
      await cleanup;
    } on Failure {
      emit(state.copyWith(saving: false));
    }
  }
}
