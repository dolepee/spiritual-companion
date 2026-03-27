import 'package:adhan/adhan.dart';

class PrayerTimeInfo {
  final Prayer prayer;
  final DateTime time;
  final String name;
  final bool isNext;
  final bool isCurrent;

  PrayerTimeInfo({
    required this.prayer,
    required this.time,
    required this.name,
    required this.isNext,
    this.isCurrent = false,
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

  static const List<Prayer> _obligatoryPrayers = <Prayer>[
    Prayer.fajr,
    Prayer.dhuhr,
    Prayer.asr,
    Prayer.maghrib,
    Prayer.isha,
  ];

  static const Map<Prayer, String> _prayerNames = <Prayer, String>{
    Prayer.fajr: 'Fajr',
    Prayer.dhuhr: 'Dhuhr',
    Prayer.asr: 'Asr',
    Prayer.maghrib: 'Maghrib',
    Prayer.isha: 'Isha',
  };

  List<PrayerTimeInfo> getAllPrayerTimes({DateTime? now}) {
    final reference = now ?? DateTime.now();
    final nextPrayer = getNextPrayer(now: reference);
    final currentPrayer = getCurrentPrayer(now: reference);

    return _obligatoryPrayers.map((prayer) {
      final prayerTime = prayerTimes.timeForPrayer(prayer) ?? reference;
      final matchesNextPrayer = nextPrayer != null &&
          nextPrayer.prayer == prayer &&
          _isSameMoment(nextPrayer.time, prayerTime);
      return PrayerTimeInfo(
        prayer: prayer,
        time: prayerTime,
        name: _prayerNames[prayer] ?? 'Prayer',
        isNext: matchesNextPrayer,
        isCurrent: currentPrayer?.prayer == prayer,
      );
    }).toList(growable: false);
  }

  PrayerTimeInfo? getCurrentPrayer({DateTime? now}) {
    final reference = now ?? DateTime.now();
    PrayerTimeInfo? current;

    for (final prayer in _obligatoryPrayers) {
      final prayerTime = prayerTimes.timeForPrayer(prayer);
      if (prayerTime == null) continue;
      if (!prayerTime.isAfter(reference)) {
        current = PrayerTimeInfo(
          prayer: prayer,
          time: prayerTime,
          name: _prayerNames[prayer] ?? 'Prayer',
          isNext: false,
          isCurrent: true,
        );
      }
    }

    if (current != null) return current;

    final previousDayTimes = PrayerTimes(
      coordinates,
      DateComponents.from(date.subtract(const Duration(days: 1))),
      prayerTimes.calculationParameters,
    );

    return PrayerTimeInfo(
      prayer: Prayer.isha,
      time: previousDayTimes.isha,
      name: _prayerNames[Prayer.isha] ?? 'Isha',
      isNext: false,
      isCurrent: true,
    );
  }

  PrayerTimeInfo? getNextPrayer({DateTime? now}) {
    final reference = now ?? DateTime.now();

    for (final prayer in _obligatoryPrayers) {
      final prayerTime = prayerTimes.timeForPrayer(prayer);
      if (prayerTime != null && prayerTime.isAfter(reference)) {
        return PrayerTimeInfo(
          prayer: prayer,
          time: prayerTime,
          name: _prayerNames[prayer] ?? 'Prayer',
          isNext: true,
        );
      }
    }

    final tomorrowTimes = PrayerTimes(
      coordinates,
      DateComponents.from(date.add(const Duration(days: 1))),
      prayerTimes.calculationParameters,
    );

    return PrayerTimeInfo(
      prayer: Prayer.fajr,
      time: tomorrowTimes.fajr,
      name: _prayerNames[Prayer.fajr] ?? 'Fajr',
      isNext: true,
    );
  }

  Duration timeUntilNextPrayer({DateTime? now}) {
    final reference = now ?? DateTime.now();
    final nextPrayer = getNextPrayer(now: reference);
    if (nextPrayer == null) return Duration.zero;
    return nextPrayer.time.difference(reference);
  }

  bool _isSameMoment(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day &&
        left.hour == right.hour &&
        left.minute == right.minute;
  }
}
