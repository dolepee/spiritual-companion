import 'package:flutter/material.dart';
import '../services/quran_service.dart';
import '../models/quran.dart';
import '../widgets/quran_page_viewer.dart';
import '../widgets/surah_list.dart';

class QuranScreen extends StatefulWidget {
  final Surah? initialSurah;

  const QuranScreen({super.key, this.initialSurah});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  int _currentPage = 1;
  bool _showSurahList = false;

  @override
  void initState() {
    super.initState();
    _currentPage = QuranService.currentPage;
    if (widget.initialSurah != null) {
      _currentPage = widget.initialSurah!.ayahs.first.page;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_showSurahList ? 'Surahs' : 'Quran'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: Icon(_showSurahList ? Icons.book : Icons.list),
            onPressed: () {
              setState(() {
                _showSurahList = !_showSurahList;
              });
            },
          ),
        ],
      ),
      body: _showSurahList ? _buildSurahList() : _buildQuranViewer(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSurahList() {
    return const SurahList();
  }

  Widget _buildQuranViewer() {
    if (QuranService.quranData == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Column(
      children: [
        Expanded(
          child: QuranPageViewer(pageNumber: _currentPage),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    if (_showSurahList) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _currentPage > 1
                ? () => setState(() => _currentPage--)
                : null,
            icon: const Icon(Icons.keyboard_arrow_left),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Page $_currentPage',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                'of ${QuranService.getTotalPages()}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          IconButton(
            onPressed: _currentPage < QuranService.getTotalPages()
                ? () => setState(() => _currentPage++)
                : null,
            icon: const Icon(Icons.keyboard_arrow_right),
          ),
        ],
      ),
    );
  }
}