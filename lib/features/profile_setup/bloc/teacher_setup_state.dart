import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../../core/logic/profile_completeness_rules.dart';
import '../../../data/models/profile.dart';
import '../../../data/models/teacher_details.dart';

/// Three-step teacher setup over a draft copy of the user's profile.
class TeacherSetupState extends Equatable {
  const TeacherSetupState({
    required this.draft,
    this.step = 1,
    this.saving = false,
    this.done = false,
    this.uploadingPhoto = false,
    this.photoPreview,
    this.mediaError,
    this.uploadingCertificate = false,
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

  /// Setup saved and the profile is active; the screen leaves for Home.
  final bool done;

  /// A photo is being compressed and uploaded.
  final bool uploadingPhoto;

  /// The just-uploaded photo (not saved yet), shown in the avatar.
  final Uint8List? photoPreview;

  /// Why the last photo / certificate upload failed or was refused; null
  /// when there is nothing to show.
  final ValidationReason? mediaError;

  /// A certificate is being uploaded.
  final bool uploadingCertificate;

  TeacherDetails get details => draft.teacherDetails ?? const TeacherDetails();

  /// Every required field of the current step is filled ("Continue" is
  /// enabled). Photo and certificate are optional.
  bool get stepComplete =>
      const ProfileCompletenessRules().missingInStep(draft, step - 1).isEmpty;

  TeacherSetupState copyWith({
    Profile? draft,
    int? step,
    bool? saving,
    bool? done,
    bool? uploadingPhoto,
    Uint8List? photoPreview,
    ValidationReason? mediaError,
    bool clearMediaError = false,
    bool? uploadingCertificate,
  }) {
    return TeacherSetupState(
      draft: draft ?? this.draft,
      step: step ?? this.step,
      saving: saving ?? this.saving,
      done: done ?? this.done,
      uploadingPhoto: uploadingPhoto ?? this.uploadingPhoto,
      photoPreview: photoPreview ?? this.photoPreview,
      mediaError: clearMediaError ? null : (mediaError ?? this.mediaError),
      uploadingCertificate: uploadingCertificate ?? this.uploadingCertificate,
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
    uploadingCertificate,
  ];
}
