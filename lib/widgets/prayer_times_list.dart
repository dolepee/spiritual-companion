import 'package:flutter/material.dart';
import '../models/prayer_times.dart';
import '../services/prayer_service.dart';

class PrayerTimesList extends StatelessWidget {
  const PrayerTimesList({super.key});

  @override
  Widget build(BuildContext context) {
    final prayerTimesData = PrayerService.currentPrayerTimes;

    if (prayerTimesData == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Loading prayer times...',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
    }

    final prayerTimes = prayerTimesData.getAllPrayerTimes();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Prayer Times',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: prayerTimes.length,
              itemBuilder: (context, index) {
                final prayerInfo = prayerTimes[index];
                return _buildPrayerTimeRow(context, prayerInfo);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerTimeRow(BuildContext context, PrayerTimeInfo prayerInfo) {
    final now = DateTime.now();
    final isNextPrayer = prayerInfo.isNext;
    final hasPassed = prayerInfo.time.isBefore(now);

    Color rowColor;
    if (isNextPrayer) {
      rowColor = Theme.of(context).colorScheme.primaryContainer;
    } else if (hasPassed) {
      rowColor = Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5);
    } else {
      rowColor = Colors.transparent;
    }

    return Container(
      decoration: BoxDecoration(
        color: rowColor,
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  _getPrayerIcon(prayerInfo.name),
                  color: isNextPrayer
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
                const SizedBox(width: 12),
                Text(
                  prayerInfo.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: isNextPrayer ? FontWeight.bold : FontWeight.normal,
                        color: isNextPrayer
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ],
            ),
            Text(
              '${prayerInfo.time.hour.toString().padLeft(2, '0')}:${prayerInfo.time.minute.toString().padLeft(2, '0')}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: isNextPrayer ? FontWeight.bold : FontWeight.normal,
                    color: isNextPrayer
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPrayerIcon(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return Icons.wb_sunny;
      case 'dhuhr':
        return Icons.wb_twighlight;
      case 'asr':
        return Icons.wb_cloudy;
      case 'maghrib':
        return Icons.nights_stay;
      case 'isha':
        return Icons.bedtime;
      default:
        return Icons.access_time;
    }
  }
}