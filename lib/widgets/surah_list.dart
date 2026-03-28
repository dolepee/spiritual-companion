import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../services/quran_service.dart';

class QuranLibrarySheet extends StatefulWidget {
  const QuranLibrarySheet({
    super.key,
    required this.currentPage,
    required this.onSelectPage,
    required this.selectedFontId,
    required this.selectedReciterId,
    required this.onChangeFont,
    required this.onChangeReciter,
  });

  final int currentPage;
  final ValueChanged<int> onSelectPage;
  final String selectedFontId;
  final String selectedReciterId;
  final ValueChanged<String?> onChangeFont;
  final ValueChanged<String?> onChangeReciter;

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
      child: FractionallySizedBox(
        heightFactor: 0.92,
        child: DefaultTabController(
          length: 4,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
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
                            'Manage your reading',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Jump quickly, revisit bookmarks, or adjust the reader without leaving the mushaf.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.tonalIcon(
                      onPressed: () => _selectPage(widget.currentPage),
                      icon: const Icon(Icons.history_rounded),
                      label: const Text('Last read'),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _LibraryPill(label: 'Page ${widget.currentPage}'),
                    _LibraryPill(
                      label: 'Juz ${QuranService.getJuzForPage(widget.currentPage) ?? '-'}',
                    ),
                    _LibraryPill(label: '${bookmarks.length} bookmarks'),
                    _LibraryPill(label: QuranService.selectedReciterOption.name),
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
                          labelText: 'Jump to page',
                          hintText: '1 - 604',
                        ),
                        onSubmitted: (_) => _jumpToPage(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    FilledButton.icon(
                      onPressed: _jumpToPage,
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: const Text('Open'),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const TabBar(
                  tabs: [
                    Tab(text: 'Surahs'),
                    Tab(text: 'Juz'),
                    Tab(text: 'Saved'),
                    Tab(text: 'Reader'),
                  ],
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildSurahList(context),
                      _buildJuzList(context),
                      _buildSavedList(context, bookmarks),
                      _buildReaderPane(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReaderPane(BuildContext context) {
    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.cream,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reader settings',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Keep the page full and adjust only what affects reading comfort.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 18),
              DropdownButtonFormField<String>(
                initialValue: widget.selectedFontId,
                decoration: const InputDecoration(labelText: 'Arabic font'),
                items: QuranService.fontOptions
                    .map(
                      (option) => DropdownMenuItem<String>(
                        value: option.id,
                        child: Text(option.label),
                      ),
                    )
                    .toList(),
                onChanged: widget.onChangeFont,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: widget.selectedReciterId,
                decoration: const InputDecoration(labelText: 'Reciter'),
                items: QuranService.reciterOptions
                    .map(
                      (option) => DropdownMenuItem<String>(
                        value: option.id,
                        child: Text(option.name),
                      ),
                    )
                    .toList(),
                onChanged: widget.onChangeReciter,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.cream,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick return points',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: () => _selectPage(widget.currentPage),
                icon: const Icon(Icons.history_rounded),
                label: Text('Resume page ${widget.currentPage}'),
              ),
              if (QuranService.bookmarkedPages.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (QuranService.bookmarkedPages.toList()..sort())
                      .take(6)
                      .map(
                        (page) => ActionChip(
                          label: Text('Page $page'),
                          onPressed: () => _selectPage(page),
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ],
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
