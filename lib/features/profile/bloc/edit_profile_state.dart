import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../../core/logic/profile_completeness_rules.dart';

import '../../../data/models/profile.dart';

/// 20b / 20d Edit profile: a draft copy saved on "Save".
class EditProfileState extends Equatable {
  const EditProfileState({
    required this.draft,
    this.saving = false,
    this.saved = false,
    this.nameMissing = false,
    this.uploadingPhoto = false,
    this.photoPreview,
    this.mediaError,
    this.uploadingCertificate = false,
  });

  /// Longest bio, short note and qualifications, in characters.
  static const int bioMax = 600;
  static const int noteMax = 200;
  static const int qualificationsMax = 300;

  final Profile draft;
  final bool saving;
  final bool saved;

  /// Save was tapped with an empty name.
  final bool nameMissing;

  /// A photo is being compressed and uploaded.
  final bool uploadingPhoto;

  /// The just-uploaded photo (not saved yet), shown in the avatar.
  final Uint8List? photoPreview;

  /// Why the last photo / certificate upload failed or was refused; null
  /// when there is nothing to show.
  final ValidationReason? mediaError;

  /// A certificate is being uploaded.
  final bool uploadingCertificate;

  /// Required fields that are empty (the name keeps its own error). Save is
  /// disabled while this is not empty, so a profile never loses its active
  /// status by editing.
  List<RequiredField> get missingFields => <RequiredField>[
    for (final f in const ProfileCompletenessRules().missing(draft))
      if (f != RequiredField.name) f,
  ];

  bool get canSave => !saving && missingFields.isEmpty;

  EditProfileState copyWith({
    Profile? draft,
    bool? saving,
    bool? saved,
    bool? nameMissing,
    bool? uploadingPhoto,
    Uint8List? photoPreview,
    ValidationReason? mediaError,
    bool clearMediaError = false,
    bool? uploadingCertificate,
  }) {
    return EditProfileState(
      draft: draft ?? this.draft,
      saving: saving ?? this.saving,
      saved: saved ?? this.saved,
      nameMissing: nameMissing ?? this.nameMissing,
      uploadingPhoto: uploadingPhoto ?? this.uploadingPhoto,
      photoPreview: photoPreview ?? this.photoPreview,
      mediaError: clearMediaError ? null : (mediaError ?? this.mediaError),
      uploadingCertificate: uploadingCertificate ?? this.uploadingCertificate,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    draft,
    saving,
    saved,
    nameMissing,
    uploadingPhoto,
    photoPreview,
    mediaError,
    uploadingCertificate,
  ];
}
