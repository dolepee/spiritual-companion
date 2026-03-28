import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';

import '../app_formatters.dart';
import '../app_theme.dart';
import '../models/prayer_times.dart';
import '../services/location_service.dart';
import '../services/prayer_service.dart';
import '../widgets/decorative_backdrop.dart';
import '../widgets/qibla_compass.dart';

class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  StreamSubscription<CompassEvent>? _compassSubscription;
  Timer? _ticker;

  double _heading = 0;
  bool _compassAvailable = false;
  bool _loading = true;
  bool _updating = false;
  DateTime _now = DateTime.now();

  bool _alertsEnabled = true;
  AdhanAlertMode _selectedMode = AdhanAlertMode.fullAdhan;
  Map<String, bool> _prayerToggles = <String, bool>{};

  @override
  void initState() {
    super.initState();
    _loadSettingsFromService();
    _initializeScreen();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _initializeScreen() async {
    setState(() => _loading = true);
    await PrayerService.refreshPrayerData();
    _listenToCompass();
    _loadSettingsFromService();
    if (!mounted) return;
    setState(() {
      _loading = false;
      _now = DateTime.now();
    });
  }

  void _loadSettingsFromService() {
    _alertsEnabled = PrayerService.adhanAlertsEnabled;
    _selectedMode = PrayerService.adhanMode;
    _prayerToggles = PrayerService.enabledPrayerAlerts;
  }

  void _listenToCompass() {
    final eventStream = FlutterCompass.events;
    if (eventStream == null) {
      if (mounted) {
        setState(() => _compassAvailable = false);
      }
      return;
    }

    _compassSubscription?.cancel();
    _compassSubscription = eventStream.listen(
      (event) {
        final headingValue = event.heading;
        if (!mounted || headingValue == null) return;
        setState(() {
          _heading = headingValue;
          _compassAvailable = true;
        });
      },
      onError: (_) {
        if (mounted) {
          setState(() => _compassAvailable = false);
        }
      },
    );
  }

  Future<void> _refreshAll() async {
    setState(() => _updating = true);
    await PrayerService.refreshPrayerData();
    _loadSettingsFromService();
    if (!mounted) return;
    setState(() {
      _updating = false;
      _now = DateTime.now();
    });
  }

  Future<void> _toggleAlerts(bool enabled) async {
    setState(() {
      _alertsEnabled = enabled;
      _updating = true;
    });
    await PrayerService.setAdhanAlertsEnabled(enabled);
    if (!mounted) return;
    setState(() => _updating = false);
  }

  Future<void> _selectAdhanMode(AdhanAlertMode mode) async {
    setState(() {
      _selectedMode = mode;
      _updating = true;
    });
    await PrayerService.setAdhanMode(mode);
    if (!mounted) return;
    setState(() => _updating = false);
  }

  Future<void> _togglePrayer(String prayerName, bool enabled) async {
    setState(() {
      _prayerToggles[prayerName] = enabled;
      _updating = true;
    });
    await PrayerService.setPrayerAlertEnabled(prayerName, enabled);
    if (!mounted) return;
    setState(() => _updating = false);
  }

  Future<void> _testAdhan() async {
    await PrayerService.playAdhanPreview();
    if (!mounted) return;
    final message = _selectedMode == AdhanAlertMode.fullAdhan && _alertsEnabled
        ? 'Playing adhan preview'
        : 'Switch to Full Adhan mode with alerts enabled to preview sound';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prayerTimesData = PrayerService.currentPrayerTimes;
    final nextPrayer = prayerTimesData?.getNextPrayer(now: _now);
    final currentPrayer = prayerTimesData?.getCurrentPrayer(now: _now);
    final schedule = prayerTimesData?.getAllPrayerTimes(now: _now) ?? const <PrayerTimeInfo>[];
    final timeUntilNext = prayerTimesData?.timeUntilNextPrayer(now: _now) ?? Duration.zero;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DecorativeBackdrop(
        child: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _refreshAll,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: 18),
                      _buildHeroCard(
                        context,
                        currentPrayer: currentPrayer,
                        nextPrayer: nextPrayer,
                        timeUntilNext: timeUntilNext,
                      ),
                      const SizedBox(height: 16),
                      _buildScheduleCard(
                        context,
                        schedule,
                        currentPrayer: currentPrayer,
                        nextPrayer: nextPrayer,
                      ),
                      const SizedBox(height: 16),
                      _buildQiblaCard(context),
                      const SizedBox(height: 16),
                      _buildAdhanSettingsCard(context),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Prayer Times', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(
                'A cleaner daily rhythm with the current prayer, next prayer, qibla, and alerts in one place.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        IconButton.filledTonal(
          onPressed: _updating ? null : _refreshAll,
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Refresh prayer data',
        ),
      ],
    );
  }

  Widget _buildHeroCard(
    BuildContext context, {
    required PrayerTimeInfo? currentPrayer,
    required PrayerTimeInfo? nextPrayer,
    required Duration timeUntilNext,
  }) {
    final qiblaDirection = LocationService.getQiblaDirection();
    final currentPrayerLabel = currentPrayer?.name ?? 'Before Fajr';
    final countdown = AppFormatters.countdown(timeUntilNext);

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
            Color(0xFF123C33),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.emerald.withValues(alpha: 0.28),
            blurRadius: 34,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _HeroBadge(label: 'Current: $currentPrayerLabel'),
              _HeroBadge(label: 'Qibla ${qiblaDirection.toStringAsFixed(0)}°'),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            nextPrayer?.name ?? 'Prayer data unavailable',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  height: 1,
                ),
          ),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: Text(
              nextPrayer == null
                  ? 'Refresh location and prayer access to continue.'
                  : '${AppFormatters.formatTime(nextPrayer.time)} • starts in $countdown',
              key: ValueKey<String>(
                nextPrayer == null ? 'prayer-empty' : '${nextPrayer.name}-$countdown',
              ),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.88),
                  ),
            ),
          ),
          if (nextPrayer != null) ...[
            const SizedBox(height: 14),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: _CountdownPill(
                key: ValueKey<String>('prayer-countdown-$countdown'),
                icon: Icons.timelapse_rounded,
                label: 'Begins in $countdown',
              ),
            ),
          ],
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _PrayerFocusPanel(
                  label: 'Current window',
                  title: currentPrayerLabel,
                  detail: currentPrayer == null
                      ? 'The next prayer will open the day.'
                      : 'Remain steady until ${AppFormatters.formatTime(nextPrayer?.time ?? currentPrayer.time)}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PrayerFocusPanel(
                  label: 'Next pause',
                  title: nextPrayer?.name ?? 'Unavailable',
                  detail: nextPrayer == null
                      ? 'Prayer data unavailable.'
                      : 'In $countdown',
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _PrayerMetric(
                  label: 'Today',
                  value: AppFormatters.formatDate(_now),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PrayerMetric(
                  label: 'Alerts',
                  value: _alertsEnabled ? 'Enabled' : 'Off',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PrayerMetric(
                  label: 'Compass',
                  value: _compassAvailable ? 'Live' : 'Unavailable',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(
    BuildContext context,
    List<PrayerTimeInfo> schedule, {
    required PrayerTimeInfo? currentPrayer,
    required PrayerTimeInfo? nextPrayer,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFECE2D3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Daily Schedule', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text(
                        'The current prayer anchors the day while the next pause stays gently highlighted.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _InfoPill(
                  label: nextPrayer == null
                      ? 'Waiting'
                      : 'Next ${nextPrayer.name}',
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (schedule.isEmpty)
              Text(
                'Prayer times are still loading.',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: schedule.asMap().entries.map((entry) {
                    return _buildScheduleRow(
                      context,
                      entry.value,
                      isLast: entry.key == schedule.length - 1,
                    );
                  }).toList(),
                ),
              ),
            if (currentPrayer != null) ...[
              const SizedBox(height: 14),
              Text(
                'Current prayer: ${currentPrayer.name} • ${AppFormatters.formatTime(currentPrayer.time)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.slate,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleRow(
    BuildContext context,
    PrayerTimeInfo prayer, {
    required bool isLast,
  }) {
    final hasPassed = prayer.time.isBefore(_now) && !prayer.isCurrent && !prayer.isNext;
    final accentColor = prayer.isCurrent
        ? AppColors.gold
        : prayer.isNext
            ? AppColors.emerald
            : hasPassed
                ? AppColors.slate
                : AppColors.moss;
    final backgroundColor = prayer.isCurrent
        ? const Color(0xFFF7ECD3)
        : prayer.isNext
            ? const Color(0xFFE4EFE7)
            : AppColors.white;

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                    boxShadow: prayer.isCurrent || prayer.isNext
                        ? [
                            BoxShadow(
                              color: accentColor.withValues(alpha: 0.24),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 78,
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE1D7C8),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: prayer.isCurrent || prayer.isNext
                      ? accentColor.withValues(alpha: 0.22)
                      : const Color(0xFFEAE0D0),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      _iconForPrayer(prayer.name),
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prayer.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.ink,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _statusLabel(prayer, hasPassed),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.slate,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        AppFormatters.formatTime(prayer.time),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      _StatusChip(label: _statusChipText(prayer, hasPassed)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQiblaCard(BuildContext context) {
    final qiblaDirection = LocationService.getQiblaDirection();
    final offset = ((_heading - qiblaDirection + 540) % 360) - 180;
    final aligned = offset.abs() <= 8;
    final guidance = aligned
        ? 'You are aligned with the qibla.'
        : offset > 0
            ? 'Turn ${offset.abs().toStringAsFixed(0)}° to the left.'
            : 'Turn ${offset.abs().toStringAsFixed(0)}° to the right.';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFECE2D3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Qibla', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              'A calmer directional view with clearer alignment guidance.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFF7F1E6),
                    Color(0xFFF1E9DB),
                  ],
                ),
                borderRadius: BorderRadius.circular(26),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 220,
                    child: _compassAvailable
                        ? QiblaCompass(
                            heading: _heading,
                            qiblaDirection: qiblaDirection,
                          )
                        : Center(
                            child: Text(
                              'Compass sensor unavailable on this device.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                  ),
                  const SizedBox(height: 14),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: aligned
                          ? AppColors.emerald.withValues(alpha: 0.10)
                          : AppColors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: aligned
                            ? AppColors.emerald.withValues(alpha: 0.24)
                            : const Color(0xFFE4D9C9),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          aligned
                              ? Icons.check_circle_rounded
                              : Icons.navigation_rounded,
                          color: aligned ? AppColors.emerald : AppColors.gold,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            guidance,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: [
                      _InfoPill(label: 'Heading ${_heading.toStringAsFixed(0)}°'),
                      _InfoPill(label: 'Qibla ${qiblaDirection.toStringAsFixed(0)}°'),
                      _InfoPill(label: aligned ? 'Aligned' : '${offset.abs().toStringAsFixed(0)}° off'),
                    ],
                  ),
                ],
              ),
            ),
            if (LocationService.currentPosition != null) ...[
              const SizedBox(height: 14),
              Text(
                'Lat ${LocationService.currentPosition!.latitude.toStringAsFixed(4)} • Lng ${LocationService.currentPosition!.longitude.toStringAsFixed(4)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAdhanSettingsCard(BuildContext context) {
    final selectedOption = PrayerService.adhanAlertOptions.firstWhere(
      (option) => option.mode == _selectedMode,
      orElse: () => PrayerService.adhanAlertOptions.first,
    );

    final orderedToggles = _orderedPrayerToggles();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFECE2D3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Prayer Alerts', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Quiet, configurable reminders that stay easy to understand.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _alertsEnabled ? 'Alerts enabled' : 'Alerts paused',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _alertsEnabled
                              ? selectedOption.title
                              : 'Turn alerts on to receive prayer reminders.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: _alertsEnabled,
                    onChanged: _updating ? null : _toggleAlerts,
                  ),
                ],
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              child: !_alertsEnabled
                  ? const SizedBox.shrink()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        SegmentedButton<AdhanAlertMode>(
                          showSelectedIcon: false,
                          segments: PrayerService.adhanAlertOptions
                              .map(
                                (option) => ButtonSegment<AdhanAlertMode>(
                                  value: option.mode,
                                  label: Text(option.title),
                                ),
                              )
                              .toList(),
                          selected: <AdhanAlertMode>{_selectedMode},
                          onSelectionChanged: _updating
                              ? null
                              : (selection) {
                                  if (selection.isNotEmpty) {
                                    _selectAdhanMode(selection.first);
                                  }
                                },
                        ),
                        const SizedBox(height: 10),
                        Text(
                          selectedOption.subtitle,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: orderedToggles.map((entry) {
                            return FilterChip(
                              label: Text(entry.key),
                              selected: entry.value,
                              onSelected: _updating
                                  ? null
                                  : (value) => _togglePrayer(entry.key, value),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _updating ? null : _testAdhan,
                          icon: const Icon(Icons.volume_up_rounded),
                          label: const Text('Test adhan'),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<MapEntry<String, bool>> _orderedPrayerToggles() {
    const prayerOrder = <String>['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    final entries = _prayerToggles.entries.toList();
    entries.sort((left, right) {
      final leftIndex = prayerOrder.indexOf(left.key);
      final rightIndex = prayerOrder.indexOf(right.key);
      return leftIndex.compareTo(rightIndex);
    });
    return entries;
  }

  IconData _iconForPrayer(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return Icons.wb_twilight_rounded;
      case 'dhuhr':
        return Icons.wb_sunny_rounded;
      case 'asr':
        return Icons.wb_cloudy_rounded;
      case 'maghrib':
        return Icons.nights_stay_rounded;
      case 'isha':
        return Icons.dark_mode_rounded;
      default:
        return Icons.access_time_rounded;
    }
  }

  String _statusLabel(PrayerTimeInfo prayer, bool hasPassed) {
    if (prayer.isCurrent) {
      return 'Current prayer window';
    }
    if (prayer.isNext) {
      return 'Up next';
    }
    if (hasPassed) {
      return 'Completed today';
    }
    return 'Later today';
  }

  String _statusChipText(PrayerTimeInfo prayer, bool hasPassed) {
    if (prayer.isCurrent) return 'Current';
    if (prayer.isNext) return 'Next';
    if (hasPassed) return 'Done';
    return 'Upcoming';
  }
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Text(
        label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.86),
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _PrayerMetric extends StatelessWidget {
  const _PrayerMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _CountdownPill extends StatelessWidget {
  const _CountdownPill({
    super.key,
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _PrayerFocusPanel extends StatelessWidget {
  const _PrayerFocusPanel({
    required this.label,
    required this.title,
    required this.detail,
  });

  final String label;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
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
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            detail,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.84),
                ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE5DAC8)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
