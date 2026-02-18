import 'dart:async';
import 'package:adhan/adhan.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prayer_times.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';

enum AdhanAlertMode {
  fullAdhan,
  notificationOnly,
  silent,
}

class AdhanAlertOption {
  final AdhanAlertMode mode;
  final String title;
  final String subtitle;

  const AdhanAlertOption({
    required this.mode,
    required this.title,
    required this.subtitle,
  });
}

class PrayerService {
  static AudioPlayer? _audioPlayer;
  static PrayerTimesData? _currentPrayerTimes;
  static Timer? _prayerCheckTimer;
  static String? _lastNotifiedPrayer;
  static bool _adhanAlertsEnabled = true;
  static AdhanAlertMode _adhanMode = AdhanAlertMode.fullAdhan;
  static final Map<String, bool> _enabledPrayerAlerts = {
    'Fajr': true,
    'Dhuhr': true,
    'Asr': true,
    'Maghrib': true,
    'Isha': true,
  };

  static const String _adhanAlertsEnabledKey = 'adhan_alerts_enabled';
  static const String _adhanModeKey = 'adhan_alert_mode';
  static const String _prayerToggleKeyPrefix = 'prayer_toggle_';

  static const List<AdhanAlertOption> adhanAlertOptions = [
    AdhanAlertOption(
      mode: AdhanAlertMode.fullAdhan,
      title: 'Full Adhan',
      subtitle: 'Play adhan sound at prayer time',
    ),
    AdhanAlertOption(
      mode: AdhanAlertMode.notificationOnly,
      title: 'Notification Tone',
      subtitle: 'Use phone notification tone only',
    ),
    AdhanAlertOption(
      mode: AdhanAlertMode.silent,
      title: 'Silent',
      subtitle: 'Show prayer alert without sound',
    ),
  ];

  static PrayerTimesData? get currentPrayerTimes => _currentPrayerTimes;
  static bool get adhanAlertsEnabled => _adhanAlertsEnabled;
  static AdhanAlertMode get adhanMode => _adhanMode;
  static Map<String, bool> get enabledPrayerAlerts =>
      Map<String, bool>.from(_enabledPrayerAlerts);

  static Future<void> initialize() async {
    _audioPlayer = AudioPlayer();
    await _loadSettings();
    await calculatePrayerTimes();
    _startPrayerMonitoring();
  }

