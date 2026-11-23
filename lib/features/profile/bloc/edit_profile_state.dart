import 'package:equatable/equatable.dart';

import '../../../data/models/profile.dart';

/// 20b / 20d Edit profile: a draft copy saved on "Save".
class EditProfileState extends Equatable {
  const EditProfileState({
    required this.draft,
    this.saving = false,
    this.saved = false,
    this.nameMissing = false,
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

  EditProfileState copyWith({
    Profile? draft,
    bool? saving,
    bool? saved,
    bool? nameMissing,
  }) {
    return EditProfileState(
      draft: draft ?? this.draft,
      saving: saving ?? this.saving,
      saved: saved ?? this.saved,
      nameMissing: nameMissing ?? this.nameMissing,
    );
  }

  @override
  List<Object?> get props => <Object?>[draft, saving, saved, nameMissing];
}
