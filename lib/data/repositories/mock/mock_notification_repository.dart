import 'dart:async';

import '../../../core/errors/failures.dart';
import '../../mock/mock_notifications.dart';
import '../../models/app_notification.dart';
import '../../models/notification_settings.dart';
import '../notification_repository.dart';

/// In-memory [NotificationRepository] (resets on restart).
class MockNotificationRepository implements NotificationRepository {
  MockNotificationRepository({DateTime? now}) {
    for (final n in buildMockNotifications(now ?? DateTime.now())) {
      _items[n.id] = n;
    }
  }

  final Map<String, AppNotification> _items = <String, AppNotification>{};
  final StreamController<void> _changes = StreamController<void>.broadcast();
  final Map<String, NotificationSettings> _settings =
      <String, NotificationSettings>{};

  /// Deletes [userId]'s notifications and those caused by them (mock account
  /// deletion).
  void removeUser(String userId) {
    _items.removeWhere((_, n) => n.userId == userId || n.actorId == userId);
    _settings.remove(userId);
    _changes.add(null);
  }

  List<AppNotification> _of(String userId) =>
      _items.values.where((n) => n.userId == userId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  @override
  Stream<List<AppNotification>> watchNotifications(String userId) {
    late final StreamController<List<AppNotification>> controller;
    StreamSubscription<void>? changes;
    controller = StreamController<List<AppNotification>>(
      onListen: () {
        controller.add(_of(userId));
        changes = _changes.stream.listen((_) => controller.add(_of(userId)));
      },
      onCancel: () => changes?.cancel(),
    );
    return controller.stream;
  }

  @override
  Future<void> markRead({
    required String notificationId,
    required String userId,
  }) async {
    final n = _items[notificationId];
    if (n == null || n.userId != userId) {
      throw const NotFoundFailure();
    }
    if (!n.read) {
      _items[notificationId] = n.markRead();
      _changes.add(null);
    }
  }

  @override
  Stream<NotificationSettings> watchSettings(String userId) {
    late final StreamController<NotificationSettings> controller;
    StreamSubscription<void>? changes;
    NotificationSettings read() =>
        _settings[userId] ?? const NotificationSettings();
    controller = StreamController<NotificationSettings>(
      onListen: () {
        controller.add(read());
        changes = _changes.stream.listen((_) => controller.add(read()));
      },
      onCancel: () => changes?.cancel(),
    );
    return controller.stream;
  }

  @override
  Future<void> updateSettings(
    String userId,
    NotificationSettings settings,
  ) async {
    _settings[userId] = settings;
    _changes.add(null);
  }

  @override
  Future<void> markAllRead(String userId) async {
    var changed = false;
    for (final n in _of(userId)) {
      if (!n.read) {
        _items[n.id] = n.markRead();
        changed = true;
      }
    }
    if (changed) {
      _changes.add(null);
    }
  }
}
