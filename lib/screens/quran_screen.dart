import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

import '../app_theme.dart';
import '../models/quran.dart';
import '../services/quran_service.dart';
import '../widgets/quran_page_viewer.dart';
import '../widgets/surah_list.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key, this.initialSurah});

  final Surah? initialSurah;

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  static const Duration _chromeDuration = Duration(milliseconds: 260);
  static const double _visibleHorizontalInset = 10;
  static const double _immersiveHorizontalInset = 2;

  late final PageController _pageController;

  int _currentPage = 1;
  String _selectedFontId = QuranService.selectedFontOption.id;
  String _selectedReciterId = QuranService.selectedReciterOption.id;
  bool _audioBusy = false;
  bool _isAudioPlaying = QuranService.isAudioPlaying;
  bool _isChromeVisible = true;
  bool _showPageFlash = false;
  int? _playingSurah = QuranService.playingSurah;
  Duration _audioPosition = QuranService.currentAudioPosition;
  Duration _audioDuration = QuranService.currentAudioDuration ?? Duration.zero;
  double? _scrubbingPageValue;

  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;
  Timer? _autoHideTimer;
  Timer? _pageFlashTimer;

  @override
  void initState() {
    super.initState();
    _currentPage =
        widget.initialSurah?.ayahs.first.page ?? QuranService.currentPage;
    _pageController = PageController(
      initialPage: _currentPage - 1,
      viewportFraction: 1,
    );
    QuranService.setReaderChromeVisible(true);
    _applySystemUi(true);
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
    _autoHideTimer?.cancel();
    _pageFlashTimer?.cancel();
    _applySystemUi(true);
    QuranService.setReaderChromeVisible(true);
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

  void _applySystemUi(bool chromeVisible) {
    SystemChrome.setEnabledSystemUIMode(
      chromeVisible ? SystemUiMode.edgeToEdge : SystemUiMode.immersiveSticky,
    );
  }

  void _scheduleAutoHide() {
    _autoHideTimer?.cancel();
    _autoHideTimer = Timer(const Duration(seconds: 4), () {
      if (!mounted || !_isChromeVisible) return;
      _setChromeVisible(false);
    });
  }

  void _showPageContextFlash() {
    _pageFlashTimer?.cancel();
    if (!_showPageFlash) {
      setState(() => _showPageFlash = true);
    }
    _pageFlashTimer = Timer(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() => _showPageFlash = false);
    });
  }

  void _setChromeVisible(bool visible, {bool autoHide = false}) {
    if (_isChromeVisible == visible) return;
    _autoHideTimer?.cancel();
    setState(() => _isChromeVisible = visible);
    QuranService.setReaderChromeVisible(visible);
    _applySystemUi(visible);
    if (visible && autoHide) {
      _scheduleAutoHide();
    }
  }

  void _toggleChrome() {
    if (_isChromeVisible) {
      _setChromeVisible(false);
      return;
    }
    _setChromeVisible(true, autoHide: true);
  }

  Future<void> _handlePageChanged(int index) async {
    final nextPage = index + 1;
    setState(() {
      _currentPage = nextPage;
      _scrubbingPageValue = null;
    });
    await QuranService.saveReadingProgress(nextPage);
    if (_isChromeVisible) {
      _scheduleAutoHide();
    } else {
      _showPageContextFlash();
    }
  }

  Future<void> _jumpToPage(int pageNumber) async {
    final boundedPage = pageNumber.clamp(1, QuranService.getTotalPages());
    setState(() => _currentPage = boundedPage);
    await _pageController.animateToPage(
      boundedPage - 1,
      duration: const Duration(milliseconds: 360),
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
        behavior: SnackBarBehavior.floating,
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
          behavior: SnackBarBehavior.floating,
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

  Future<void> _showManageSheet() async {
    _autoHideTimer?.cancel();
    _setChromeVisible(true);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return QuranLibrarySheet(
          currentPage: _currentPage,
          onSelectPage: _jumpToPage,
          selectedFontId: _selectedFontId,
          selectedReciterId: _selectedReciterId,
          onChangeFont: _changeFont,
          onChangeReciter: _changeReciter,
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

    final mediaPadding = MediaQuery.paddingOf(context);
    final pageSurahs = QuranService.getSurahsForPage(_currentPage);
    final primarySurah = pageSurahs.isEmpty ? null : pageSurahs.first;
    final currentJuz = QuranService.getJuzForPage(_currentPage) ?? 1;
    final isBookmarked = QuranService.isBookmarked(_currentPage);
    final isPlayingCurrentSurah =
        _isAudioPlaying && _playingSurah == primarySurah?.number;
    final hasAudioOverlay = _playingSurah != null || _audioBusy;
    final horizontalInset =
        _isChromeVisible ? _visibleHorizontalInset : _immersiveHorizontalInset;
    final pageEdgePadding = _isChromeVisible ? 4.0 : 0.0;
    final topInset = mediaPadding.top + (_isChromeVisible ? 74 : 4);
    final bottomInset = mediaPadding.bottom +
        (hasAudioOverlay
            ? (_isChromeVisible ? 120 : 72)
            : (_isChromeVisible ? 22 : 10));

    return Scaffold(
      backgroundColor: const Color(0xFFF2EADB),
      body: Stack(
        children: [
          Positioned.fill(child: _buildBackdrop()),
          Positioned.fill(
            child: AnimatedPadding(
              duration: _chromeDuration,
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.fromLTRB(
                horizontalInset,
                topInset,
                horizontalInset,
                bottomInset,
              ),
              child: PageView.builder(
                controller: _pageController,
                itemCount: QuranService.getTotalPages(),
                physics: const BouncingScrollPhysics(),
                onPageChanged: _handlePageChanged,
                itemBuilder: (context, index) {
                  return AnimatedPadding(
                    duration: _chromeDuration,
                    curve: Curves.easeOutCubic,
                    padding: EdgeInsets.symmetric(horizontal: pageEdgePadding),
                    child: QuranPageViewer(
                      pageNumber: index + 1,
                      arabicFontFamily: QuranService.selectedFontOption.fontFamily,
                      immersive: !_isChromeVisible,
                      onToggleChrome: _toggleChrome,
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned(
            left: 10,
            right: 10,
            top: mediaPadding.top + 8,
            child: _buildOverlayChrome(
              visible: _isChromeVisible,
              hiddenOffset: const Offset(0, -0.12),
              child: _buildTopBar(
                context,
                surahs: pageSurahs,
                currentJuz: currentJuz,
                isBookmarked: isBookmarked,
                isPlayingCurrentSurah: isPlayingCurrentSurah,
                primarySurah: primarySurah,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: mediaPadding.top + 18,
            child: IgnorePointer(
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                offset: _showPageFlash ? Offset.zero : const Offset(0, -0.08),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  opacity: _showPageFlash ? 1 : 0,
                  child: Center(
                    child: _PageContextBadge(
                      page: _currentPage,
                      juz: currentJuz,
                      surahLabel: primarySurah?.englishName ??
                          QuranService.getSurahNamesForPage(_currentPage),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 10,
            right: 10,
            bottom: mediaPadding.bottom + 10,
            child: _buildBottomOverlay(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBackdrop() {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF8F3EA),
            Color(0xFFF2EBDE),
            Color(0xFFECE4D6),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            left: -20,
            child: _BackdropGlow(
              size: 220,
              color: AppColors.emerald.withValues(alpha: 0.08),
            ),
          ),
          Positioned(
            right: -60,
            bottom: 120,
            child: _BackdropGlow(
              size: 240,
              color: AppColors.gold.withValues(alpha: 0.08),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlayChrome({
    required bool visible,
    required Offset hiddenOffset,
    required Widget child,
  }) {
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedSlide(
        duration: _chromeDuration,
        curve: Curves.easeOutCubic,
        offset: visible ? Offset.zero : hiddenOffset,
        child: AnimatedOpacity(
          duration: _chromeDuration,
          curve: Curves.easeOutCubic,
          opacity: visible ? 1 : 0,
          child: child,
        ),
      ),
    );
  }

  Widget _buildTopBar(
    BuildContext context, {
    required List<Surah> surahs,
    required int currentJuz,
    required bool isBookmarked,
    required bool isPlayingCurrentSurah,
    required Surah? primarySurah,
  }) {
    final canPop = Navigator.of(context).canPop();
    final surahLabel = surahs.isEmpty
        ? 'Quran'
        : surahs.map((surah) => surah.englishName).join(' • ');

    return _ReaderChromeSurface(
      child: Row(
        children: [
          _ReaderIconButton(
            icon: Icons.arrow_back_rounded,
            onPressed: canPop ? () => Navigator.of(context).maybePop() : null,
            tooltip: 'Back',
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  surahLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.ink,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Page $_currentPage • Juz $currentJuz',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        color: AppColors.slate,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _ReaderIconButton(
            icon: isBookmarked
                ? Icons.bookmark_rounded
                : Icons.bookmark_border_rounded,
            onPressed: _toggleBookmark,
            tooltip: isBookmarked ? 'Remove bookmark' : 'Bookmark page',
            emphasized: isBookmarked,
          ),
          const SizedBox(width: 8),
          _ReaderIconButton(
            icon: _audioBusy
                ? Icons.sync_rounded
                : isPlayingCurrentSurah
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
            onPressed:
                primarySurah == null || _audioBusy ? null : _toggleAudio,
            tooltip: isPlayingCurrentSurah ? 'Pause recitation' : 'Play recitation',
            emphasized: isPlayingCurrentSurah,
          ),
          const SizedBox(width: 8),
          _ReaderIconButton(
            icon: Icons.more_horiz_rounded,
            onPressed: _showManageSheet,
            tooltip: 'Manage',
          ),
        ],
      ),
    );
  }

  Widget _buildBottomOverlay(BuildContext context) {
    final hasAudioOverlay = _playingSurah != null || _audioBusy;

    if (hasAudioOverlay) {
      return AnimatedSwitcher(
        duration: _chromeDuration,
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.12),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: _isChromeVisible
            ? _buildMiniPlayer(context, compact: false)
            : _buildMiniPlayer(context, compact: true),
      );
    }

    return _buildOverlayChrome(
      visible: _isChromeVisible,
      hiddenOffset: const Offset(0, 0.12),
      child: _buildPageNavigator(context),
    );
  }

  Widget _buildPageNavigator(BuildContext context) {
    final totalPages = QuranService.getTotalPages();
    final displayedPage =
        (_scrubbingPageValue ?? _currentPage.toDouble()).round().clamp(1, totalPages);
    final pageSurah = QuranService.getSurahNamesForPage(displayedPage);

    return _ReaderChromeSurface(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          _ReaderIconButton(
            icon: Icons.chevron_left_rounded,
            onPressed:
                _currentPage > 1 ? () => _jumpToPage(_currentPage - 1) : null,
            tooltip: 'Previous page',
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: _showManageSheet,
                    child: Column(
                      children: [
                        Text(
                          'Page $displayedPage of $totalPages',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          pageSurah,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.slate,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 3,
                      overlayShape:
                          const RoundSliderOverlayShape(overlayRadius: 12),
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 6),
                      activeTrackColor: AppColors.emerald,
                      inactiveTrackColor: const Color(0xFFE1D7C8),
                      thumbColor: AppColors.emerald,
                    ),
                    child: Slider(
                      value: displayedPage.toDouble(),
                      min: 1,
                      max: totalPages.toDouble(),
                      divisions: totalPages - 1,
                      label: 'Page $displayedPage',
                      onChanged: (value) {
                        setState(() => _scrubbingPageValue = value);
                      },
                      onChangeEnd: (value) async {
                        final targetPage = value.round().clamp(1, totalPages);
                        setState(() => _scrubbingPageValue = null);
                        await _jumpToPage(targetPage);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          _ReaderIconButton(
            icon: Icons.chevron_right_rounded,
            onPressed: _currentPage < QuranService.getTotalPages()
                ? () => _jumpToPage(_currentPage + 1)
                : null,
            tooltip: 'Next page',
          ),
        ],
      ),
    );
  }

  Widget _buildMiniPlayer(BuildContext context, {required bool compact}) {
    final surahNumber = _playingSurah;
    final surahName = surahNumber == null
        ? 'Recitation'
        : QuranService.getSurahName(surahNumber);
    final durationMs = _audioDuration.inMilliseconds.toDouble();
    final positionMs = _audioPosition.inMilliseconds.toDouble();
    final sliderMax = durationMs <= 0 ? 1.0 : durationMs;
    final sliderValue = positionMs.clamp(0.0, sliderMax);

    if (compact) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: GestureDetector(
          onTap: () => _setChromeVisible(true),
          child: _ReaderChromeSurface(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.ink.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.graphic_eq_rounded,
                    size: 18,
                    color: AppColors.emerald,
                  ),
                ),
                const SizedBox(width: 10),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 180),
                  child: Text(
                    surahName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                const SizedBox(width: 10),
                _ReaderIconButton(
                  icon: _isAudioPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  onPressed: surahNumber == null || _audioBusy
                      ? null
                      : () => QuranService.playSurahAudio(surahNumber),
                  tooltip: 'Toggle audio',
                  emphasized: _isAudioPlaying,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return _ReaderChromeSurface(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.ink.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.graphic_eq_rounded,
                  color: AppColors.emerald,
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
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      QuranService.selectedReciterOption.name,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.slate,
                          ),
                    ),
                  ],
                ),
              ),
              _ReaderIconButton(
                icon: _isAudioPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                onPressed: surahNumber == null || _audioBusy
                    ? null
                    : () => QuranService.playSurahAudio(surahNumber),
                tooltip: 'Toggle audio',
                emphasized: _isAudioPlaying,
              ),
              const SizedBox(width: 8),
              _ReaderIconButton(
                icon: Icons.stop_rounded,
                onPressed: _audioBusy ? null : _stopAudio,
                tooltip: 'Stop audio',
              ),
            ],
          ),
          const SizedBox(height: 10),
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
                      color: AppColors.slate,
                    ),
              ),
              Text(
                _formatDuration(_audioDuration),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.slate,
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
    final minutes =
        duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds =
        duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }
}

class _ReaderChromeSurface extends StatelessWidget {
  const _ReaderChromeSurface({
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.76),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFE7DCCA).withValues(alpha: 0.82),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _PageContextBadge extends StatelessWidget {
  const _PageContextBadge({
    required this.page,
    required this.juz,
    required this.surahLabel,
  });

  final int page;
  final int juz;
  final String surahLabel;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: const Color(0xFFE7DCCA).withValues(alpha: 0.82),
            ),
          ),
          child: Text(
            '$surahLabel • Page $page • Juz $juz',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ),
    );
  }
}

class _ReaderIconButton extends StatelessWidget {
  const _ReaderIconButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.emphasized = false,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final activeColor = emphasized ? AppColors.emerald : AppColors.ink;
    final bgColor = emphasized
        ? AppColors.emerald.withValues(alpha: 0.14)
        : AppColors.ink.withValues(alpha: 0.06);

    return Tooltip(
      message: tooltip,
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            width: 38,
            height: 38,
            child: Icon(
              icon,
              size: 20,
              color: onPressed == null
                  ? AppColors.slate.withValues(alpha: 0.42)
                  : activeColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _BackdropGlow extends StatelessWidget {
  const _BackdropGlow({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: 80,
              spreadRadius: 16,
            ),
          ],
        ),
      ),
    );
  }
}
