import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin
  flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // 1. Load all timezone data
    tz.initializeTimeZones();

    // 2. Set the local timezone to the device's current offset.
    //    We do this without flutter_timezone by using DateTime.now()
    //    which already knows the device offset.
    final String localTzName = _getLocalTzName();
    try {
      tz.setLocalLocation(tz.getLocation(localTzName));
    } catch (_) {
      // Fallback to UTC if the name lookup fails
      tz.setLocalLocation(tz.UTC);
    }

    // 3. Android init settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
        InitializationSettings(android: androidSettings);

    await flutterLocalNotificationsPlugin.initialize(settings);

    // 4. Request POST_NOTIFICATIONS permission (Android 13 / API 33+)
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      final bool? permissionGranted =
          await androidPlugin.requestNotificationsPermission();
      // Request exact alarm permission (Android 12+ / API 31+)
      await androidPlugin.requestExactAlarmsPermission();

      if (kDebugMode) {
        final enabled = await androidPlugin.areNotificationsEnabled();
        debugPrint(
          '[NotifService] notificationsPermission=$permissionGranted enabled=$enabled',
        );
      }
    }
  }

  /// Returns a timezone name matching the device's current UTC offset.
  /// Falls back to UTC only when no safe mapping exists.
  static String _getLocalTzName() {
    final offset = DateTime.now().timeZoneOffset;

    switch (offset.inMinutes) {
      case 330:
        return 'Asia/Kolkata';
      case 345:
        return 'Asia/Kathmandu';
      case 390:
        return 'Asia/Yangon';
      case 270:
        return 'Asia/Kabul';
      case 570:
        return 'Australia/Darwin';
      case 630:
        return 'Australia/Adelaide';
    }

    final hours = offset.inHours;
    if (offset.inMinutes % 60 == 0) {
      return 'Etc/GMT${hours > 0 ? '-' : '+'}${hours.abs()}';
    }

    return 'UTC';
  }

  static Future<bool> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    final tz.TZDateTime tzScheduled = tz.TZDateTime.from(
      scheduledTime,
      tz.local,
    );

    if (kDebugMode) {
      debugPrint('[NotifService] Scheduling id=$id at $tzScheduled â†’ "$title"');
    }

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'study_channel',
        'Study Reminders',
        channelDescription: 'Notifications for upcoming study sessions',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
    );

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzScheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: null,
      );
      return true;
    } catch (error) {
      if (kDebugMode) {
        debugPrint(
          '[NotifService] Exact schedule failed for id=$id, retrying inexact: $error',
        );
      }

      try {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          tzScheduled,
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: null,
        );
        return true;
      } catch (fallbackError) {
        if (kDebugMode) {
          debugPrint(
            '[NotifService] Inexact schedule also failed for id=$id: $fallbackError',
          );
        }
        return false;
      }
    }
  }

  static Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}

