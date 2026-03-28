import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../services/quran_service.dart';

class QuranLibrarySheet extends StatefulWidget {
  const QuranLibrarySheet({
    super.key,
    required this.currentPage,
    required this.onSelectPage,
  });

  final int currentPage;
  final ValueChanged<int> onSelectPage;

  @override
  State<QuranLibrarySheet> createState() => _QuranLibrarySheetState();
}

class _QuranLibrarySheetState extends State<QuranLibrarySheet> {
  late final TextEditingController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = TextEditingController(text: widget.currentPage.toString());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _selectPage(int pageNumber) {
    widget.onSelectPage(pageNumber);
    Navigator.of(context).pop();
  }

  void _jumpToPage() {
    final requestedPage = int.tryParse(_pageController.text.trim());
    if (requestedPage == null) return;
    final boundedPage = requestedPage.clamp(1, QuranService.getTotalPages());
    _selectPage(boundedPage);
  }

  @override
  Widget build(BuildContext context) {
    final bookmarks = QuranService.bookmarkedPages.toList()..sort();

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        child: DefaultTabController(
          length: 3,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0D5C2),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Browse the Quran',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Jump by page, surah, juz, or return to saved pages.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.tonalIcon(
                    onPressed: () => _selectPage(QuranService.currentPage),
                    icon: const Icon(Icons.history_rounded),
                    label: const Text('Resume'),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _pageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Go to page',
                        hintText: '1 - 604',
                      ),
                      onSubmitted: (_) => _jumpToPage(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
                    onPressed: _jumpToPage,
                    child: const Text('Open'),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const TabBar(
                tabs: [
                  Tab(text: 'Surahs'),
                  Tab(text: 'Juz'),
                  Tab(text: 'Saved'),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 420,
                child: TabBarView(
                  children: [
                    _buildSurahList(context),
                    _buildJuzList(context),
                    _buildSavedList(context, bookmarks),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSurahList(BuildContext context) {
    final surahs = QuranService.allSurahs;
    return ListView.separated(
      itemCount: surahs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final surah = surahs[index];
        final page = QuranService.getFirstPageForSurah(surah.number);
        return Material(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(22),
          child: InkWell(
            onTap: () => _selectPage(page),
            borderRadius: BorderRadius.circular(22),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      surah.number.toString(),
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
                          surah.englishName,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${surah.englishNameTranslation} • ${surah.revelationType}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _LibraryPill(label: '${surah.numberOfAyahs} ayahs'),
                            _LibraryPill(label: 'Page $page'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    surah.name,
                    textDirection: TextDirection.rtl,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.emerald,
                        ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildJuzList(BuildContext context) {
    return ListView.separated(
      itemCount: 30,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final juz = index + 1;
        final page = QuranService.getFirstPageForJuz(juz);
        final label = QuranService.getSurahNamesForPage(page);
        return Material(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(22),
          child: InkWell(
            onTap: () => _selectPage(page),
            borderRadius: BorderRadius.circular(22),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      juz.toString(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.gold,
                          ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Juz $juz',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          label,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  _LibraryPill(label: 'Page $page'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSavedList(BuildContext context, List<int> bookmarks) {
    if (bookmarks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bookmark_border_rounded,
                size: 40,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 12),
              Text(
                'No bookmarked pages yet.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Bookmark any page from the reader and it will appear here.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: bookmarks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final page = bookmarks[index];
        return Material(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(22),
          child: InkWell(
            onTap: () => _selectPage(page),
            borderRadius: BorderRadius.circular(22),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.bookmark_rounded, color: AppColors.emerald),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Page $page',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          QuranService.getSurahNamesForPage(page),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  _LibraryPill(
                    label: 'Juz ${QuranService.getJuzForPage(page) ?? '-'}',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LibraryPill extends StatelessWidget {
  const _LibraryPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE8DCC8)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
