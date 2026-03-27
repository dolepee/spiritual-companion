import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../models/quran.dart';
import '../services/quran_service.dart';

class QuranPageViewer extends StatelessWidget {
  const QuranPageViewer({
    super.key,
    required this.pageNumber,
    this.arabicFontFamily,
  });

  final int pageNumber;
  final String? arabicFontFamily;

  @override
  Widget build(BuildContext context) {
    final ayahs = QuranService.getAyahsForPage(pageNumber);

    if (ayahs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No Quran content was found for page $pageNumber.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
    }

    final groupedAyahs = _groupAyahsBySurah(ayahs);
    final surahs = QuranService.getSurahsForPage(pageNumber);

    return Card(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPageHeader(context, surahs),
            const SizedBox(height: 18),
            ...groupedAyahs.entries.map((entry) {
              final surah = QuranService.getSurahByNumber(entry.key);
              if (surah == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _SurahPageSection(
                  surah: surah,
                  ayahs: entry.value,
                  arabicFontFamily: arabicFontFamily,
                ),
              );
            }),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Reading position updates automatically as you move through the pages.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<int, List<Ayah>> _groupAyahsBySurah(List<Ayah> ayahs) {
    final grouped = <int, List<Ayah>>{};
    for (final ayah in ayahs) {
      grouped.putIfAbsent(ayah.surahNumber, () => <Ayah>[]).add(ayah);
    }
    return grouped;
  }

  Widget _buildPageHeader(BuildContext context, List<Surah> surahs) {
    final surahLabel = surahs.map((item) => item.englishName).join(' • ');
    final juz = QuranService.getJuzForPage(pageNumber) ?? 1;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE7DCCA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  pageNumber.toString(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.emerald,
                      ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mushaf Page $pageNumber',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      surahLabel,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              _MetaChip(label: 'Juz $juz'),
            ],
          ),
        ],
      ),
    );
  }
}

class _SurahPageSection extends StatelessWidget {
  const _SurahPageSection({
    required this.surah,
    required this.ayahs,
    required this.arabicFontFamily,
  });

  final Surah surah;
  final List<Ayah> ayahs;
  final String? arabicFontFamily;

  @override
  Widget build(BuildContext context) {
    final firstAyah = ayahs.first.numberInSurah;
    final lastAyah = ayahs.last.numberInSurah;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEDE3D4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 18,
            offset: const Offset(0, 10),
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
                      surah.englishName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${surah.englishNameTranslation} • ${surah.revelationType}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Text(
                surah.name,
                textDirection: TextDirection.rtl,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.emerald,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(label: 'Ayahs $firstAyah-$lastAyah'),
              _MetaChip(label: '${surah.numberOfAyahs} total'),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFCFAF5),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Text.rich(
              TextSpan(
                children: [
                  for (final ayah in ayahs) ...[
                    TextSpan(text: '${ayah.text} '),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: _AyahMarker(number: ayah.numberInSurah),
                    ),
                    const TextSpan(text: ' '),
                  ],
                ],
              ),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontFamily: arabicFontFamily ?? 'Amiri',
                    fontSize: 24,
                    height: 2.1,
                    color: AppColors.ink,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AyahMarker extends StatelessWidget {
  const _AyahMarker({required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5E8CA),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFEAD5A2)),
      ),
      child: Text(
        number.toString(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE7DCCA)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
      ),
    );
  }
}
