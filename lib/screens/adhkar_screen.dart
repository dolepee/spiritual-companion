import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_theme.dart';
import '../widgets/decorative_backdrop.dart';

class AdhkarItem {
  const AdhkarItem({
    required this.duaId,
    required this.title,
    required this.arabic,
    required this.transcription,
    required this.english,
    required this.reference,
    required this.repeatCount,
    required this.category,
    required this.uncertain,
    required this.sourceIndex,
    required this.notes,
  });

  final String duaId;
  final String title;
  final String arabic;
  final String transcription;
  final String english;
  final String reference;
  final String repeatCount;
  final String category;
  final bool uncertain;
  final int? sourceIndex;
  final String notes;

  factory AdhkarItem.fromJson(Map<String, dynamic> json) {
    return AdhkarItem(
      duaId: _asString(json['duaId'], fallback: 'Dua'),
      title: _asString(json['title']),
      arabic: _asString(json['arabic']),
      transcription: _asString(json['transcription']),
      english: _asString(json['english']),
      reference: _asString(json['reference']),
      repeatCount: _asString(json['repeatCount']),
      category: _asString(json['category']),
      uncertain: json['uncertain'] == true,
      sourceIndex: _asInt(json['sourceIndex']),
      notes: _asString(json['notes']),
    );
  }

  static String _asString(dynamic value, {String fallback = ''}) {
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? fallback : trimmed;
    }
    return fallback;
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value.trim());
    return null;
  }
}

class AdhkarScreen extends StatefulWidget {
  const AdhkarScreen({
    super.key,
    this.assetBundle,
  });

  final AssetBundle? assetBundle;

  @override
  State<AdhkarScreen> createState() => _AdhkarScreenState();
}

