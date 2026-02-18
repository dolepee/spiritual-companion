import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
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
  String _selectedFontId = QuranService.selectedFontOption.id;
  String _selectedReciterId = QuranService.selectedReciterOption.id;
  bool _audioBusy = false;
  bool _isAudioPlaying = QuranService.isAudioPlaying;
  int? _playingSurah = QuranService.playingSurah;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  @override
  void initState() {
    super.initState();
    _currentPage = QuranService.currentPage;
    _loadStateFromService();
    _playerStateSubscription = QuranService.playerStateStream.listen((_) {
      if (!mounted) return;
      setState(_loadStateFromService);
    });
    if (widget.initialSurah != null) {
      _currentPage = widget.initialSurah!.ayahs.first.page;
    }
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    super.dispose();
  }

  void _loadStateFromService() {
    _isAudioPlaying = QuranService.isAudioPlaying;
    _playingSurah = QuranService.playingSurah;
    _selectedFontId = QuranService.selectedFontOption.id;
    _selectedReciterId = QuranService.selectedReciterOption.id;
  }

  Future<void> _changeFont(String? fontId) async {
    if (fontId == null) return;
    await QuranService.setSelectedFont(fontId);
    if (mounted) {
      setState(_loadStateFromService);
    }
  }

  Future<void> _changeReciter(String? reciterId) async {
    if (reciterId == null) return;
    await QuranService.stopAudio();
    await QuranService.setSelectedReciter(reciterId);
    if (mounted) {
      setState(_loadStateFromService);
    }
  }

  Future<void> _toggleAudio() async {
    final surahNumber = QuranService.getPrimarySurahForPage(_currentPage);
    if (surahNumber == null) return;

    setState(() => _audioBusy = true);
    try {
      await QuranService.playSurahAudio(surahNumber);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to stream this reciter now. Check internet and try again.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _audioBusy = false);
      }
    }
  }

  Future<void> _stopAudio() async {
    setState(() => _audioBusy = true);
    await QuranService.stopAudio();
    if (mounted) {
      setState(() => _audioBusy = false);
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

    final currentSurah = QuranService.getPrimarySurahForPage(_currentPage);
    final currentSurahName =
        currentSurah == null ? 'Unknown' : QuranService.getSurahName(currentSurah);
    final isPlayingCurrentSurah = _isAudioPlaying && _playingSurah == currentSurah;

    return Column(
      children: [
        Card(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recitation & Display',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedFontId,
                  decoration: const InputDecoration(
                    labelText: 'Quran font',
                    border: OutlineInputBorder(),
                  ),
                  items: QuranService.fontOptions
                      .map(
                        (option) => DropdownMenuItem<String>(
                          value: option.id,
                          child: Text(option.label),
                        ),
                      )
                      .toList(),
                  onChanged: _changeFont,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedReciterId,
                  decoration: const InputDecoration(
                    labelText: 'Reciter (MP3)',
                    border: OutlineInputBorder(),
                  ),
                  items: QuranService.reciterOptions
                      .map(
                        (option) => DropdownMenuItem<String>(
                          value: option.id,
                          child: Text(option.name),
                        ),
                      )
                      .toList(),
                  onChanged: _changeReciter,
                ),
                const SizedBox(height: 12),
                Text(
                  'Current surah on page: $currentSurahName',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: currentSurah == null || _audioBusy ? null : _toggleAudio,
                        icon: Icon(
                          isPlayingCurrentSurah ? Icons.pause : Icons.play_arrow,
                        ),
                        label: Text(
                          isPlayingCurrentSurah ? 'Pause Recitation' : 'Play Recitation',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: _audioBusy ? null : _stopAudio,
                      icon: const Icon(Icons.stop),
                      label: const Text('Stop'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: QuranPageViewer(
            pageNumber: _currentPage,
            arabicFontFamily: QuranService.selectedFontOption.fontFamily,
          ),
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
