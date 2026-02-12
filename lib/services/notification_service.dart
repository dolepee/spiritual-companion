import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'prayer_notifications',
    'Prayer Notifications',
    description: 'Notifications for prayer times and Islamic reminders',
    importance: Importance.high,
  );

  static Future<void> initialize(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  static Future<void> showPrayerNotification(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
      String prayerName,
      DateTime prayerTime) async {
    final notificationId = prayerName.hashCode.abs() % 100000;
    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      'Time for $prayerName',
      'It is time for $prayerName prayer. May Allah accept your prayers.',
      tz.TZDateTime.from(prayerTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'prayer_notifications',
          'Prayer Notifications',
          channelDescription: 'Notifications for prayer times',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> scheduleFridayReminders(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    final now = DateTime.now();
    var friday = now;
    while (friday.weekday != DateTime.friday) {
      friday = friday.add(const Duration(days: 1));
    }

    final fridayMorning = DateTime(
      friday.year,
      friday.month,
      friday.day,
      8,
      0,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      1,
      'Friday Reminders',
      '🌟 Remember to perform Ghusl, read Surah Al-Kahf, and send Salawat on the Prophet (ﷺ)',
      tz.TZDateTime.from(fridayMorning, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'friday_reminders',
          'Friday Reminders',
          channelDescription: 'Weekly Friday reminders',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  static Future<void> showQuranReminder(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
      int pageNumber) async {
    await flutterLocalNotificationsPlugin.show(
      2,
      'Continue Reading Quran',
      'Continue from page $pageNumber of the Holy Quran',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'quran_reminders',
          'Quran Reminders',
          channelDescription: 'Reminders for Quran reading',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }
}