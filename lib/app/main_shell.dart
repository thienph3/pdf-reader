import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/l10n/app_strings.dart';
import './main.dart';
import '../models/book.dart';
import '../core/utils/pdf_file_utils.dart';
import '../features/library/screens/book_list_screen.dart';
import '../features/settings/screens/category_screen.dart';
import '../features/stats/screens/stats_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../core/routing/shared_route.dart';
import '../features/reader/screens/epub_view_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  static const _intentChannel = MethodChannel('com.thienph3.pdfreader/intent');

  @override
  void initState() {
    super.initState();
    _checkOpenedFile();
  }

  Future<void> _checkOpenedFile() async {
    try {
      final path = await _intentChannel.invokeMethod<String>('getOpenedFile');
      if (path == null || path.isEmpty || !mounted) return;

      final bookService = BookServiceScope.of(context);
      final fileName = fileNameFromPath(path);

      // Check if this file is already in the library
      final existing = bookService.getAll().where((b) =>
        b.filePath != null && fileNameFromPath(b.filePath!) == fileName
      ).firstOrNull;

      if (existing != null) {
        // Existing book — open directly with saved progress
        if (!mounted) return;
        await _openBookFile(context,
          filePath: existing.filePath!,
          fileName: existing.title,
          bookId: existing.id,
          initialPage: existing.lastPage,
        );
      } else {
        // New file — copy to app dir and prompt to add
        final savedPath = await copyPdfToAppDir(path);
        if (!mounted) return;
        final isEpub = path.toLowerCase().endsWith('.epub');
        final title = isEpub
            ? fileName.replaceAll(RegExp(r'\.epub$', caseSensitive: false), '')
            : fileName.endsWith('.pdf')
                ? fileName.substring(0, fileName.length - 4)
                : fileName;

        final shouldAdd = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(AppStrings.of(context).addBook),
            content: Text('"$title"\n${AppStrings.of(context).addToLibraryPrompt}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(AppStrings.of(context).readOnly),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(AppStrings.of(context).addBook),
              ),
            ],
          ),
        );

        if (!mounted) return;
        String? bookId;
        if (shouldAdd == true) {
          final book = await bookService.create(
            title: title,
            format: BookFormat.ebook,
            filePath: savedPath,
          );
          bookId = book.id;
        }

        if (!mounted) return;
        await _openBookFile(context,
          filePath: savedPath,
          fileName: title,
          bookId: bookId,
        );
      }
    } catch (_) {}
  }

  Future<void> _openBookFile(
    BuildContext context, {
    required String filePath,
    required String fileName,
    String? bookId,
    int initialPage = 0,
  }) async {
    if (filePath.toLowerCase().endsWith('.epub')) {
      await Navigator.push(context, buildPageRoute(EpubViewScreen(
        filePath: filePath,
        fileName: fileName,
        bookId: bookId,
      )));
    } else {
      await openPdfViewer(context,
        filePath: filePath,
        fileName: fileName,
        bookId: bookId,
        initialPage: initialPage,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final destinations = [
      NavigationDestination(
        icon: const Icon(Icons.library_books_outlined),
        selectedIcon: const Icon(Icons.library_books),
        label: s.library,
      ),
      NavigationDestination(
        icon: const Icon(Icons.folder_outlined),
        selectedIcon: const Icon(Icons.folder),
        label: s.categories,
      ),
      NavigationDestination(
        icon: const Icon(Icons.bar_chart_outlined),
        selectedIcon: const Icon(Icons.bar_chart),
        label: s.statistics,
      ),
      NavigationDestination(
        icon: const Icon(Icons.settings_outlined),
        selectedIcon: const Icon(Icons.settings),
        label: s.settings,
      ),
    ];

    final body = IndexedStack(
      index: _currentIndex,
      children: [
        const BookListScreen(),
        const CategoryScreen(),
        const StatsScreen(),
        SettingsScreen(
          settingsService: SettingsScope.of(context),
          ttsService: TtsServiceScope.of(context),
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 600) {
          // Tablet: NavigationRail on left
          // TODO(#46): When width >= 900dp and on Library tab, show split view
          // with book list on left (flex: 2) and PDF reader on right (flex: 3).
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (i) => setState(() => _currentIndex = i),
                  labelType: NavigationRailLabelType.all,
                  destinations: destinations.map((d) => NavigationRailDestination(
                    icon: d.icon,
                    selectedIcon: d.selectedIcon,
                    label: Text(d.label),
                  )).toList(),
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: body),
              ],
            ),
          );
        }
        // Phone: NavigationBar at bottom
        return Scaffold(
          body: body,
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (i) => setState(() => _currentIndex = i),
            destinations: destinations,
          ),
        );
      },
    );
  }
}
