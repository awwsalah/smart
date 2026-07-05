import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/pickup_request.dart';

/// Local-only alerts when a request status changes (same device demo).
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  static const String _channelId = 'request_status_channel';
  static const String _channelName = 'Request updates';

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Call once at app startup before showing notifications.
  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    // Android 13+ runtime permission for notifications.
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();

    _initialized = true;
  }

  /// Shows a local notification for the client when status changes.
  Future<void> notifyStatusChange(PickupRequest request) async {
    if (!_initialized) return;

    final message = _messageForStatus(request);
    if (message == null) return;

    await _plugin.show(
      request.id,
      message.title,
      message.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: 'Pickup request status changes',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  ({String title, String body})? _messageForStatus(PickupRequest request) {
    switch (request.status) {
      case 'accepted':
        final driver = request.driverName ?? 'A driver';
        return (
          title: 'Request accepted / La aqbalay',
          body: '$driver accepted your pickup request #${request.id}',
        );
      case 'en_route':
        return (
          title: 'Driver en route / Wadada',
          body: 'Your driver is on the way for request #${request.id}',
        );
      case 'completed':
        return (
          title: 'Pickup completed / Dhammaystiran',
          body: 'Request #${request.id} has been completed. Thank you!',
        );
      case 'cancelled':
        return (
          title: 'Request cancelled / La joojiyay',
          body: request.cancelReason ?? 'Your pickup request was cancelled',
        );
      default:
        return null;
    }
  }
}
