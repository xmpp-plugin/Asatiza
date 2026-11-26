import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/failures.dart';
import '../../../core/logic/certificate_file_rules.dart';
import '../../../core/logic/profile_completeness_rules.dart';
import '../../../core/services/document_picker_service.dart';
import '../../../core/services/image_compressor.dart';
import '../../../core/services/image_picker_service.dart';
import '../../../core/services/image_source_kind.dart';
import '../../../data/models/enums/media_bucket.dart';
import '../../../data/repositories/media_repository.dart';
import '../../../data/models/enums/fee_unit.dart';
import '../../../data/models/enums/gender.dart';
import '../../../data/models/enums/subject.dart';
import '../../../data/models/enums/teaches_audience.dart';
import '../../../data/models/enums/teaching_language.dart';
import '../../../data/models/enums/weekday.dart';
import '../../../data/models/profile.dart';
import '../../../data/models/teacher_details.dart';
import '../../../data/repositories/profile_repository.dart';
import 'teacher_setup_state.dart';

/// Teacher setup (artboards 07a–07c). No Skip: "Continue" needs the step's
/// required fields ([ProfileCompletenessRules]); every step is saved when
/// the user continues. Opens at the first step with a missing required
/// field, so an unfinished setup resumes where it stopped.
class TeacherSetupCubit extends Cubit<TeacherSetupState> {
  TeacherSetupCubit(
    this._profiles,
    Profile user, {
    required MediaRepository media,
    required ImagePickerService picker,
    required ImageCompressor compressor,
    required DocumentPickerService documents,
  }) : _media = media,
       _picker = picker,
       _compressor = compressor,
       _documents = documents,
       _savedMedia = _mediaOf(user),
       super(TeacherSetupState(draft: user, step: _startStep(user)));

  static const ProfileCompletenessRules _rules = ProfileCompletenessRules();

  static int _startStep(Profile user) =>
      (_rules.firstIncompleteStep(user) ?? 0) + 1;

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

  List<String> get _certificates => state.details.certificatePaths;

  void _addCertificate(String path) => _details(
    (d) => d.copyWith(certificatePaths: <String>[...d.certificatePaths, path]),
  );

  /// Removes a certificate from the draft; the file is deleted after the
  /// next successful save.
  void certificateRemoved(String path) => _details(
    (d) => d.copyWith(
      certificatePaths: List<String>.of(d.certificatePaths)..remove(path),
    ),
  );

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

  void qualificationsChanged(String value) =>
      _details((d) => d.copyWith(qualifications: value));

  void feeChanged(String value) {
    final amount = int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), ''));
    if (amount != null) {
      _details((d) => d.copyWith(feeAmount: amount));
    }
  }

  void audienceToggled(TeachesAudience a) => _details((d) {
    final teaches = Set<TeachesAudience>.of(d.teaches);
    if (!teaches.remove(a)) {
      teaches.add(a);
    }
    return d.copyWith(teaches: teaches);
  });

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

  /// Saves the draft; false when the save failed (the user stays on the
  /// step and can try again).
  Future<bool> _save() async {
    emit(state.copyWith(saving: true));
    try {
      final saved = await _profiles.updateProfile(state.draft);
      emit(state.copyWith(draft: saved, saving: false));
      await _cleanUpAfterSave();
      return true;
    } on Failure {
      emit(state.copyWith(saving: false));
      return false;
    }
  }

  /// Saves and moves on. After the last step the profile must be active
  /// (set by the database); otherwise setup goes to the first step that is
  /// still missing something.
  Future<void> next() async {
    if (state.saving || !state.stepComplete || !await _save()) {
      return;
    }
    if (state.step < TeacherSetupState.totalSteps) {
      emit(state.copyWith(step: state.step + 1));
    } else if (state.draft.isActive) {
      emit(state.copyWith(done: true));
    } else {
      emit(state.copyWith(step: _startStep(state.draft)));
    }
  }

  void back() {
    if (state.step > 1) {
      emit(state.copyWith(step: state.step - 1));
    }
  }
}
