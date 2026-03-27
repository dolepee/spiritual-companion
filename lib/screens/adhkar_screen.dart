import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  late TabController _tabController;

  bool _isLoading = true;
  String? _errorMessage;

  String _title = 'Words of remembrance for morning and evening';
  List<AdhkarItem> _morningAdhkar = const [];
  List<AdhkarItem> _eveningAdhkar = const [];

  bool _showArabic = true;
  bool _showTranscription = true;
  bool _showEnglish = true;
  bool _showReference = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAdhkarContent();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
      appBar: AppBar(
        title: const Text('Adhkar'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Morning'),
            Tab(text: 'Evening'),
          ],
        ),
      ),
      body: _buildBody(),
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
          sectionTitle: 'Morning Adhkar',
          icon: Icons.wb_sunny_outlined,
          items: _morningAdhkar,
        ),
        _buildSection(
          sectionTitle: 'Evening Adhkar',
          icon: Icons.nightlight_round,
          items: _eveningAdhkar,
        ),
      ],
    );
  }

  Widget _buildSection({
    required String sectionTitle,
    required IconData icon,
    required List<AdhkarItem> items,
  }) {
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
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildOptionsCard(),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No entries available in this section yet.'),
              ),
            ),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return _buildAdhkarCard(index + 1, item);
          }),
        ],
      ),
    );
  }

  Widget _buildOptionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Option Boxes',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildOptionBox(
                  label: 'Arabic',
                  value: _showArabic,
                  onChanged: (value) => setState(() => _showArabic = value),
                ),
                _buildOptionBox(
                  label: 'Transcription',
                  value: _showTranscription,
                  onChanged: (value) =>
                      setState(() => _showTranscription = value),
                ),
                _buildOptionBox(
                  label: 'English',
                  value: _showEnglish,
                  onChanged: (value) => setState(() => _showEnglish = value),
                ),
                _buildOptionBox(
                  label: 'Reference',
                  value: _showReference,
                  onChanged: (value) => setState(() => _showReference = value),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionBox({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: value
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
          ),
          color: value
              ? Theme.of(context).colorScheme.primaryContainer
              : Colors.transparent,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: value,
              visualDensity: VisualDensity.compact,
              onChanged: (checked) => onChanged(checked ?? false),
            ),
            Text(label),
          ],
        ),
      ),
    );
  }

  Widget _buildAdhkarCard(int number, AdhkarItem item) {
    final visibleFieldCount = [
      _showArabic && item.arabic.isNotEmpty,
      _showTranscription && item.transcription.isNotEmpty,
      _showEnglish && item.english.isNotEmpty,
      _showReference && item.reference.isNotEmpty,
    ].where((isVisible) => isVisible).length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    '$number',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title.isEmpty
                            ? item.duaId
                            : '${item.duaId} — ${item.title}',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      if (item.repeatCount.isNotEmpty || item.uncertain) ...[
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
                ),
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
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                key: ValueKey<String>('adhkar-copy-${item.duaId}'),
                onPressed: () => _copyToClipboard(item),
                icon: const Icon(Icons.copy),
                label: const Text('Copy'),
              ),
            ),
          ],
        ),
      ),
    );
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
    buffer.writeln(
        item.title.isEmpty ? item.duaId : '${item.duaId} — ${item.title}');
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
