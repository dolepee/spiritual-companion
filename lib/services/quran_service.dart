import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quran.dart';

class QuranService {
  static QuranData? _quranData;
  static int _currentPage = 1;
  static const String _pageKey = 'quran_current_page';

  static QuranData? get quranData => _quranData;
  static int get currentPage => _currentPage;

  static Future<void> initialize() async {
    await loadQuranData();
    await loadReadingProgress();
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
}