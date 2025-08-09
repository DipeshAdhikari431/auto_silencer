import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'timezone_service.dart';

class NotificationService {
  static FlutterLocalNotificationsPlugin get notificationsPlugin =>
      _notificationsPlugin;
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Cancel all scheduled notifications
  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  static Future<void> initialize() async {
    await TimeZoneService.initialize();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );
    await _notificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    // Show notification 5 minutes before the schedule's start time
    final notifTime = scheduledTime.subtract(const Duration(minutes: 5));
    print('timezone to local, ${TimeZoneService.toLocal(notifTime)}');
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      TimeZoneService.toLocal(notifTime),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'schedule_channel',
          'Schedules',
          channelDescription: 'Schedule notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
    print('Scheduled notification $id at $notifTime');
  }

  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  /// Show an immediate notification for debugging purposes
  static Future<void> showImmediateNotification() async {
    await _notificationsPlugin.show(
      0,
      'Test Notification',
      'This is a test notification',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'schedule_channel',
          'Schedules',
          channelDescription: 'Schedule notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  static Future<void> showScheduledNotification() async {
    await _notificationsPlugin.zonedSchedule(
      899,
      'testNotification',
      'scheduled notification',
      TimeZoneService.toLocal(DateTime.now().add(const Duration(seconds: 10))),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'schedule_channel',
          'Schedules',
          channelDescription: 'Schedule notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}
