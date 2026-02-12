import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import '../models/prayer_times.dart';
import '../services/prayer_service.dart';
import '../services/quran_service.dart';
import '../screens/adhkar_screen.dart';
import '../screens/tasbih_screen.dart';
import '../widgets/prayer_time_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HijriCalendar _hijriDate = HijriCalendar.now();
  PrayerTimeInfo? _nextPrayer;

  @override
  void initState() {
    super.initState();
    _updateNextPrayer();
  }

  void _updateNextPrayer() {
    if (PrayerService.currentPrayerTimes != null) {
      setState(() {
        _nextPrayer = PrayerService.currentPrayerTimes!.getNextPrayer();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildHijriDateCard(),
              const SizedBox(height: 24),
              _buildNextPrayerCard(),
              const SizedBox(height: 24),
              _buildActionCards(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Assalamu Alaikum',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Welcome to your spiritual companion',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
        ),
      ],
    );
  }

  Widget _buildHijriDateCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hijri Date',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_hijriDate.hDay} ${_hijriDate.getLongMonthName()} ${_hijriDate.hYear} AH',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            Icon(
              Icons.calendar_today,
              color: Theme.of(context).colorScheme.primary,
              size: 32,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextPrayerCard() {
    if (_nextPrayer == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Loading prayer times...'),
        ),
      );
    }

    return PrayerTimeCard(prayerInfo: _nextPrayer!);
  }

  Widget _buildActionCards() {
    return Expanded(
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildActionCard(
            'Adhkar',
            'Morning & Evening Remembrances',
            Icons.book,
            Colors.green,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AdhkarScreen()),
            ),
          ),
          _buildActionCard(
            'Tasbih',
            'Digital Counter',
            Icons.repeat,
            Colors.blue,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TasbihScreen()),
            ),
          ),
          _buildActionCard(
            'Quran Progress',
            'Page ${QuranService.currentPage}',
            Icons.menu_book,
            Colors.purple,
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Navigate to Quran tab to continue reading')),
              );
            },
          ),
          _buildActionCard(
            'Prayer Status',
            'View All Times',
            Icons.access_time,
            Colors.orange,
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Navigate to Prayer tab for details')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 40,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}