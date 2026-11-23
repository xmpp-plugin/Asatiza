import '../../data/models/profile.dart';
import 'profile_strength_calculator.dart';

/// Who appears on the Teachers / Students tabs and who may send a request
/// (plan section 7). The backend phase mirrors these rules in RLS.
class DiscoverVisibilityRules {
  const DiscoverVisibilityRules({
    ProfileStrengthCalculator strength = const ProfileStrengthCalculator(),
  }) : _strength = strength;

  final ProfileStrengthCalculator _strength;

  /// Teachers are listed from this profile strength (and only when verified).
  static const int teacherListPercent = 80;

  /// Students are listed from this profile strength (and only when looking).
  static const int studentListPercent = 60;

  /// A user may send connection requests from this profile strength.
  static const int requestPercent = 60;

  bool isTeacherListed(Profile profile) =>
      profile.isTeacher &&
      profile.isVerified &&
      _strength.percent(profile) >= teacherListPercent;

  bool isStudentListed(Profile profile) =>
      !profile.isTeacher &&
      (profile.studentDetails?.lookingForTeacher ?? false) &&
      _strength.percent(profile) >= studentListPercent;

  bool canSendRequest(Profile sender) =>
      _strength.percent(sender) >= requestPercent;
}
