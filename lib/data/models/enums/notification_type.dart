/// Kinds of in-app notification (plan section 9).
enum NotificationType {
  /// Someone wants to connect (Accept / Decline).
  connectionRequest,

  /// Your request was accepted ("Say salam!").
  requestAccepted,

  /// Someone commented on your post.
  comment,

  /// People liked your post (grouped: "… and 11 others").
  likes,

  /// Your teacher profile was approved.
  teacherApproved,

  /// Your teacher profile needs changes before approval.
  teacherNeedsChanges,
}
