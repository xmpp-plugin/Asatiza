import 'package:equatable/equatable.dart';

import '../../../data/models/notification_settings.dart';

/// 21 Settings.
class SettingsState extends Equatable {
  const SettingsState({
    this.notifications = const NotificationSettings(),
    this.loaded = false,
  });

  final NotificationSettings notifications;
  final bool loaded;

  @override
  List<Object?> get props => <Object?>[notifications, loaded];
}
