import '../../data/models/profile.dart';

/// Who appears on the Teachers / Students tabs and who may send a request
/// (plan section 7): every **active** profile (all required fields filled,
/// `Profile.isActive`, set by the database). Admin approval and "Looking for
/// a teacher" do not affect listing.
class DiscoverVisibilityRules {
  const DiscoverVisibilityRules();

  bool isTeacherListed(Profile profile) =>
      profile.isTeacher && profile.isActive;

  bool isStudentListed(Profile profile) =>
      !profile.isTeacher && profile.isActive;

  /// Sender and receiver both need an active profile.
  bool canSendRequest(Profile sender) => sender.isActive;

  bool canReceiveRequest(Profile receiver) => receiver.isActive;
}
