import '../models/app_notification.dart';
import '../models/notification_settings.dart';

/// Provisional contract for in-app notifications. Throws only `Failure`
/// types.
abstract interface class NotificationRepository {
  /// [userId]'s notifications, newest first. Emits again on every change.
  Stream<List<AppNotification>> watchNotifications(String userId);

  Future<void> markRead({
    required String notificationId,
    required String userId,
  });

  Future<void> markAllRead(String userId);

  /// Which notifications [userId] wants (Settings switches).
  Stream<NotificationSettings> watchSettings(String userId);

  Future<void> updateSettings(String userId, NotificationSettings settings);
}
