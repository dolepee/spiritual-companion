import 'package:flutter/material.dart';
import '../services/quran_service.dart';
import '../models/quran.dart';
import '../screens/quran_screen.dart';

class SurahList extends StatelessWidget {
  const SurahList({super.key});

  @override
  Widget build(BuildContext context) {
    if (QuranService.quranData == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final surahs = QuranService.quranData!.surahs;

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: surahs.length,
      itemBuilder: (context, index) {
        final surah = surahs[index];
        return _buildSurahCard(context, surah);
      },
    );
  }

  Widget _buildSurahCard(BuildContext context, Surah surah) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => QuranScreen(
                initialSurah: surah,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    '${surah.number}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      surah.englishName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      surah.englishNameTranslation,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    surah.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontFamily: 'Amiri',
                          color: Theme.of(context).colorScheme.primary,
                        ),
                    ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getRevelationTypeColor(context, surah.revelationType),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${surah.numberOfAyahs} verses',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getRevelationTypeColor(BuildContext context, String revelationType) {
    switch (revelationType.toLowerCase()) {
      case 'meccan':
        return Colors.orange;
      case 'medinan':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}