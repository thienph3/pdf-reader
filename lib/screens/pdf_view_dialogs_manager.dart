import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import '../l10n/app_strings.dart';
import '../services/tts_service.dart';
import 'pdf_highlight_manager.dart';
import 'pdf_bookmark_manager.dart';

/// Manages dialogs and bottom sheets for PDF viewer.
class PdfViewDialogsManager {
  final PdfHighlightManager highlightManager;
  final PdfBookmarkManager bookmarkManager;
  final PdfViewerController viewerController;
  final TtsService? ttsService;
  final int currentPage;
  final PdfDocument? pdfDocument;
  final VoidCallback onShowToc;
  final VoidCallback onShowHighlightsList;
  final ValueChanged<int> onPageSelected;
  final VoidCallback? onTtsSpeedChanged;

  PdfViewDialogsManager({
    required this.highlightManager,
    required this.bookmarkManager,
    required this.viewerController,
    this.ttsService,
    required this.currentPage,
    required this.pdfDocument,
    required this.onShowToc,
    required this.onShowHighlightsList,
    required this.onPageSelected,
    this.onTtsSpeedChanged,
  });

  /// Shows the reader actions bottom sheet.
  void showReaderActions(BuildContext context) {
    final s = AppStrings.of(context);
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.bookmarks_outlined),
              title: Text(s.bookmarkList),
              onTap: () {
                Navigator.pop(ctx);
                bookmarkManager.showBookmarksList(context, currentPage, (page) {
                  viewerController.goToPage(pageNumber: page + 1);
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.toc),
              title: Text(s.tableOfContents),
              onTap: () {
                Navigator.pop(ctx);
                showToc(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.highlight),
              title: Text(s.highlights),
              onTap: () {
                Navigator.pop(ctx);
                onShowHighlightsList();
              },
            ),
            if (ttsService != null && ttsService!.isAvailable)
              ListTile(
                leading: const Icon(Icons.speed),
                title: Text(s.ttsSpeed),
                subtitle: Text('${(ttsService!.speed * 2).toStringAsFixed(1)}x'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showTtsSpeedPicker(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showTtsSpeedPicker(BuildContext context) {
    final s = AppStrings.of(context);
    final speeds = [0.25, 0.5, 0.75, 1.0];
    final labels = ['0.5x', '1x', '1.5x', '2x'];
    final wasPlaying = ttsService!.isPlaying;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(s.readingSpeed,
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            ...List.generate(speeds.length, (i) => ListTile(
              title: Text(labels[i]),
              trailing: ttsService!.speed == speeds[i]
                  ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                  : null,
              onTap: () {
                ttsService!.setSpeed(speeds[i]);
                Navigator.pop(ctx);
                if (wasPlaying) {
                  ttsService!.stop();
                  onTtsSpeedChanged?.call();
                }
              },
            )),
          ],
        ),
      ),
    );
  }

  /// Shows the table of contents.
  void showToc(BuildContext context) async {
    final s = AppStrings.of(context);
    if (pdfDocument == null) return;
    final outline = await pdfDocument!.loadOutline();
    if (!context.mounted) return;
    if (outline.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.noToc)),
      );
      return;
    }
    if (!context.mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.8,
        minChildSize: 0.3,
        expand: false,
        builder: (_, scrollCtrl) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(s.tableOfContents,
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollCtrl,
                itemCount: outline.length,
                itemBuilder: (_, i) {
                  final item = outline[i];
                  return ListTile(
                    contentPadding: EdgeInsets.only(
                        left: 16.0 + (item.children.isNotEmpty ? 0 : 16)),
                    title: Text(item.title),
                    onTap: () {
                      Navigator.pop(ctx);
                      if (item.dest != null) {
                        viewerController.goToDest(item.dest);
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}