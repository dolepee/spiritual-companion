import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import '../services/location_service.dart';
import '../services/prayer_service.dart';
import '../widgets/prayer_times_list.dart';
import '../widgets/qibla_compass.dart';

class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  StreamSubscription<CompassEvent>? _compassSubscription;
  double _heading = 0;
  bool _compassAvailable = false;
  bool _loading = true;
  bool _updating = false;

  bool _alertsEnabled = true;
  AdhanAlertMode _selectedMode = AdhanAlertMode.fullAdhan;
  Map<String, bool> _prayerToggles = {};

  @override
  void initState() {
    super.initState();
    _loadSettingsFromService();
    _initializeScreen();
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeScreen() async {
    setState(() => _loading = true);
    await PrayerService.refreshPrayerData();
    _listenToCompass();
    _loadSettingsFromService();
    if (mounted) {
      setState(() => _loading = false);
    }
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
    if (mounted) {
      setState(() => _updating = false);
    }
  }

  Future<void> _toggleAlerts(bool enabled) async {
    setState(() {
      _alertsEnabled = enabled;
      _updating = true;
    });
    await PrayerService.setAdhanAlertsEnabled(enabled);
    if (mounted) {
      setState(() => _updating = false);
    }
  }

  Future<void> _selectAdhanMode(AdhanAlertMode mode) async {
    setState(() {
      _selectedMode = mode;
      _updating = true;
    });
    await PrayerService.setAdhanMode(mode);
    if (mounted) {
      setState(() => _updating = false);
    }
  }

  Future<void> _togglePrayer(String prayerName, bool enabled) async {
    setState(() {
      _prayerToggles[prayerName] = enabled;
      _updating = true;
    });
    await PrayerService.setPrayerAlertEnabled(prayerName, enabled);
    if (mounted) {
      setState(() => _updating = false);
    }
  }

  Future<void> _testAdhan() async {
    await PrayerService.playAdhanPreview();
    if (!mounted) return;
    if (_selectedMode == AdhanAlertMode.fullAdhan && _alertsEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Playing adhan preview')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Switch to Full Adhan mode and keep alerts enabled to test sound'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prayer Times'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            onPressed: _updating ? null : _refreshAll,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh prayer data',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshAll,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildLocationInfo(),
                  const SizedBox(height: 16),
                  _buildQiblaCompass(),
                  const SizedBox(height: 16),
                  _buildAdhanSettingsCard(),
                  const SizedBox(height: 16),
                  const PrayerTimesList(),
                ],
              ),
            ),
    );
  }

  Widget _buildAdhanSettingsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Adhan Alerts',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              value: _alertsEnabled,
              onChanged: _updating ? null : _toggleAlerts,
              contentPadding: EdgeInsets.zero,
              title: const Text('Enable prayer alerts'),
              subtitle: const Text('Receive call-to-prayer notifications'),
            ),
            if (_alertsEnabled) ...[
              const Divider(),
              Text(
                'Alert style',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
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
                selected: {_selectedMode},
                onSelectionChanged: _updating
                    ? null
                    : (selection) {
                        if (selection.isNotEmpty) {
                          _selectAdhanMode(selection.first);
                        }
                      },
              ),
              const SizedBox(height: 8),
              Text(
                PrayerService.adhanAlertOptions
                    .firstWhere((item) => item.mode == _selectedMode)
                    .subtitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Divider(),
              Text(
                'Enable by prayer',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              ..._prayerToggles.entries.map(
                (entry) => SwitchListTile(
                  value: entry.value,
                  onChanged: _updating
                      ? null
                      : (value) => _togglePrayer(entry.key, value),
                  contentPadding: EdgeInsets.zero,
                  title: Text(entry.key),
                ),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: _updating ? null : _testAdhan,
                icon: const Icon(Icons.volume_up),
                label: const Text('Test Adhan'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInfo() {
    if (LocationService.currentPosition == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(Icons.location_on, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Location not available. Enable location and refresh.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final position = LocationService.currentPosition!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Your Location',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQiblaCompass() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Qibla Direction',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: _compassAvailable
                  ? QiblaCompass(
                      heading: _heading,
                      qiblaDirection: LocationService.getQiblaDirection(),
                    )
                  : Center(
                      child: Text(
                        'Compass sensor unavailable on this device',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
            ),
            const SizedBox(height: 8),
            Text(
              'Heading: ${_heading.toStringAsFixed(0)}°  •  Qibla: ${LocationService.getQiblaDirection().toStringAsFixed(0)}°',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
