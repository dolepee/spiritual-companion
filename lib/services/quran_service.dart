import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quran.dart';

class QuranFontOption {
  final String id;
  final String label;
  final String? fontFamily;

  const QuranFontOption({
    required this.id,
    required this.label,
    required this.fontFamily,
  });
}

class QuranReciterOption {
  final String id;
  final String name;
  final String baseUrl;

  const QuranReciterOption({
    required this.id,
    required this.name,
    required this.baseUrl,
  });
}

class QuranService {
  static QuranData? _quranData;
  static int _currentPage = 1;
  static const String _pageKey = 'quran_current_page';
  static const String _fontKey = 'quran_font_option';
  static const String _reciterKey = 'quran_reciter_option';

  static final AudioPlayer _audioPlayer = AudioPlayer();
  static bool _audioStateListenerAttached = false;
  static bool _isAudioPlaying = false;
  static int? _playingSurah;
  static String _selectedFontId = 'amiri';
  static String _selectedReciterId = 'alafasy';

  static const List<QuranFontOption> fontOptions = [
    QuranFontOption(
      id: 'amiri',
      label: 'Amiri',
      fontFamily: 'Amiri',
    ),
    QuranFontOption(
      id: 'dejavu',
      label: 'DejaVu Arabic',
      fontFamily: 'DejaVuArabic',
    ),
    QuranFontOption(
      id: 'system',
      label: 'System Arabic',
      fontFamily: null,
    ),
  ];

  static const List<QuranReciterOption> reciterOptions = [
    QuranReciterOption(
      id: 'alafasy',
      name: 'Mishary Alafasy',
      baseUrl: 'https://server8.mp3quran.net/afs',
    ),
    QuranReciterOption(
      id: 'sudais',
      name: 'Abdurrahman As-Sudais',
      baseUrl: 'https://server11.mp3quran.net/sds',
    ),
    QuranReciterOption(
      id: 'maher',
      name: 'Maher Al-Muaiqly',
      baseUrl: 'https://server12.mp3quran.net/maher',
    ),
    QuranReciterOption(
      id: 'shuraim',
      name: 'Saud Ash-Shuraim',
      baseUrl: 'https://server7.mp3quran.net/shur',
    ),
    QuranReciterOption(
      id: 'minshawi',
      name: 'Muhammad Siddiq Al-Minshawi',
      baseUrl: 'https://server10.mp3quran.net/minsh',
    ),
    QuranReciterOption(
      id: 'husary',
      name: 'Mahmoud Khalil Al-Husary',
      baseUrl: 'https://server13.mp3quran.net/husr',
    ),
  ];

  static QuranData? get quranData => _quranData;
  static int get currentPage => _currentPage;
  static bool get isAudioPlaying => _isAudioPlaying;
  static int? get playingSurah => _playingSurah;
  static Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;

  static QuranFontOption get selectedFontOption {
    return fontOptions.firstWhere(
      (item) => item.id == _selectedFontId,
      orElse: () => fontOptions.first,
    );
  }

  static QuranReciterOption get selectedReciterOption {
    return reciterOptions.firstWhere(
      (item) => item.id == _selectedReciterId,
      orElse: () => reciterOptions.first,
    );
  }

  static Future<void> initialize() async {
    await loadQuranData();
    await loadReadingProgress();
    await loadPreferences();
    _bindAudioState();
  }

  static Future<void> loadQuranData() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/quran.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      _quranData = QuranData.fromJson(jsonData);
    } catch (e) {
      if (kDebugMode) print('Error loading Quran data: $e');
    }
  }

  static Future<void> loadReadingProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentPage = prefs.getInt(_pageKey) ?? 1;
    } catch (e) {
      if (kDebugMode) print('Error loading reading progress: $e');
      _currentPage = 1;
    }
  }

  static Future<void> saveReadingProgress(int pageNumber) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_pageKey, pageNumber);
      _currentPage = pageNumber;
    } catch (e) {
      if (kDebugMode) print('Error saving reading progress: $e');
    }
  }

  static List<Ayah> getAyahsForPage(int pageNumber) {
    if (_quranData == null) return [];

    final allAyahs = <Ayah>[];
    for (final surah in _quranData!.surahs) {
      for (final ayah in surah.ayahs) {
        if (ayah.page == pageNumber) {
          allAyahs.add(ayah);
        }
      }
    }

    return allAyahs;
  }

  static String getSurahName(int surahNumber) {
    if (_quranData == null) return '';

    try {
      final surah = _quranData!.surahs
          .firstWhere((s) => s.number == surahNumber);
      return surah.englishName;
    } catch (e) {
      return '';
    }
  }

  static int getTotalPages() {
    return 604;
  }

  static int getNextUnreadPage() {
    if (_currentPage < getTotalPages()) {
      return _currentPage + 1;
    }
    return 1;
  }

  static int? getPrimarySurahForPage(int pageNumber) {
    final ayahs = getAyahsForPage(pageNumber);
    if (ayahs.isEmpty) return null;
    return ayahs.first.surahNumber;
  }

  static Future<void> loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _selectedFontId = prefs.getString(_fontKey) ?? fontOptions.first.id;
      _selectedReciterId = prefs.getString(_reciterKey) ?? reciterOptions.first.id;
    } catch (error) {
      if (kDebugMode) {
        print('Error loading Quran preferences: $error');
      }
    }
  }

  static Future<void> setSelectedFont(String fontId) async {
    if (!fontOptions.any((item) => item.id == fontId)) return;
    _selectedFontId = fontId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fontKey, fontId);
  }

  static Future<void> setSelectedReciter(String reciterId) async {
    if (!reciterOptions.any((item) => item.id == reciterId)) return;
    _selectedReciterId = reciterId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_reciterKey, reciterId);
  }

  static String buildSurahAudioUrl(int surahNumber) {
    final surahCode = surahNumber.toString().padLeft(3, '0');
    return '${selectedReciterOption.baseUrl}/$surahCode.mp3';
  }

  static Future<void> playSurahAudio(int surahNumber) async {
    try {
      final isSameSurah = _playingSurah == surahNumber;
      if (isSameSurah &&
          _audioPlayer.playing &&
          _audioPlayer.processingState != ProcessingState.completed) {
        await _audioPlayer.pause();
        _isAudioPlaying = false;
        return;
      }

      if (isSameSurah &&
          !_audioPlayer.playing &&
          _audioPlayer.processingState != ProcessingState.idle) {
        await _audioPlayer.play();
        _isAudioPlaying = true;
        return;
      }

      final audioUrl = buildSurahAudioUrl(surahNumber);
      await _audioPlayer.setUrl(audioUrl);
      await _audioPlayer.play();
      _playingSurah = surahNumber;
      _isAudioPlaying = true;
    } catch (error) {
      _isAudioPlaying = false;
      if (kDebugMode) {
        print('Error playing surah audio: $error');
      }
      rethrow;
    }
  }

  static Future<void> stopAudio() async {
    await _audioPlayer.stop();
    _isAudioPlaying = false;
    _playingSurah = null;
  }

  static void _bindAudioState() {
    if (_audioStateListenerAttached) return;
    _audioStateListenerAttached = true;
    _audioPlayer.playerStateStream.listen((state) {
      final completed = state.processingState == ProcessingState.completed;
      _isAudioPlaying = state.playing && !completed;
      if (completed) {
        _playingSurah = null;
      }
    });
  }
}
