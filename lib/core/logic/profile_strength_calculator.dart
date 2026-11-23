import '../../data/models/enums/user_role.dart';
import '../../data/models/profile.dart';

/// Checklist items behind the profile-strength %, in the order the
/// strength card suggests them.
enum ProfileStrengthItem {
  // Teacher
  photo,
  headline,
  subjects,
  teachingLanguages,
  bio,
  experience,
  feeAndAvailability,
  certificate,
  // Student
  learningGoals,
  ageGroup,
  level,
  studentLanguages,
  location,
  preferredTeacherGender,
  photoOrNote,
}

/// Profile strength % per plan section 7 (shared by profile setup, my
/// profile and the Home strength card).
class ProfileStrengthCalculator {
  const ProfileStrengthCalculator();

  static const Map<ProfileStrengthItem, int> teacherWeights =
      <ProfileStrengthItem, int>{
        ProfileStrengthItem.photo: 15,
        ProfileStrengthItem.headline: 10,
        ProfileStrengthItem.subjects: 15,
        ProfileStrengthItem.teachingLanguages: 10,
        ProfileStrengthItem.bio: 15,
        ProfileStrengthItem.experience: 10,
        ProfileStrengthItem.feeAndAvailability: 15,
        ProfileStrengthItem.certificate: 10,
      };

  static const Map<ProfileStrengthItem, int> studentWeights =
      <ProfileStrengthItem, int>{
        ProfileStrengthItem.learningGoals: 25,
        ProfileStrengthItem.ageGroup: 15,
        ProfileStrengthItem.level: 15,
        ProfileStrengthItem.studentLanguages: 15,
        ProfileStrengthItem.location: 10,
        ProfileStrengthItem.preferredTeacherGender: 10,
        ProfileStrengthItem.photoOrNote: 10,
      };

  /// Completion from 0 to 100.
  int percent(Profile profile) {
    final weights = _weights(profile);
    return weights.entries
        .where((e) => _isDone(profile, e.key))
        .fold(0, (sum, e) => sum + e.value);
  }

  /// Items still missing, in suggestion order.
  List<ProfileStrengthItem> missing(Profile profile) =>
      _weights(profile).keys.where((item) => !_isDone(profile, item)).toList();

  Map<ProfileStrengthItem, int> _weights(Profile profile) =>
      profile.role == UserRole.teacher ? teacherWeights : studentWeights;

  bool _isDone(Profile p, ProfileStrengthItem item) {
    final t = p.teacherDetails;
    final s = p.studentDetails;
    bool has(String? v) => v != null && v.trim().isNotEmpty;
    return switch (item) {
      ProfileStrengthItem.photo => has(p.photoPath),
      ProfileStrengthItem.headline => has(p.headline),
      ProfileStrengthItem.subjects => (t?.subjects ?? const []).isNotEmpty,
      ProfileStrengthItem.teachingLanguages ||
      ProfileStrengthItem.studentLanguages => p.languages.isNotEmpty,
      ProfileStrengthItem.bio => has(p.bio),
      ProfileStrengthItem.experience =>
        t?.experienceYears != null && has(t?.qualifications),
      ProfileStrengthItem.feeAndAvailability =>
        t?.feeAmount != null && (t?.availableDays ?? const {}).isNotEmpty,
      ProfileStrengthItem.certificate =>
        (t?.certificatePaths ?? const []).isNotEmpty,
      ProfileStrengthItem.learningGoals => (s?.goals ?? const []).isNotEmpty,
      ProfileStrengthItem.ageGroup => s?.ageGroup != null,
      ProfileStrengthItem.level => s?.level != null,
      ProfileStrengthItem.location => has(p.country) || has(p.timeZone),
      ProfileStrengthItem.preferredTeacherGender =>
        s?.preferredTeacherGender != null,
      ProfileStrengthItem.photoOrNote => has(p.photoPath) || has(s?.note),
    };
  }
}
