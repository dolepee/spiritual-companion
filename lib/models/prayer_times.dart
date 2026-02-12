import 'package:adhan/adhan.dart';

class PrayerTimeInfo {
  final Prayer prayer;
  final DateTime time;
  final String name;
  final bool isNext;

  PrayerTimeInfo({
    required this.prayer,
    required this.time,
    required this.name,
    required this.isNext,
  });
}

class PrayerTimesData {
  final PrayerTimes prayerTimes;
  final DateTime date;
  final Coordinates coordinates;

  PrayerTimesData({
    required this.prayerTimes,
    required this.date,
    required this.coordinates,
  });

  List<PrayerTimeInfo> getAllPrayerTimes() {
    final prayers = [
      Prayer.fajr,
      Prayer.dhuhr,
      Prayer.asr,
      Prayer.maghrib,
      Prayer.isha,
    ];

    final now = DateTime.now();
    final prayerNames = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    return prayers.asMap().entries.map((entry) {
      final index = entry.key;
      final prayer = entry.value;
      final prayerTime = prayerTimes.timeForPrayer(prayer);
      final name = prayerNames[index];
      final isNext = prayerTime != null && prayerTime.isAfter(now);

      return PrayerTimeInfo(
        prayer: prayer,
        time: prayerTime ?? DateTime.now(),
        name: name,
        isNext: isNext,
      );
    }).toList();
  }

  PrayerTimeInfo? getNextPrayer() {
    final allPrayers = getAllPrayerTimes();
    try {
      return allPrayers.firstWhere((prayer) => prayer.isNext);
    } catch (e) {
      return null;
    }
  }
}