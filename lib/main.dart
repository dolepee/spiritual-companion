import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/prayer_screen.dart';
import 'screens/quran_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/settings_screen.dart';
import 'services/app_preferences_service.dart';
import 'services/notification_service.dart';
import 'services/location_service.dart';
import 'services/prayer_service.dart';
import 'services/quran_service.dart';
import 'services/post_prayer_service.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    tz.initializeTimeZones();
  } catch (_) {}

  try {
    await NotificationService.initialize(flutterLocalNotificationsPlugin);
  } catch (_) {}

  try {
    await LocationService.initialize();
  } catch (_) {}

  try {
    await PrayerService.initialize();
  } catch (_) {}

  try {
    await QuranService.initialize();
  } catch (_) {}

  try {
    await AppPreferencesService.initialize();
  } catch (_) {}

  try {
    await NotificationService.scheduleFridayReminders();
  } catch (_) {}

  try {
    PostPrayerService.initialize();
  } catch (_) {}

  runApp(const SpiritualCompanionApp());
}

class SpiritualCompanionApp extends StatelessWidget {
  const SpiritualCompanionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spiritual Companion',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  int _lastNonReaderIndex = 0;

  final List<NavigationDestination> _destinations = const [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home_rounded),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.schedule_outlined),
      selectedIcon: Icon(Icons.schedule_rounded),
      label: 'Prayer',
    ),
    NavigationDestination(
      icon: Icon(Icons.menu_book_outlined),
      selectedIcon: Icon(Icons.menu_book_rounded),
      label: 'Quran',
    ),
    NavigationDestination(
      icon: Icon(Icons.calendar_month_outlined),
      selectedIcon: Icon(Icons.calendar_month_rounded),
      label: 'Dates',
    ),
    NavigationDestination(
      icon: Icon(Icons.tune_outlined),
      selectedIcon: Icon(Icons.tune_rounded),
      label: 'Settings',
    ),
  ];

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return const HomeScreen();
      case 1:
        return const PrayerScreen();
      case 2:
        return QuranScreen(onExitReader: _exitReader);
      case 3:
        return const CalendarScreen();
      case 4:
        return const SettingsScreen();
      default:
        return const HomeScreen();
    }
  }

  void _selectDestination(int index) {
    if (index == _currentIndex) return;

    setState(() {
      if (index == 2) {
        _lastNonReaderIndex = _currentIndex == 2 ? 0 : _currentIndex;
      } else {
        _lastNonReaderIndex = index;
      }
      _currentIndex = index;
    });
  }

  void _exitReader() {
    setState(() {
      _currentIndex = _lastNonReaderIndex == 2 ? 0 : _lastNonReaderIndex;
    });
    QuranService.setReaderChromeVisible(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 420),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final offset = Tween<Offset>(
            begin: const Offset(0.0, 0.02),
            end: Offset.zero,
          ).animate(animation);
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: offset, child: child),
          );
        },
        child: KeyedSubtree(
          key: ValueKey<int>(_currentIndex),
          child: _buildScreen(_currentIndex),
        ),
      ),
      bottomNavigationBar: ValueListenableBuilder<bool>(
        valueListenable: QuranService.readerChromeVisibleListenable,
        builder: (context, chromeVisible, _) {
          final showNavigation = _currentIndex != 2 && chromeVisible;
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return SizeTransition(
                sizeFactor: animation,
                axisAlignment: -1,
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: showNavigation
                ? Container(
                    key: const ValueKey<String>('main-nav-visible'),
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 24,
                          offset: const Offset(0, -8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: NavigationBar(
                        selectedIndex: _currentIndex,
                        onDestinationSelected: _selectDestination,
                        destinations: _destinations,
                      ),
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey<String>('main-nav-hidden')),
          );
        },
      ),
    );
  }
}