  static Future<void> calculatePrayerTimes() async {
    if (LocationService.coordinates == null) {
      await LocationService.getCurrentLocation();
      if (LocationService.coordinates == null) {
        if (kDebugMode) {
          print('Cannot calculate prayer times: location not available');
        }
        return;
      }
    }

    try {
      final now = DateTime.now();
      final params = CalculationMethod.muslim_world_league.getParameters();
      params.madhab = Madhab.hanafi;

      final prayerTimes = PrayerTimes(
        LocationService.coordinates!,
        DateComponents.from(now),
        params,
      );

      _currentPrayerTimes = PrayerTimesData(
        prayerTimes: prayerTimes,
        date: now,
        coordinates: LocationService.coordinates!,
      );

      await _schedulePrayerNotifications();

      if (kDebugMode) {
        print('Prayer times calculated for ${now.toString()}');
        final nextPrayer = _currentPrayerTimes!.getNextPrayer();
        if (nextPrayer != null) {
          print('Next prayer: ${nextPrayer.name} at ${nextPrayer.time}');
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error calculating prayer times: $error');
      }
    }
  }

  static void _startPrayerMonitoring() {
    _prayerCheckTimer?.cancel();
    _prayerCheckTimer = Timer.periodic(const Duration(seconds: 20), (timer) {
      _checkPrayerTimes();
    });
  }

  static Future<void> _checkPrayerTimes() async {
    if (_currentPrayerTimes == null) return;

    final now = DateTime.now();
    final allPrayers = _currentPrayerTimes!.getAllPrayerTimes();

    for (final prayerInfo in allPrayers) {
      if (!_adhanAlertsEnabled || !(_enabledPrayerAlerts[prayerInfo.name] ?? true)) {
        continue;
      }

      final prayerStamp =
          '${prayerInfo.name}-${prayerInfo.time.year}-${prayerInfo.time.month}-${prayerInfo.time.day}';
      final secondsDiff = prayerInfo.time.difference(now).inSeconds;

      if (secondsDiff >= 0 &&
          secondsDiff <= 45 &&
          _lastNotifiedPrayer != prayerStamp) {
        await _triggerPrayerAlert(prayerInfo);
        _lastNotifiedPrayer = prayerStamp;
      }
    }

    if (now.hour == 0 && now.minute == 0 && now.second < 20) {
      await calculatePrayerTimes();
    }
  }

  static Future<void> _triggerPrayerAlert(PrayerTimeInfo prayerInfo) async {
    if (kDebugMode) {
      print('Triggering prayer alert for ${prayerInfo.name}');
    }

    await NotificationService.showPrayerNotification(
      prayerInfo.name,
      style: _notificationStyleForMode(_adhanMode),
    );

    if (_adhanMode == AdhanAlertMode.fullAdhan) {
      await _playAdhan();
    }
  }

  static Future<void> _playAdhan() async {
    try {
      if (_audioPlayer == null) return;
      await _audioPlayer!.setAsset('assets/audio/adhan.mp3');
      await _audioPlayer!.play();
    } catch (error) {
      if (kDebugMode) {
        print('Error playing adhan: $error');
      }
    }
  }

  static Future<void> stopAdhan() async {
    try {
      await _audioPlayer?.stop();
    } catch (error) {
      if (kDebugMode) {
        print('Error stopping adhan: $error');
      }
    }
  }

  static Future<void> playAdhanPreview() async {
    if (!_adhanAlertsEnabled || _adhanMode != AdhanAlertMode.fullAdhan) {
      return;
    }
    await _playAdhan();
  }

  static Future<void> refreshPrayerData() async {
    await LocationService.getCurrentLocation();
    await calculatePrayerTimes();
  }

  static Future<void> setAdhanAlertsEnabled(bool enabled) async {
    _adhanAlertsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_adhanAlertsEnabledKey, enabled);
    await _schedulePrayerNotifications();
  }

  static Future<void> setAdhanMode(AdhanAlertMode mode) async {
    _adhanMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_adhanModeKey, mode.name);
    await _schedulePrayerNotifications();
  }

  static Future<void> setPrayerAlertEnabled(String prayerName, bool enabled) async {
    _enabledPrayerAlerts[prayerName] = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_prayerToggleKeyPrefix$prayerName', enabled);
    await _schedulePrayerNotifications();
  }

  static Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    _adhanAlertsEnabled = prefs.getBool(_adhanAlertsEnabledKey) ?? true;

    final modeName = prefs.getString(_adhanModeKey);
    if (modeName != null) {
      _adhanMode = AdhanAlertMode.values.firstWhere(
        (mode) => mode.name == modeName,
        orElse: () => AdhanAlertMode.fullAdhan,
      );
    }

    for (final prayerName in _enabledPrayerAlerts.keys.toList()) {
      _enabledPrayerAlerts[prayerName] =
          prefs.getBool('$_prayerToggleKeyPrefix$prayerName') ?? true;
    }
  }

  static Future<void> _schedulePrayerNotifications() async {
    final prayerTimes = _currentPrayerTimes?.getAllPrayerTimes();
    if (prayerTimes == null) return;

    if (!_adhanAlertsEnabled) {
      await NotificationService.cancelPrayerNotifications();
      return;
    }

    await NotificationService.schedulePrayerNotifications(
      prayerTimes: prayerTimes,
      enabledPrayers: _enabledPrayerAlerts,
      style: _notificationStyleForMode(_adhanMode),
    );
  }

  static PrayerNotificationStyle _notificationStyleForMode(AdhanAlertMode mode) {
    switch (mode) {
      case AdhanAlertMode.fullAdhan:
        return PrayerNotificationStyle.adhan;
      case AdhanAlertMode.notificationOnly:
        return PrayerNotificationStyle.defaultTone;
      case AdhanAlertMode.silent:
        return PrayerNotificationStyle.silent;
    }
  }

  static void dispose() {
    _prayerCheckTimer?.cancel();
    _audioPlayer?.dispose();
  }
}
