import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';

import '../app_formatters.dart';
import '../app_theme.dart';
import '../models/prayer_times.dart';
import '../models/quran.dart';
import '../screens/adhkar_screen.dart';
import '../screens/prayer_screen.dart';
import '../screens/quran_screen.dart';
import '../screens/tasbih_screen.dart';
import '../services/location_service.dart';
import '../services/prayer_service.dart';
import '../services/quran_service.dart';
import '../widgets/decorative_backdrop.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _ticker;
  DateTime _now = DateTime.now();
  PrayerTimeInfo? _nextPrayer;

  @override
  void initState() {
    super.initState();
    _refreshPrayerState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _now = DateTime.now();
        _refreshPrayerState();
      });
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _refreshPrayerState() {
    _nextPrayer = PrayerService.currentPrayerTimes?.getNextPrayer();
  }

  @override
  Widget build(BuildContext context) {
    final hijri = HijriCalendar.now();
    final dailyAyah = QuranService.getDailyAyah(_now);
    final bookmarkedPages = QuranService.bookmarkedPages.length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DecorativeBackdrop(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 18),
                    _buildHeroCard(context, hijri, dailyAyah),
                    const SizedBox(height: 16),
                    _buildDailyFlow(context, bookmarkedPages),
                    const SizedBox(height: 16),
                    _buildActionDeck(context),
                    const SizedBox(height: 16),
                    _buildCompanionTools(context),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isMorning = _now.hour < 12;
    final greeting = isMorning ? 'Assalamu Alaikum' : 'Peace for your evening';
    final subline = isMorning
        ? 'Begin with steadiness, remembrance, and clarity.'
        : 'Close the day with calm prayer and a gentle Quran rhythm.';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 6),
              Text(
                subline,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.slate,
                    ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFEAE0D0)),
          ),
          child: Column(
            children: [
              Text(
                _now.day.toString().padLeft(2, '0'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.emerald,
                    ),
              ),
              Text(
                AppFormatters.formatShortDate(_now).split(',').first,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard(
    BuildContext context,
    HijriCalendar hijri,
    Ayah? dailyAyah,
  ) {
    final nextPrayer = _nextPrayer;
    final verseSurah = dailyAyah == null
        ? null
        : QuranService.getSurahByNumber(dailyAyah.surahNumber);
    final countdown = nextPrayer == null
        ? '--:--'
        : AppFormatters.countdown(nextPrayer.time.difference(_now));

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.emerald,
            AppColors.emeraldSoft,
            Color(0xFF113C32),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.emerald.withValues(alpha: 0.28),
            blurRadius: 34,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Your next pause for prayer',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.88),
                      ),
                ),
              ),
              Text(
                AppFormatters.formatShortDate(_now),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.72),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            nextPrayer?.name ?? 'Prayer data loading',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  height: 1,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            nextPrayer == null
                ? 'Refresh location and prayer data to continue.'
                : '${AppFormatters.formatTime(nextPrayer.time)} • starts in $countdown',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.86),
                ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _HeroMetric(
                  label: 'Hijri',
                  value: AppFormatters.formatHijri(hijri),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeroMetric(
                  label: 'Gregorian',
                  value: AppFormatters.formatDate(_now),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _HeroSignal(
                      icon: Icons.explore_rounded,
                      label: LocationService.currentPosition == null
                          ? 'Location unavailable'
                          : 'Qibla ${LocationService.getQiblaDirection().toStringAsFixed(0)}°',
                    ),
                    if (verseSurah != null)
                      _HeroSignal(
                        icon: Icons.auto_stories_rounded,
                        label:
                            '${verseSurah.englishName} ${dailyAyah!.numberInSurah}',
                      ),
                  ],
                ),
                if (dailyAyah != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    'Daily reminder',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.70),
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    dailyAyah.text.replaceFirst('\ufeff', ''),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontFamily: QuranService.selectedFontOption.fontFamily,
                          height: 1.65,
                        ),
                  ),
                ] else ...[
                  const SizedBox(height: 10),
                  Text(
                    LocationService.currentPosition == null
                        ? 'Open Prayer to refresh location and align qibla accurately.'
                        : 'The next prayer, your dates, and a quiet Quran reminder stay connected here.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.84),
                        ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyFlow(BuildContext context, int bookmarkedPages) {
    final currentPage = QuranService.currentPage;
    final surahName = QuranService.getSurahNamesForPage(currentPage);
    final juz = QuranService.getJuzForPage(currentPage);
    final prayers = PrayerService.currentPrayerTimes?.getAllPrayerTimes() ?? const <PrayerTimeInfo>[];
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xF0EBDDDE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeading(
              title: 'Today\'s Flow',
              subtitle: 'Prayer rhythm, Quran continuity, and your next gentle action in one composed view.',
              actionLabel: 'Reader',
              onTap: () => _openScreen(context, const QuranScreen()),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(26),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reading resume',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.slate,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Page $currentPage',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$surahName${juz == null ? '' : ' • Juz $juz'}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InlineMetricPill(label: '$bookmarkedPages bookmarks'),
                      _InlineMetricPill(
                        label: _nextPrayer == null
                            ? 'Prayer loading'
                            : 'Next: ${_nextPrayer!.name}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: () => _openScreen(context, const QuranScreen()),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text('Resume from page $currentPage'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Prayer rhythm',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            if (prayers.isEmpty)
              Text(
                'Prayer data is still loading.',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: prayers
                    .map(
                      (prayer) => _PrayerRhythmChip(prayer: prayer),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionDeck(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFEDE2D2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Continue with intention', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              'The most useful actions stay close without breaking the calm rhythm of the page.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _QuickActionTile(
                    icon: Icons.self_improvement_rounded,
                    accent: AppColors.gold,
                    title: 'Adhkar',
                    subtitle: 'Morning and evening remembrance',
                    onTap: () => _openScreen(context, const AdhkarScreen()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionTile(
                    icon: Icons.touch_app_rounded,
                    accent: AppColors.moss,
                    title: 'Tasbih',
                    subtitle: 'Count dhikr with focus',
                    onTap: () => _openScreen(context, const TasbihScreen()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _ToolRow(
              title: 'Prayer detail and qibla',
              subtitle: 'Open the full schedule, compass, and notification settings.',
              icon: Icons.schedule_rounded,
              onTap: () => _openScreen(context, const PrayerScreen()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanionTools(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHeading(
              title: 'Spiritual Companion',
              subtitle: 'Keep your practice calm, regular, and easy to return to.',
            ),
            const SizedBox(height: 18),
            _ToolRow(
              title: 'Morning and Evening Adhkar',
              subtitle: 'Structured remembrance with cleaner progress and repeat cues.',
              icon: Icons.wb_sunny_outlined,
              onTap: () => _openScreen(context, const AdhkarScreen()),
            ),
            const SizedBox(height: 12),
            _ToolRow(
              title: 'Tasbih Sessions',
              subtitle: 'Count dhikr with goals, rhythm, and satisfying interaction.',
              icon: Icons.blur_circular_rounded,
              onTap: () => _openScreen(context, const TasbihScreen()),
            ),
          ],
        ),
      ),
    );
  }

  void _openScreen(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 360),
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final fade = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
          final slide = Tween<Offset>(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(fade);
          return FadeTransition(
            opacity: fade,
            child: SlideTransition(position: slide, child: child),
          );
        },
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.72),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _HeroSignal extends StatelessWidget {
  const _HeroSignal({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.86)),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.86),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.accent,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: accent),
              ),
              const SizedBox(height: 16),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InlineMetricPill extends StatelessWidget {
  const _InlineMetricPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _PrayerRhythmChip extends StatelessWidget {
  const _PrayerRhythmChip({required this.prayer});

  final PrayerTimeInfo prayer;

  @override
  Widget build(BuildContext context) {
    final isEmphasized = prayer.isCurrent || prayer.isNext;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: prayer.isCurrent
            ? const Color(0xFFF5E8CA)
            : prayer.isNext
                ? AppColors.emerald.withValues(alpha: 0.10)
                : AppColors.cream,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isEmphasized
              ? AppColors.emerald.withValues(alpha: 0.24)
              : const Color(0xFFE9DECF),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            prayer.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isEmphasized ? AppColors.emerald : AppColors.ink,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            AppFormatters.formatTime(prayer.time),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _ToolRow extends StatelessWidget {
  const _ToolRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: AppColors.emerald),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: AppColors.slate),
          ],
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        if (actionLabel != null && onTap != null)
          TextButton(
            onPressed: onTap,
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}
