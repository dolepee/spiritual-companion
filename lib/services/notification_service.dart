import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/prayer_times.dart';

enum PrayerNotificationStyle {
  adhan,
  defaultTone,
  silent,
}

class NotificationService {
  static FlutterLocalNotificationsPlugin? _plugin;

  static const Map<String, int> _prayerNotificationIds = {
    'Fajr': 1101,
    'Dhuhr': 1102,
    'Asr': 1103,
    'Maghrib': 1104,
    'Isha': 1105,
  };

  static const AndroidNotificationChannel _prayerDefaultChannel =
      AndroidNotificationChannel(
    'prayer_notifications_default',
    'Prayer Notifications',
    description: 'Prayer alerts with default phone tone',
    importance: Importance.high,
  );

  static const AndroidNotificationChannel _prayerAdhanChannel =
      AndroidNotificationChannel(
    'prayer_notifications_adhan',
    'Prayer Notifications (Adhan)',
    description: 'Prayer alerts with adhan sound',
    importance: Importance.max,
    sound: RawResourceAndroidNotificationSound('adhan'),
    playSound: true,
    enableVibration: true,
    audioAttributesUsage: AudioAttributesUsage.alarm,
  );

  static const AndroidNotificationChannel _prayerSilentChannel =
      AndroidNotificationChannel(
    'prayer_notifications_silent',
    'Prayer Notifications (Silent)',
    description: 'Prayer alerts without sound',
    importance: Importance.high,
    playSound: false,
  );

  static const AndroidNotificationChannel _fridayChannel =
      AndroidNotificationChannel(
    'friday_reminders',
    'Friday Reminders',
    description: 'Weekly Friday reminders',
    importance: Importance.high,
  );

  static const AndroidNotificationChannel _quranChannel =
      AndroidNotificationChannel(
    'quran_reminders',
    'Quran Reminders',
    description: 'Reminders for Quran reading',
    importance: Importance.defaultImportance,
  );

  static Future<void> initialize(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  ) async {
    _plugin = flutterLocalNotificationsPlugin;
    await _configureTimezone();

    const androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInitSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initializationSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: darwinInitSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();
    await androidPlugin?.createNotificationChannel(_prayerDefaultChannel);
    await androidPlugin?.createNotificationChannel(_prayerAdhanChannel);
    await androidPlugin?.createNotificationChannel(_prayerSilentChannel);
    await androidPlugin?.createNotificationChannel(_fridayChannel);
    await androidPlugin?.createNotificationChannel(_quranChannel);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  static Future<void> _configureTimezone() async {
    try {
      final timezoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneName));
    } catch (error) {
      if (kDebugMode) {
        print('Could not set local timezone: $error');
      }
    }
  }

  static Future<void> showPrayerNotification(
    String prayerName, {
    PrayerNotificationStyle style = PrayerNotificationStyle.defaultTone,
  }) async {
    final plugin = _plugin;
    if (plugin == null) return;

    final notificationId = _prayerNotificationIds[prayerName] ??
        (prayerName.hashCode.abs() % 100000);

    await plugin.show(
      notificationId,
      'Time for $prayerName',
      'It is time for $prayerName prayer. May Allah accept your prayers.',
      _buildPrayerNotificationDetails(style),
    );
  }

  static Future<void> schedulePrayerNotifications({
    required List<PrayerTimeInfo> prayerTimes,
    required Map<String, bool> enabledPrayers,
    PrayerNotificationStyle style = PrayerNotificationStyle.defaultTone,
  }) async {
    final plugin = _plugin;
    if (plugin == null) return;

    await cancelPrayerNotifications();
    final now = tz.TZDateTime.now(tz.local);

    for (final prayerInfo in prayerTimes) {
      if (!(enabledPrayers[prayerInfo.name] ?? true)) {
        continue;
      }

      var scheduleTime = tz.TZDateTime.from(prayerInfo.time, tz.local);
      if (scheduleTime.isBefore(now)) {
        scheduleTime = scheduleTime.add(const Duration(days: 1));
      }

      final notificationId = _prayerNotificationIds[prayerInfo.name] ??
          (prayerInfo.name.hashCode.abs() % 100000);

      await plugin.zonedSchedule(
        notificationId,
        'Time for ${prayerInfo.name}',
        'It is time for ${prayerInfo.name} prayer.',
        scheduleTime,
        _buildPrayerNotificationDetails(style),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'prayer:${prayerInfo.name}',
      );
    }
  }

  static Future<void> cancelPrayerNotifications() async {
    final plugin = _plugin;
    if (plugin == null) return;

    for (final notificationId in _prayerNotificationIds.values) {
      await plugin.cancel(notificationId);
    }
  }

  static Future<void> scheduleFridayReminders() async {
    final plugin = _plugin;
    if (plugin == null) return;

    final now = DateTime.now();
    var friday = now;
    while (friday.weekday != DateTime.friday) {
      friday = friday.add(const Duration(days: 1));
    }

    final fridayMorning = DateTime(friday.year, friday.month, friday.day, 8);

    await plugin.zonedSchedule(
      2001,
      'Friday Reminders',
      'Remember Ghusl, Surah Al-Kahf, and Salawat on the Prophet',
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
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  static Future<void> showQuranReminder(int pageNumber) async {
    final plugin = _plugin;
    if (plugin == null) return;

    await plugin.show(
      2002,
      'Continue Reading Quran',
      'Continue from page $pageNumber of the Holy Quran',
      const NotificationDetails(
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

  static NotificationDetails _buildPrayerNotificationDetails(
    PrayerNotificationStyle style,
  ) {
    switch (style) {
      case PrayerNotificationStyle.adhan:
        return const NotificationDetails(
          android: AndroidNotificationDetails(
            'prayer_notifications_adhan',
            'Prayer Notifications (Adhan)',
            channelDescription: 'Prayer alerts with adhan sound',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            sound: RawResourceAndroidNotificationSound('adhan'),
            playSound: true,
            audioAttributesUsage: AudioAttributesUsage.alarm,
          ),
          iOS: DarwinNotificationDetails(
            presentSound: true,
          ),
        );
      case PrayerNotificationStyle.silent:
        return const NotificationDetails(
          android: AndroidNotificationDetails(
            'prayer_notifications_silent',
            'Prayer Notifications (Silent)',
            channelDescription: 'Prayer alerts without sound',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            playSound: false,
          ),
          iOS: DarwinNotificationDetails(
            presentSound: false,
          ),
        );
      case PrayerNotificationStyle.defaultTone:
        return const NotificationDetails(
          android: AndroidNotificationDetails(
            'prayer_notifications_default',
            'Prayer Notifications',
            channelDescription: 'Prayer alerts with default phone tone',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentSound: true,
          ),
        );
    }
  }
}
