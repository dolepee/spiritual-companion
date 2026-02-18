import 'dart:async';
import 'package:flutter/material.dart';
import '../services/quran_service.dart';
import '../services/notification_service.dart';
import '../services/prayer_service.dart';
import '../screens/quran_screen.dart';

class PostPrayerService {
  static Timer? _checkTimer;
  static String? _lastPrayerNotified;
  static bool _quranPromptShown = false;

  static void initialize() {
    _startPostPrayerMonitoring();
  }

  static void _startPostPrayerMonitoring() {
    _checkTimer?.cancel();
    _checkTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkPostPrayerTime();
    });
  }

  static void _checkPostPrayerTime() {
    final now = DateTime.now();

    // Use real calculated prayer times if available
    final realPrayerTimes = PrayerService.currentPrayerTimes?.getAllPrayerTimes();

    if (realPrayerTimes != null) {
      for (final prayerInfo in realPrayerTimes) {
        final diffMinutes = now.difference(prayerInfo.time).inMinutes;
        if (diffMinutes >= 0 && diffMinutes < 15) {
          if (_lastPrayerNotified != prayerInfo.name && !_quranPromptShown) {
            _showQuranPrompt(prayerInfo.name);
            _lastPrayerNotified = prayerInfo.name;
            _quranPromptShown = true;

            Timer(const Duration(minutes: 15), () {
              _quranPromptShown = false;
            });
          }
        }
      }
      return;
    }

    // Fallback to hardcoded times if prayer data unavailable
    final currentHour = now.hour;
    final currentMinute = now.minute;

    final fallbackPrayerTimes = {
      'Fajr': (5, 30),
      'Dhuhr': (13, 30),
      'Asr': (16, 30),
      'Maghrib': (19, 0),
      'Isha': (21, 0),
    };

    for (final entry in fallbackPrayerTimes.entries) {
      final prayerName = entry.key;
      final (hour, minute) = entry.value;

      if (currentHour == hour && currentMinute >= minute && currentMinute < minute + 15) {
        if (_lastPrayerNotified != prayerName && !_quranPromptShown) {
          _showQuranPrompt(prayerName);
          _lastPrayerNotified = prayerName;
          _quranPromptShown = true;

          Timer(const Duration(minutes: 15), () {
            _quranPromptShown = false;
          });
        }
      }
    }
  }

  static void _showQuranPrompt(String prayerName) {
    final nextPage = QuranService.getNextUnreadPage();
    
    NotificationService.showQuranReminder(
      nextPage,
    );
  }

  static void dispose() {
    _checkTimer?.cancel();
  }
}

class QuranPromptDialog extends StatelessWidget {
  final int pageNumber;
  final VoidCallback onMarkAsRead;
  final VoidCallback onDismiss;

  const QuranPromptDialog({
    super.key,
    required this.pageNumber,
    required this.onMarkAsRead,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.menu_book,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          const Text('Continue Reading Quran'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'After completing your prayer, continue your spiritual journey with the Holy Quran.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Next Page:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                ),
                Text(
                  '$pageNumber',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Continue from where you left off and strengthen your connection with Allah\'s words.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onDismiss,
          child: const Text('Later'),
        ),
        ElevatedButton(
          onPressed: () {
            onMarkAsRead();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const QuranScreen()),
            );
          },
          child: const Text('Open Quran'),
        ),
      ],
    );
  }
}
