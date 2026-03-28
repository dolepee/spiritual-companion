import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../models/quran.dart';
import '../services/quran_service.dart';

class QuranPageViewer extends StatelessWidget {
  const QuranPageViewer({
    super.key,
    required this.pageNumber,
    this.arabicFontFamily,
    this.onToggleChrome,
    this.immersive = false,
  });

  final int pageNumber;
  final String? arabicFontFamily;
  final VoidCallback? onToggleChrome;
  final bool immersive;

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
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onToggleChrome,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: const Color(0xFFFFFCF5).withValues(
            alpha: immersive ? 0.998 : 0.975,
          ),
          borderRadius: BorderRadius.circular(immersive ? 10 : 26),
          border: Border.all(
            color: const Color(0xFFE6DBCB).withValues(
              alpha: immersive ? 0.18 : 0.88,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: immersive ? 0.018 : 0.07),
              blurRadius: immersive ? 10 : 28,
              offset: Offset(0, immersive ? 4 : 18),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(immersive ? 10 : 26),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              immersive ? 14 : 22,
              immersive ? 14 : 24,
              immersive ? 14 : 22,
              immersive ? 18 : 30,
            ),
            child: Column(
              children: [
                ...groupedAyahs.entries.toList().asMap().entries.map((entry) {
                  final surah = QuranService.getSurahByNumber(entry.value.key);
                  if (surah == null) return const SizedBox.shrink();
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: entry.key == groupedAyahs.length - 1 ? 0 : 26,
                    ),
                    child: _SurahPageSection(
                      surah: surah,
                      ayahs: entry.value.value,
                      arabicFontFamily: arabicFontFamily,
                      showDivider: entry.key != 0,
                      immersive: immersive,
                    ),
                  );
                }),
                if (!immersive) ...[
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7EFE0),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Page $pageNumber',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.slate,
                          ),
                    ),
                  ),
                ],
              ],
            ),
          ),
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
}

class _SurahPageSection extends StatelessWidget {
  const _SurahPageSection({
    required this.surah,
    required this.ayahs,
    required this.arabicFontFamily,
    required this.showDivider,
    required this.immersive,
  });

  final Surah surah;
  final List<Ayah> ayahs;
  final String? arabicFontFamily;
  final bool showDivider;
  final bool immersive;

  @override
  Widget build(BuildContext context) {
    final firstAyah = ayahs.first.numberInSurah;
    final lastAyah = ayahs.last.numberInSurah;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          if (showDivider)
            Center(
              child: Container(
                width: 82,
                height: 1,
                margin: const EdgeInsets.only(bottom: 24),
                color: const Color(0xFFE7DCCA),
              ),
            ),
          Center(
            child: Column(
              children: [
                Text(
                  surah.name,
                  textDirection: TextDirection.rtl,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.emerald,
                        fontFamily: arabicFontFamily ?? 'Amiri',
                        fontWeight: FontWeight.w700,
                        fontSize: immersive ? 30 : 28,
                      ),
                ),
                if (!immersive) ...[
                  const SizedBox(height: 6),
                  Text(
                    surah.englishName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${surah.englishNameTranslation} • ${surah.revelationType} • Ayahs $firstAyah-$lastAyah',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ] else ...[
                  const SizedBox(height: 4),
                  Text(
                    'Ayahs $firstAyah-$lastAyah',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.slate,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: immersive ? 14 : 20),
          Text.rich(
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
                  fontSize: immersive ? 30 : 26,
                  height: immersive ? 1.95 : 2.15,
                  color: AppColors.ink,
                ),
          ),
          if (lastAyah < surah.numberOfAyahs) ...[
            SizedBox(height: immersive ? 14 : 18),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Continues on the next page',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.slate,
                    ),
              ),
            ),
          ],
      ],
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
