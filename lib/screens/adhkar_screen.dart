import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AdhkarScreen extends StatefulWidget {
  const AdhkarScreen({super.key});

  @override
  State<AdhkarScreen> createState() => _AdhkarScreenState();
}

class _AdhkarScreenState extends State<AdhkarScreen> with TickerProviderStateMixin {
  String _adhkarContent = '';
  bool _isLoading = true;
  late TabController _tabController;

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
      final String content = await rootBundle.loadString('assets/adhkar.txt');
      setState(() {
        _adhkarContent = content;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _adhkarContent = 'Error loading Adhkar content. Please check if the assets/adhkar.txt file exists.';
        _isLoading = false;
      });
    }
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
          indicatorColor: Theme.of(context).colorScheme.onPrimary,
          labelColor: Theme.of(context).colorScheme.onPrimary,
          unselectedLabelColor: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
          tabs: const [
            Tab(text: 'Morning'),
            Tab(text: 'Evening'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildAdhkarContent('Morning Adhkar', _getMorningAdhkar()),
                _buildAdhkarContent('Evening Adhkar', _getEveningAdhkar()),
              ],
            ),
    );
  }

  Widget _buildAdhkarContent(String title, List<String> adhkarList) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    Icons.wb_sunny,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...adhkarList.asMap().entries.map((entry) {
            final index = entry.key;
            final adhkar = entry.value;
            return _buildAdhkarCard(index + 1, adhkar);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildAdhkarCard(int number, String adhkar) {
    // Split Arabic text from transliteration
    String arabicText = adhkar;
    String? transliteration;
    final transIndex = adhkar.indexOf('TRANSLITERATION:');
    if (transIndex != -1) {
      arabicText = adhkar.substring(0, transIndex).trim();
      transliteration = adhkar.substring(transIndex + 'TRANSLITERATION:'.length).trim();
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Text(
                      '$number',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    arabicText,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 18,
                          height: 1.8,
                          fontFamily: 'Amiri',
                        ),
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            if (transliteration != null) ...[
              const Divider(height: 20),
              Text(
                transliteration,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 13,
                      height: 1.5,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                    ),
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.left,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    _copyToClipboard(adhkar);
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<String> _parseSection(String sectionHeader) {
    try {
      if (_adhkarContent.isEmpty) return [];
      final sections = _adhkarContent.split(RegExp(r'^# ', multiLine: true));
      for (final section in sections) {
        if (section.trim().startsWith(sectionHeader)) {
          final content = section.substring(section.indexOf('\n') + 1).trim();
          if (content.isEmpty) continue;
          // Split by numbered entries (lines starting with "1. ", "2. ", etc.)
          final entries = content.split(RegExp(r'\n(?=\d+\.\s)', multiLine: true));
          final result = entries
              .map((entry) => entry.replaceFirst(RegExp(r'^\d+\.\s*'), '').trim())
              .where((entry) => entry.isNotEmpty)
              .toList();
          if (result.isNotEmpty) return result;
        }
      }
    } catch (_) {}
    return [];
  }

  List<String> _getMorningAdhkar() {
    final parsed = _parseSection('Morning Adhkar');
    if (parsed.isNotEmpty) return parsed;
    return [
      'أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ',
      'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
      'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
      'اللَّهُمَّ بِكَ أَصْبَحْنَا وَبِكَ أَمْسَيْنَا',
      'اللَّهُمَّ أَنْتَ رَبُّنَا لَا إِلَهَ إِلَّا أَنْتَ',
      'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ عَدَدَ خَلْقِهِ',
      'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَافِيَةَ',
      'رَضِيتُ بِاللَّهِ رَبًّا وَبِالْإِسْلَامِ دِينًا',
      'حَسْبِيَ اللَّهُ لَا إِلَهَ إِلَّا هُوَ',
      'اللَّهُمَّ عَافِنِي فِي بَدَنِي',
    ];
  }

  List<String> _getEveningAdhkar() {
    final parsed = _parseSection('Evening Adhkar');
    if (parsed.isNotEmpty) return parsed;
    return [
      'أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ',
      'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
      'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
      'اللَّهُمَّ بِكَ أَمْسَيْنَا وَبِكَ أَصْبَحْنَا',
      'اللَّهُمَّ أَنْتَ رَبُّنَا لَا إِلَهَ إِلَّا أَنْتَ',
      'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ عَدَدَ خَلْقِهِ',
      'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَافِيَةَ',
      'رَضِيتُ بِاللَّهِ رَبًّا وَبِالْإِسْلَامِ دِينًا',
      'حَسْبِيَ اللَّهُ لَا إِلَهَ إِلَّا هُوَ',
      'اللَّهُمَّ عَافِنِي فِي بَدَنِي',
    ];
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Adhkar copied to clipboard')),
    );
  }
}