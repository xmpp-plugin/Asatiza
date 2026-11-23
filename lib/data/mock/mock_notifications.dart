import '../models/app_notification.dart';
import '../models/enums/notification_type.dart';
import 'mock_profiles.dart';

/// Seed notifications, created relative to [now]. Request notifications point
/// at the pending requests in `buildMockConnections`
/// (`connection-4`, `-5`, `-9`, `-10`).
List<AppNotification> buildMockNotifications(DateTime now) {
  var n = 0;
  AppNotification note(
    String userId,
    NotificationType type,
    Duration ago, {
    String? actor,
    String? postId,
    String? connectionId,
    String? text,
    int others = 0,
    bool read = false,
  }) {
    n++;
    return AppNotification(
      id: 'notification-$n',
      userId: userId,
      type: type,
      createdAt: now.subtract(ago),
      actorId: actor,
      postId: postId,
      connectionId: connectionId,
      text: text,
      othersCount: others,
      read: read,
    );
  }

  return <AppNotification>[
    // Ayesha (student account)
    note(
      MockIds.ayesha,
      NotificationType.connectionRequest,
      const Duration(hours: 5),
      actor: MockIds.usman,
      connectionId: 'connection-4',
      text:
          'Assalamu alaikum Ayesha, I have evening slots for Tajweed revision '
          'if you are still looking.',
    ),
    note(
      MockIds.ayesha,
      NotificationType.connectionRequest,
      const Duration(days: 1, hours: 3),
      actor: MockIds.fatimaZahra,
      connectionId: 'connection-5',
    ),
    note(
      MockIds.ayesha,
      NotificationType.requestAccepted,
      const Duration(days: 3, hours: 2),
      actor: MockIds.ahmed,
      read: true,
    ),
    note(
      MockIds.ayesha,
      NotificationType.likes,
      const Duration(days: 4),
      actor: MockIds.maryam,
      postId: 'post-005',
      others: 18,
      read: true,
    ),
    // Qari Ahmed (teacher account)
    note(
      MockIds.ahmed,
      NotificationType.connectionRequest,
      const Duration(hours: 2),
      actor: MockIds.omar,
      connectionId: 'connection-9',
      text:
          'Assalamu alaikum Qari sahib, I am revising my first 10 juz and need '
          'someone to listen to my revision three times a week.',
    ),
    note(
      MockIds.ahmed,
      NotificationType.comment,
      const Duration(hours: 1),
      actor: MockIds.hira,
      postId: 'post-001',
      text:
          'JazakAllahu khairan Ustadh, this is the exact mistake I keep '
          'making.',
    ),
    note(
      MockIds.ahmed,
      NotificationType.connectionRequest,
      const Duration(days: 1),
      actor: MockIds.hamid,
      connectionId: 'connection-10',
      text:
          'Learning to read as an adult, weekends only. Do you take '
          'beginners?',
    ),
    note(
      MockIds.ahmed,
      NotificationType.teacherApproved,
      const Duration(days: 1, hours: 2),
      read: true,
    ),
    note(
      MockIds.ahmed,
      NotificationType.likes,
      const Duration(days: 2),
      actor: MockIds.ayesha,
      postId: 'post-001',
      others: 47,
      read: true,
    ),
  ];
}
