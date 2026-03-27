import 'package:flutter/material.dart';

import '../app_formatters.dart';
import '../app_theme.dart';
import '../services/app_preferences_service.dart';
import '../services/prayer_service.dart';
import '../services/quran_service.dart';
import '../widgets/decorative_backdrop.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _hapticsEnabled;
  late bool _alertsEnabled;
  late AdhanAlertMode _adhanMode;
  late String _selectedFontId;
  late String _selectedReciterId;

  @override
  void initState() {
    super.initState();
    _syncState();
  }

  void _syncState() {
    _hapticsEnabled = AppPreferencesService.hapticsEnabled;
    _alertsEnabled = PrayerService.adhanAlertsEnabled;
    _adhanMode = PrayerService.adhanMode;
    _selectedFontId = QuranService.selectedFontOption.id;
    _selectedReciterId = QuranService.selectedReciterOption.id;
  }

  Future<void> _setHaptics(bool value) async {
    await AppPreferencesService.setHapticsEnabled(value);
    if (mounted) {
      setState(() => _hapticsEnabled = value);
    }
  }

  Future<void> _setAlerts(bool value) async {
    await PrayerService.setAdhanAlertsEnabled(value);
    if (mounted) {
      setState(() => _alertsEnabled = value);
    }
  }

  Future<void> _setAdhanMode(AdhanAlertMode mode) async {
    await PrayerService.setAdhanMode(mode);
    if (mounted) {
      setState(() => _adhanMode = mode);
    }
  }

  Future<void> _setFont(String? fontId) async {
    if (fontId == null) return;
    await QuranService.setSelectedFont(fontId);
    if (mounted) {
      setState(() => _selectedFontId = fontId);
    }
  }

  Future<void> _setReciter(String? reciterId) async {
    if (reciterId == null) return;
    await QuranService.setSelectedReciter(reciterId);
    if (mounted) {
      setState(() => _selectedReciterId = reciterId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookmarks = QuranService.bookmarkedPages.length;

    return DecorativeBackdrop(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tune recitation, alerts, and comfort preferences without clutter.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.slate,
                        ),
                  ),
                  const SizedBox(height: 20),
                  _buildSummaryCard(bookmarks),
                  const SizedBox(height: 16),
                  _buildReaderCard(),
                  const SizedBox(height: 16),
                  _buildAlertsCard(),
                  const SizedBox(height: 16),
                  _buildComfortCard(),
                  const SizedBox(height: 16),
                  _buildAboutCard(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(int bookmarks) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.emerald.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.tune_rounded, color: AppColors.emerald),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Companion Preferences',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Keep the app calm, personal, and useful.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _StatPill(label: 'Current Page', value: '${QuranService.currentPage}'),
                const SizedBox(width: 10),
                _StatPill(label: 'Bookmarks', value: '$bookmarks'),
                const SizedBox(width: 10),
                _StatPill(
                  label: 'Alerts',
                  value: _alertsEnabled ? 'On' : 'Off',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReaderCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quran Reader', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Refine the reading surface, reciter, and resume flow.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 18),
            DropdownButtonFormField<String>(
              value: _selectedFontId,
              decoration: const InputDecoration(labelText: 'Arabic font'),
              items: QuranService.fontOptions
                  .map(
                    (option) => DropdownMenuItem<String>(
                      value: option.id,
                      child: Text(option.label),
                    ),
                  )
                  .toList(),
              onChanged: _setFont,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _selectedReciterId,
              decoration: const InputDecoration(labelText: 'Preferred reciter'),
              items: QuranService.reciterOptions
                  .map(
                    (option) => DropdownMenuItem<String>(
                      value: option.id,
                      child: Text(option.name),
                    ),
                  )
                  .toList(),
              onChanged: _setReciter,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Prayer Alerts', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Choose a prayer-alert style that fits your day.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: _alertsEnabled,
              onChanged: _setAlerts,
              title: const Text('Enable prayer alerts'),
              subtitle: Text(
                _alertsEnabled
                    ? 'Notifications and adhan reminders stay active.'
                    : 'Prayer alerts are currently silent.',
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
              selected: {_adhanMode},
              onSelectionChanged: _alertsEnabled
                  ? (value) => _setAdhanMode(value.first)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComfortCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Comfort', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Subtle feedback should support calmness, not distract from it.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: _hapticsEnabled,
              onChanged: _setHaptics,
              title: const Text('Haptic feedback'),
              subtitle: const Text('Used for tasbih taps and gentle confirmations.'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This Build', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Current reading page: ${QuranService.currentPage}\n'
              'Preferred reciter: ${QuranService.selectedReciterOption.name}\n'
              'Updated: ${AppFormatters.formatDate(DateTime.now())}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE6DDCE)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
