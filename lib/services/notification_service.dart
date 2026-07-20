import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/task_model.dart';

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin
  flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Whether exact alarms are available (Android 12+ requires user grant).
  static bool _exactAlarmsGranted = false;

  static Future<void> initialize() async {
    // 1. Load all timezone data
    tz.initializeTimeZones();

    // 2. Set the local timezone to the device's current offset.
    final String localTzName = _getLocalTzName();
    try {
      tz.setLocalLocation(tz.getLocation(localTzName));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }

    // 3. Android init settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
        InitializationSettings(android: androidSettings);

    await flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    // 4. Create the notification channel explicitly (required Android 8+)
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      // Create channel
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'study_channel',
        'Study Reminders',
        description: 'Notifications for upcoming study sessions',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        enableLights: true,
      );
      await androidPlugin.createNotificationChannel(channel);

      // Request POST_NOTIFICATIONS permission (Android 13+)
      await androidPlugin.requestNotificationsPermission();

      // Request exact alarm permission (Android 12+)
      try {
        await androidPlugin.requestExactAlarmsPermission();
        _exactAlarmsGranted = true;
      } catch (_) {
        _exactAlarmsGranted = false;
      }

      // Check final state
      final bool? exactOk =
          await androidPlugin.canScheduleExactNotifications();
      _exactAlarmsGranted = exactOk ?? false;

      if (kDebugMode) {
        final enabled = await androidPlugin.areNotificationsEnabled();
        debugPrint(
          '[NotifService] exactAlarms=$_exactAlarmsGranted enabled=$enabled',
        );
      }
    }
  }

  static void _onNotificationResponse(NotificationResponse response) {
    if (kDebugMode) {
      debugPrint('[NotifService] Tapped notification id=${response.id}');
    }
  }

  /// Returns a timezone name matching the device's current UTC offset.
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
      case 60:
        return 'Europe/London';
      case 120:
        return 'Europe/Berlin';
      case 180:
        return 'Asia/Riyadh';
      case 480:
        return 'Asia/Shanghai';
      case 540:
        return 'Asia/Tokyo';
      case -300:
        return 'America/New_York';
      case -360:
        return 'America/Chicago';
      case -420:
        return 'America/Denver';
      case -480:
        return 'America/Los_Angeles';
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

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'study_channel',
        'Study Reminders',
        channelDescription: 'Notifications for upcoming study sessions',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
        enableLights: true,
        fullScreenIntent: false,
      ),
    );

    final AndroidScheduleMode scheduleMode = _exactAlarmsGranted
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzScheduled,
        details,
        androidScheduleMode: scheduleMode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: null,
      );
      return true;
    } catch (error) {
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
      } catch (_) {
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

  /// Synchronizes scheduled notifications with current Firestore tasks.
  /// Handles creation, modification, completion, and deletion of tasks automatically.
  static Future<void> syncNotifications(List<TaskModel> tasks) async {
    final now = DateTime.now();
    final Set<int> activeNotifIds = {};

    // 1. Schedule or update notifications for all active upcoming tasks
    for (final task in tasks) {
      if (task.completed) continue;

      try {
        final datePart = DateFormat("dd MMM yyyy").parse(task.date);
        final timePart = DateFormat.jm().parse(task.startTime);
        final startDateTime = DateTime(
          datePart.year,
          datePart.month,
          datePart.day,
          timePart.hour,
          timePart.minute,
        );

        final reminderTime = startDateTime.subtract(const Duration(minutes: 10));
        if (reminderTime.isAfter(now)) {
          final int notifId = task.id.hashCode.abs() % 100000;
          activeNotifIds.add(notifId);

          await scheduleNotification(
            id: notifId,
            title: '⏰ Upcoming Study Session',
            body: '${task.title} · ${task.subjectName} starts in 10 minutes!',
            scheduledTime: reminderTime,
          );
        }
      } catch (_) {
        // Skip malformed tasks
      }
    }

    // 2. Clean up any scheduled notifications for deleted or completed tasks
    try {
      final List<PendingNotificationRequest> pending =
          await flutterLocalNotificationsPlugin.pendingNotificationRequests();
      for (final req in pending) {
        if (!activeNotifIds.contains(req.id)) {
          await cancelNotification(req.id);
        }
      }
    } catch (_) {
      // Ignore platform lookup failures
    }
  }
}