class _AdhkarScreenState extends State<AdhkarScreen>
    with TickerProviderStateMixin {
  static const String _completedKey = 'adhkar_completed_entries';

  late TabController _tabController;
  final Map<String, GlobalKey> _entryKeys = <String, GlobalKey>{};

  bool _isLoading = true;
  String? _errorMessage;

  String _title = 'Words of remembrance for morning and evening';
  List<AdhkarItem> _morningAdhkar = const [];
  List<AdhkarItem> _eveningAdhkar = const [];

  bool _showArabic = true;
  bool _showTranscription = true;
  bool _showEnglish = true;
  bool _showReference = true;
  Set<String> _completedEntries = <String>{};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCompletionState();
    _loadAdhkarContent();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCompletionState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _completedEntries = (prefs.getStringList(_completedKey) ?? const <String>[]).toSet();
    });
  }

  Future<void> _saveCompletionState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _completedKey,
      _completedEntries.toList()..sort(),
    );
  }

  Future<void> _loadAdhkarContent() async {
    try {
      final raw = await (widget.assetBundle ?? rootBundle)
          .loadString('assets/adhkar_data.json');
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Invalid adhkar data format');
      }

      final morning = _parseAdhkarList(decoded['morning']);
      final evening = _parseAdhkarList(decoded['evening']);

      setState(() {
        _title = (decoded['title'] is String &&
                (decoded['title'] as String).trim().isNotEmpty)
            ? (decoded['title'] as String).trim()
            : 'Words of remembrance for morning and evening';
        _morningAdhkar = morning;
        _eveningAdhkar = evening;
        _isLoading = false;
        _errorMessage = (morning.isEmpty && evening.isEmpty)
            ? 'No adhkar entries found. Check assets/adhkar_data.json.'
            : null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Error loading Adhkar content. Check assets/adhkar_data.json.';
      });
    }
  }

  List<AdhkarItem> _parseAdhkarList(dynamic rawList) {
    if (rawList is! List) return const [];
    final result = <AdhkarItem>[];
    for (final item in rawList) {
      if (item is Map<String, dynamic>) {
        result.add(AdhkarItem.fromJson(item));
      } else if (item is Map) {
        result.add(AdhkarItem.fromJson(Map<String, dynamic>.from(item)));
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Adhkar'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Morning'),
            Tab(text: 'Evening'),
          ],
        ),
      ),
      body: DecorativeBackdrop(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  _loadAdhkarContent();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildSection(
          sectionKey: 'morning',
          sectionTitle: 'Morning Adhkar',
          icon: Icons.wb_sunny_outlined,
          items: _morningAdhkar,
        ),
        _buildSection(
          sectionKey: 'evening',
          sectionTitle: 'Evening Adhkar',
          icon: Icons.nightlight_round,
          items: _eveningAdhkar,
        ),
      ],
    );
  }

  Widget _buildSection({
    required String sectionKey,
    required String sectionTitle,
    required IconData icon,
    required List<AdhkarItem> items,
  }) {
    final completedCount = items
        .where((item) => _completedEntries.contains(_entryKey(sectionKey, item)))
        .length;
    final progress = items.isEmpty ? 0.0 : completedCount / items.length;
    final nextUnread = _nextUnreadItem(sectionKey, items);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        icon,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          sectionTitle,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryPill(
                          label: 'Entries',
                          value: items.length.toString(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _SummaryPill(
                          label: 'Completed',
                          value: '$completedCount / ${items.length}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 7,
                      backgroundColor: Colors.white.withValues(alpha: 0.16),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.gold,
                      ),
                    ),
                  ),
                  if (nextUnread != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.play_circle_outline_rounded,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Next unread: ${nextUnread.title.isEmpty ? 'Adhkar' : nextUnread.title}',
                              style:
                                  Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimaryContainer,
                                      ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () => _jumpToEntry(sectionKey, nextUnread),
                            child: const Text('Continue'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildOptionsStrip(),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No entries available in this section yet.'),
              ),
            ),
          ...items.map((item) => _buildAdhkarCard(sectionKey, item)),
        ],
      ),
    );
  }

  Widget _buildOptionsStrip() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE9E0D2)),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _buildOptionChip(
            label: 'Arabic',
            value: _showArabic,
            onChanged: (value) => setState(() => _showArabic = value),
          ),
          _buildOptionChip(
            label: 'Transcription',
            value: _showTranscription,
            onChanged: (value) => setState(() => _showTranscription = value),
          ),
          _buildOptionChip(
            label: 'English',
            value: _showEnglish,
            onChanged: (value) => setState(() => _showEnglish = value),
          ),
          _buildOptionChip(
            label: 'Reference',
            value: _showReference,
            onChanged: (value) => setState(() => _showReference = value),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionChip({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return FilterChip(
      label: Text(label),
      selected: value,
      onSelected: onChanged,
      showCheckmark: false,
    );
  }

  Widget _buildAdhkarCard(String sectionKey, AdhkarItem item) {
    final completed = _completedEntries.contains(_entryKey(sectionKey, item));
    final visibleFieldCount = [
      _showArabic && item.arabic.isNotEmpty,
      _showTranscription && item.transcription.isNotEmpty,
      _showEnglish && item.english.isNotEmpty,
      _showReference && item.reference.isNotEmpty,
    ].where((isVisible) => isVisible).length;

    return Card(
      key: _entryCardKey(sectionKey, item),
      margin: const EdgeInsets.only(bottom: 12),
      color: completed ? const Color(0xFFF3F8F5) : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              height: 4,
              width: double.infinity,
              decoration: BoxDecoration(
                color: completed
                    ? AppColors.emerald
                    : item.repeatCount.isNotEmpty
                        ? AppColors.gold.withValues(alpha: 0.82)
                        : const Color(0xFFE8DDD0),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title.isEmpty ? 'Adhkar' : item.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (item.repeatCount.isNotEmpty || item.uncertain || completed) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (item.repeatCount.isNotEmpty)
                        Chip(
                          label: Text('Repeat: ${item.repeatCount}'),
                          visualDensity: VisualDensity.compact,
                        ),
                      if (completed)
                        const Chip(
                          avatar: Icon(Icons.check_circle_rounded, size: 18),
                          label: Text('Completed'),
                          visualDensity: VisualDensity.compact,
                        ),
                      if (item.uncertain)
                        const Chip(
                          avatar: Icon(Icons.warning_amber_rounded, size: 18),
                          label: Text('Needs review'),
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            if (item.uncertain && item.notes.isNotEmpty) ...[
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item.notes,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                ),
              ),
            ],
            if (visibleFieldCount == 0)
              const Text(
                  'Enable at least one option box to display the content.'),
            if (_showArabic && item.arabic.isNotEmpty)
              _buildFieldSection(
                label: 'Arabic',
                value: item.arabic,
                isArabic: true,
              ),
            if (_showTranscription && item.transcription.isNotEmpty)
              _buildFieldSection(
                label: 'Transcription',
                value: item.transcription,
              ),
            if (_showEnglish && item.english.isNotEmpty)
              _buildFieldSection(
                label: 'English',
                value: item.english,
              ),
            if (_showReference && item.reference.isNotEmpty)
              _buildFieldSection(
                label: 'Reference',
                value: item.reference,
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _toggleCompleted(sectionKey, item),
                    icon: Icon(
                      completed ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                    ),
                    label: Text(completed ? 'Completed' : 'Mark complete'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    key: ValueKey<String>('adhkar-copy-${item.duaId}'),
                    onPressed: () => _copyToClipboard(item),
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleCompleted(String sectionKey, AdhkarItem item) async {
    final key = _entryKey(sectionKey, item);
    setState(() {
      if (_completedEntries.contains(key)) {
        _completedEntries.remove(key);
      } else {
        _completedEntries.add(key);
      }
    });
    await _saveCompletionState();
  }

  AdhkarItem? _nextUnreadItem(String sectionKey, List<AdhkarItem> items) {
    for (final item in items) {
      if (!_completedEntries.contains(_entryKey(sectionKey, item))) {
        return item;
      }
    }
    return null;
  }

  GlobalKey _entryCardKey(String sectionKey, AdhkarItem item) {
    final key = _entryKey(sectionKey, item);
    return _entryKeys.putIfAbsent(key, GlobalKey.new);
  }

  Future<void> _jumpToEntry(String sectionKey, AdhkarItem item) async {
    final targetContext = _entryCardKey(sectionKey, item).currentContext;
    if (targetContext == null) return;
    await Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      alignment: 0.08,
    );
  }

  String _entryKey(String sectionKey, AdhkarItem item) {
    return '$sectionKey:${item.duaId}';
  }

  Widget _buildFieldSection({
    required String label,
    required String value,
    bool isArabic = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.slate,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            textAlign: isArabic ? TextAlign.right : TextAlign.left,
            style: isArabic
                ? Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontFamily: 'Amiri',
                      fontSize: 20,
                      height: 1.7,
                    )
                : Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(AdhkarItem item) {
    final text = _formatAdhkarForCopy(item);
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Adhkar copied to clipboard')),
    );
  }

  String _formatAdhkarForCopy(AdhkarItem item) {
    final buffer = StringBuffer();
    buffer.writeln(item.title.isEmpty ? 'Adhkar' : item.title);
    buffer.writeln();
    if (item.arabic.isNotEmpty) {
      buffer.writeln('Arabic:');
      buffer.writeln(item.arabic);
      buffer.writeln();
    }
    if (item.repeatCount.isNotEmpty) {
      buffer.writeln('Repeat: ${item.repeatCount}');
      buffer.writeln();
    }
    if (item.transcription.isNotEmpty) {
      buffer.writeln('Transcription:');
      buffer.writeln(item.transcription);
      buffer.writeln();
    }
    if (item.english.isNotEmpty) {
      buffer.writeln('English:');
      buffer.writeln(item.english);
      buffer.writeln();
    }
    if (item.reference.isNotEmpty) {
      buffer.writeln('Reference:');
      buffer.writeln(item.reference);
      buffer.writeln();
    }
    if (item.uncertain && item.notes.isNotEmpty) {
      buffer.writeln('Review note:');
      buffer.writeln(item.notes);
    }
    return buffer.toString().trim();
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.74),
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                ),
          ),
        ],
      ),
    );
  }
}
