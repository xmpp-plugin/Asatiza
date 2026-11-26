import '../../data/models/enums/user_role.dart';
import '../../data/models/profile.dart';

/// A field every active profile must have (plan section 7, "Required and
/// optional fields"). Photo, certificate, short note and "Looking for a
/// teacher" are optional and never listed here.
enum RequiredField {
  // Both roles
  name,
  gender,
  languages,
  country,
  timeZone,
  // Teacher
  headline,
  subjects,
  bio,
  experience,
  qualifications,
  fee,
  availableDays,
  teaches,
  // Student
  learner,
  goals,
  level,
  preferredTeacherGender,
}

/// Whether a profile is complete (status "active"). Mirrors
/// `private.profile_is_complete` in
/// `supabase/migrations/20261126120000_profile_status.sql` — change both
/// together. The database is the source of truth; the app uses this for
/// mock data, setup "Next" buttons and Edit profile validation.
class ProfileCompletenessRules {
  const ProfileCompletenessRules();

  /// Number of profile-setup steps for each role.
  static const int setupSteps = 3;

  static const List<RequiredField> _teacherFields = <RequiredField>[
    RequiredField.name,
    RequiredField.headline,
    RequiredField.subjects,
    RequiredField.languages,
    RequiredField.gender,
    RequiredField.country,
    RequiredField.timeZone,
    RequiredField.bio,
    RequiredField.experience,
    RequiredField.qualifications,
    RequiredField.fee,
    RequiredField.availableDays,
    RequiredField.teaches,
  ];

  static const List<RequiredField> _studentFields = <RequiredField>[
    RequiredField.name,
    RequiredField.learner,
    RequiredField.goals,
    RequiredField.level,
    RequiredField.languages,
    RequiredField.gender,
    RequiredField.country,
    RequiredField.timeZone,
    RequiredField.preferredTeacherGender,
  ];

  /// True when no required field is missing.
  bool isComplete(Profile profile) => missing(profile).isEmpty;

  /// Required fields still empty, in setup order.
  List<RequiredField> missing(Profile profile) => <RequiredField>[
    for (final field in _fields(profile.role))
      if (!_isFilled(profile, field)) field,
  ];

  /// Required fields of setup step [step] (0-based) that are still empty.
  List<RequiredField> missingInStep(Profile profile, int step) =>
      <RequiredField>[
        for (final field in missing(profile))
          if (stepOf(profile.role, field) == step) field,
      ];

  /// The first setup step (0-based) with a missing required field, or null
  /// when the profile is complete.
  int? firstIncompleteStep(Profile profile) {
    final fields = missing(profile);
    return fields.isEmpty ? null : stepOf(profile.role, fields.first);
  }

  /// The setup step (0-based) that asks [field]. The name comes from
  /// sign-up and counts as step 0.
  int stepOf(UserRole role, RequiredField field) => switch (role) {
    UserRole.teacher => switch (field) {
      RequiredField.name || RequiredField.headline => 0,
      RequiredField.subjects ||
      RequiredField.languages ||
      RequiredField.gender ||
      RequiredField.country ||
      RequiredField.timeZone => 1,
      _ => 2,
    },
    UserRole.student => switch (field) {
      RequiredField.name || RequiredField.learner => 0,
      RequiredField.goals ||
      RequiredField.level ||
      RequiredField.languages ||
      RequiredField.gender ||
      RequiredField.country ||
      RequiredField.timeZone => 1,
      _ => 2,
    },
  };

  List<RequiredField> _fields(UserRole role) =>
      role == UserRole.teacher ? _teacherFields : _studentFields;

  bool _isFilled(Profile p, RequiredField field) {
    final t = p.teacherDetails;
    final s = p.studentDetails;
    bool has(String? v) => v != null && v.trim().isNotEmpty;
    return switch (field) {
      RequiredField.name => has(p.fullName),
      RequiredField.gender => p.gender != null,
      RequiredField.languages => p.languages.isNotEmpty,
      RequiredField.country => has(p.country),
      RequiredField.timeZone => has(p.timeZone),
      RequiredField.headline => has(p.headline),
      RequiredField.subjects => (t?.subjects ?? const []).isNotEmpty,
      RequiredField.bio => has(p.bio),
      RequiredField.experience => t?.experienceYears != null,
      RequiredField.qualifications => has(t?.qualifications),
      RequiredField.fee => t?.feeAmount != null,
      RequiredField.availableDays => (t?.availableDays ?? const {}).isNotEmpty,
      RequiredField.teaches => (t?.teaches ?? const {}).isNotEmpty,
      RequiredField.learner => s?.ageGroup != null,
      RequiredField.goals => (s?.goals ?? const []).isNotEmpty,
      RequiredField.level => s?.level != null,
      RequiredField.preferredTeacherGender => s?.preferredTeacherGender != null,
    };
  }
}
