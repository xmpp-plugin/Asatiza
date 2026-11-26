import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../../core/logic/profile_completeness_rules.dart';
import '../../../data/models/profile.dart';
import '../../../data/models/student_details.dart';

/// Three-step student setup over a draft copy of the user's profile.
class StudentSetupState extends Equatable {
  const StudentSetupState({
    required this.draft,
    this.step = 1,
    this.saving = false,
    this.done = false,
    this.uploadingPhoto = false,
    this.photoPreview,
    this.mediaError,
  });

  static const int totalSteps = 3;

  /// Short note limit (artboard 07f: "0 / 200").
  static const int noteMax = 200;

  final Profile draft;

  /// 1-based.
  final int step;
  final bool saving;
  final bool done;

  /// A photo is being compressed and uploaded.
  final bool uploadingPhoto;

  /// The just-uploaded photo (not saved yet), shown in the avatar.
  final Uint8List? photoPreview;

  /// Why the last photo / certificate upload failed or was refused; null
  /// when there is nothing to show.
  final ValidationReason? mediaError;

  StudentDetails get details => draft.studentDetails ?? const StudentDetails();

  /// Every required field of the current step is filled ("Continue" is
  /// enabled). Photo, short note and "Looking for a teacher" are optional.
  bool get stepComplete =>
      const ProfileCompletenessRules().missingInStep(draft, step - 1).isEmpty;

  StudentSetupState copyWith({
    Profile? draft,
    int? step,
    bool? saving,
    bool? done,
    bool? uploadingPhoto,
    Uint8List? photoPreview,
    ValidationReason? mediaError,
    bool clearMediaError = false,
  }) {
    return StudentSetupState(
      draft: draft ?? this.draft,
      step: step ?? this.step,
      saving: saving ?? this.saving,
      done: done ?? this.done,
      uploadingPhoto: uploadingPhoto ?? this.uploadingPhoto,
      photoPreview: photoPreview ?? this.photoPreview,
      mediaError: clearMediaError ? null : (mediaError ?? this.mediaError),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    draft,
    step,
    saving,
    done,
    uploadingPhoto,
    photoPreview,
    mediaError,
  ];
}
