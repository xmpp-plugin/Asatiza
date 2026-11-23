import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/notification_settings.dart';
import '../../../data/repositories/notification_repository.dart';
import 'settings_state.dart';

/// Settings: notification switches (saved on change).
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._notifications, {required this.viewerId})
    : super(const SettingsState()) {
    _sub = _notifications
        .watchSettings(viewerId)
        .listen(
          (s) => emit(SettingsState(notifications: s, loaded: true)),
          onError: (Object _) {},
        );
  }

  final NotificationRepository _notifications;
  final String viewerId;
  StreamSubscription<NotificationSettings>? _sub;

  Future<void> update(NotificationSettings settings) =>
      _notifications.updateSettings(viewerId, settings);

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
