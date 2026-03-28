import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../app_theme.dart';
import '../models/quran.dart';
import '../services/quran_service.dart';
import '../widgets/decorative_backdrop.dart';
import '../widgets/quran_page_viewer.dart';
import '../widgets/surah_list.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key, this.initialSurah});

  final Surah? initialSurah;

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  late final PageController _pageController;

  int _currentPage = 1;
  String _selectedFontId = QuranService.selectedFontOption.id;
  String _selectedReciterId = QuranService.selectedReciterOption.id;
  bool _audioBusy = false;
  bool _isAudioPlaying = QuranService.isAudioPlaying;
  int? _playingSurah = QuranService.playingSurah;
  Duration _audioPosition = QuranService.currentAudioPosition;
  Duration _audioDuration = QuranService.currentAudioDuration ?? Duration.zero;

  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialSurah?.ayahs.first.page ?? QuranService.currentPage;
    _pageController = PageController(
      initialPage: _currentPage - 1,
      viewportFraction: 0.94,
    );
    _syncFromService();
    _playerStateSubscription = QuranService.playerStateStream.listen((_) {
      if (!mounted) return;
      setState(_syncFromService);
    });
    _positionSubscription = QuranService.positionStream.listen((position) {
      if (!mounted) return;
      setState(() => _audioPosition = position);
    });
    _durationSubscription = QuranService.durationStream.listen((duration) {
      if (!mounted) return;
      setState(() => _audioDuration = duration ?? Duration.zero);
    });
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _syncFromService() {
    _isAudioPlaying = QuranService.isAudioPlaying;
    _playingSurah = QuranService.playingSurah;
    _selectedFontId = QuranService.selectedFontOption.id;
    _selectedReciterId = QuranService.selectedReciterOption.id;
    _audioPosition = QuranService.currentAudioPosition;
    _audioDuration = QuranService.currentAudioDuration ?? Duration.zero;
  }

  Future<void> _handlePageChanged(int index) async {
    final nextPage = index + 1;
    setState(() => _currentPage = nextPage);
    await QuranService.saveReadingProgress(nextPage);
  }

  Future<void> _jumpToPage(int pageNumber) async {
    final boundedPage = pageNumber.clamp(1, QuranService.getTotalPages());
    setState(() => _currentPage = boundedPage);
    await _pageController.animateToPage(
      boundedPage - 1,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
    await QuranService.jumpToPage(boundedPage);
  }

  Future<void> _toggleBookmark() async {
    await QuranService.toggleBookmark(_currentPage);
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          QuranService.isBookmarked(_currentPage)
              ? 'Page $_currentPage bookmarked'
              : 'Bookmark removed from page $_currentPage',
        ),
      ),
    );
  }

  Future<void> _toggleAudio() async {
    final surahNumber = QuranService.getPrimarySurahForPage(_currentPage);
    if (surahNumber == null) return;

    setState(() => _audioBusy = true);
    try {
      await QuranService.playSurahAudio(surahNumber);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to stream this reciter now. Check your connection and try again.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _audioBusy = false;
          _syncFromService();
        });
      }
    }
  }

  Future<void> _stopAudio() async {
    setState(() => _audioBusy = true);
    await QuranService.stopAudio();
    if (!mounted) return;
    setState(() {
      _audioBusy = false;
      _syncFromService();
    });
  }

  Future<void> _seekAudio(double value) async {
    await QuranService.seekAudio(Duration(milliseconds: value.round()));
  }

  Future<void> _changeFont(String? fontId) async {
    if (fontId == null) return;
    await QuranService.setSelectedFont(fontId);
    if (!mounted) return;
    setState(_syncFromService);
  }

  Future<void> _changeReciter(String? reciterId) async {
    if (reciterId == null) return;
    await QuranService.stopAudio();
    await QuranService.setSelectedReciter(reciterId);
    if (!mounted) return;
    setState(_syncFromService);
  }

  Future<void> _showLibrarySheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return QuranLibrarySheet(
          currentPage: _currentPage,
          onSelectPage: (page) {
            _jumpToPage(page);
          },
        );
      },
    );
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _showReaderControls() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0D5C2),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Reader controls',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  'Tune the page appearance and recitation without leaving the reader.',
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
                  onChanged: _changeFont,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: _selectedReciterId,
                  decoration: const InputDecoration(labelText: 'Reciter'),
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
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _ReaderSettingPill(
                      icon: Icons.bookmark_rounded,
                      label: '${QuranService.bookmarkedPages.length} bookmarks',
                    ),
                    _ReaderSettingPill(
                      icon: Icons.history_rounded,
                      label: 'Resume page ${QuranService.currentPage}',
                    ),
                    _ReaderSettingPill(
                      icon: Icons.record_voice_over_rounded,
                      label: QuranService.selectedReciterOption.name,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    if (!mounted) return;
    setState(_syncFromService);
  }

  @override
  Widget build(BuildContext context) {
    if (QuranService.quranData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final pageSurahs = QuranService.getSurahsForPage(_currentPage);
    final primarySurah = pageSurahs.isEmpty ? null : pageSurahs.first;
    final currentJuz = QuranService.getJuzForPage(_currentPage) ?? 1;
    final isBookmarked = QuranService.isBookmarked(_currentPage);
    final pageProgress = _currentPage / QuranService.getTotalPages();
    final isPlayingCurrentSurah =
        _isAudioPlaying && _playingSurah == primarySurah?.number;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DecorativeBackdrop(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: _buildHeader(context),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: _buildHeroCard(
                  context,
                  surahs: pageSurahs,
                  primarySurah: primarySurah,
                  currentJuz: currentJuz,
                  pageProgress: pageProgress,
                  isBookmarked: isBookmarked,
                  isPlayingCurrentSurah: isPlayingCurrentSurah,
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: QuranService.getTotalPages(),
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: _handlePageChanged,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 20),
                      child: QuranPageViewer(
                        pageNumber: index + 1,
                        arabicFontFamily:
                            QuranService.selectedFontOption.fontFamily,
                      ),
                    );
                  },
                ),
              ),
              if (_playingSurah != null || _audioBusy)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                  child: _buildMiniPlayer(context),
                ),
            ],
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
              Text('Quran Reader', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(
                'A calmer, page-first reading flow with quick audio and navigation.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        IconButton.filledTonal(
          onPressed: _showLibrarySheet,
          icon: const Icon(Icons.grid_view_rounded),
          tooltip: 'Browse Quran',
        ),
        const SizedBox(width: 8),
        IconButton.filledTonal(
          onPressed: _showReaderControls,
          icon: const Icon(Icons.tune_rounded),
          tooltip: 'Reader controls',
        ),
      ],
    );
  }

  Widget _buildHeroCard(
    BuildContext context, {
    required List<Surah> surahs,
    required Surah? primarySurah,
    required int currentJuz,
    required double pageProgress,
    required bool isBookmarked,
    required bool isPlayingCurrentSurah,
  }) {
    final title = surahs.isEmpty
        ? 'Quran'
        : surahs.map((surah) => surah.englishName).join(' • ');
    final subtitle = primarySurah == null
        ? 'Resume your reading rhythm.'
        : '${primarySurah.englishNameTranslation} • ${primarySurah.revelationType}';

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.white,
            Color(0xFFF7F1E7),
            Color(0xFFF0E9DD),
          ],
        ),
        border: Border.all(color: const Color(0xFFE8DDCE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.slate,
                          ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _toggleBookmark,
                icon: Icon(
                  isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                ),
                tooltip: isBookmarked ? 'Remove bookmark' : 'Bookmark page',
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _ReaderMetric(
                  label: 'Page',
                  value: '$_currentPage / ${QuranService.getTotalPages()}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ReaderMetric(
                  label: 'Juz',
                  value: '$currentJuz',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ReaderMetric(
                  label: 'Reciter',
                  value: QuranService.selectedReciterOption.name.split(' ').first,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: pageProgress,
              minHeight: 8,
              backgroundColor: const Color(0xFFE5DDD1),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.emerald),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: primarySurah == null || _audioBusy ? null : _toggleAudio,
                  icon: Icon(
                    isPlayingCurrentSurah ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  ),
                  label: Text(
                    isPlayingCurrentSurah ? 'Pause recitation' : 'Play recitation',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: _audioBusy ? null : () => _jumpToPage(QuranService.currentPage),
                icon: const Icon(Icons.history_rounded),
                label: const Text('Resume'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniPlayer(BuildContext context) {
    final surahNumber = _playingSurah;
    final surahName = surahNumber == null
        ? 'Recitation'
        : QuranService.getSurahName(surahNumber);
    final durationMs = _audioDuration.inMilliseconds.toDouble();
    final positionMs = _audioPosition.inMilliseconds.toDouble();
    final sliderMax = durationMs <= 0 ? 1.0 : durationMs;
    final sliderValue = positionMs.clamp(0.0, sliderMax);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.16),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.graphic_eq_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      surahName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      QuranService.selectedReciterOption.name,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withOpacity(0.72),
                          ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: surahNumber == null || _audioBusy
                    ? null
                    : () => QuranService.playSurahAudio(surahNumber),
                icon: Icon(
                  _isAudioPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: _audioBusy ? null : _stopAudio,
                icon: const Icon(Icons.stop_circle_outlined, color: Colors.white),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            ),
            child: Slider(
              value: sliderValue,
              min: 0,
              max: sliderMax,
              onChanged: surahNumber == null || durationMs <= 0 ? null : _seekAudio,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_audioPosition),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.72),
                    ),
              ),
              Text(
                _formatDuration(_audioDuration),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.72),
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }
}

class _ReaderMetric extends StatelessWidget {
  const _ReaderMetric({
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
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.ink,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ReaderSettingPill extends StatelessWidget {
  const _ReaderSettingPill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.emerald),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
