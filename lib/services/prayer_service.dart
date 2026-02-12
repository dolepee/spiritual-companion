import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:adhan/adhan.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/prayer_times.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';

class PrayerService {
  static AudioPlayer? _audioPlayer;
  static PrayerTimesData? _currentPrayerTimes;
  static Timer? _prayerCheckTimer;
  static String? _lastNotifiedPrayer;

  static PrayerTimesData? get currentPrayerTimes => _currentPrayerTimes;

  static Future<void> initialize() async {
    _audioPlayer = AudioPlayer();
    await calculatePrayerTimes();
    _startPrayerMonitoring();
  }

  static Future<void> calculatePrayerTimes() async {
    if (LocationService.coordinates == null) {
      if (kDebugMode) print('Cannot calculate prayer times: Location not available');
      return;
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

      if (kDebugMode) {
        print('Prayer times calculated for ${now.toString()}');
        final nextPrayer = _currentPrayerTimes!.getNextPrayer();
        if (nextPrayer != null) {
          print('Next prayer: ${nextPrayer.name} at ${nextPrayer.time}');
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error calculating prayer times: $e');
    }
  }

  static void _startPrayerMonitoring() {
    _prayerCheckTimer?.cancel();
    _prayerCheckTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkPrayerTimes();
    });
  }

  static Future<void> _checkPrayerTimes() async {
    if (_currentPrayerTimes == null) return;

    final now = DateTime.now();
    final allPrayers = _currentPrayerTimes!.getAllPrayerTimes();

    for (final prayerInfo in allPrayers) {
      final timeDiff = prayerInfo.time.difference(now).inMinutes;

      if (timeDiff >= 0 && timeDiff <= 1) {
        if (_lastNotifiedPrayer != prayerInfo.name) {
          await _triggerPrayerNotification(prayerInfo);
          _lastNotifiedPrayer = prayerInfo.name;
        }
      }
    }

    if (now.hour == 0 && now.minute == 0) {
      await calculatePrayerTimes();
    }
  }

  static Future<void> _triggerPrayerNotification(
      PrayerTimeInfo prayerInfo) async {
    if (kDebugMode) {
      print('Triggering notification for ${prayerInfo.name}');
    }

    await NotificationService.showPrayerNotification(
      FlutterLocalNotificationsPlugin(),
      prayerInfo.name,
      prayerInfo.time,
    );

    await _playAdhan();
  }

  static Future<void> _playAdhan() async {
    try {
      if (_audioPlayer != null) {
        await _audioPlayer!.setAsset('assets/audio/adhan.mp3');
        await _audioPlayer!.play();
      }
    } catch (e) {
      if (kDebugMode) print('Error playing adhan: $e');
    }
  }

  static Future<void> stopAdhan() async {
    try {
      if (_audioPlayer != null) {
        await _audioPlayer!.stop();
      }
    } catch (e) {
      if (kDebugMode) print('Error stopping adhan: $e');
    }
  }

  static void dispose() {
    _prayerCheckTimer?.cancel();
    _audioPlayer?.dispose();
  }
}