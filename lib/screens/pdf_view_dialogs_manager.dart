import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import '../l10n/app_strings.dart';
import 'pdf_highlight_manager.dart';
import 'pdf_bookmark_manager.dart';
import 'pdf_ui_controls.dart';

/// Manages dialogs and bottom sheets for PDF viewer.
class PdfViewDialogsManager {
  final PdfHighlightManager highlightManager;
  final PdfBookmarkManager bookmarkManager;
  final PdfUiControls uiControls;
  final PdfViewerController viewerController;
  final int currentPage;
  final PdfDocument? pdfDocument;
  final VoidCallback onStartSearch;
  final VoidCallback onShowToc;
  final VoidCallback onShowHighlightsList;
  final ValueChanged<int> onPageSelected;
  final VoidCallback onToggleZoomControls;
  final VoidCallback onToggleNightMode;
  final bool nightMode;

  PdfViewDialogsManager({
    required this.highlightManager,
    required this.bookmarkManager,
    required this.uiControls,
    required this.viewerController,
    required this.currentPage,
    required this.pdfDocument,
    required this.onStartSearch,
    required this.onShowToc,
    required this.onShowHighlightsList,
    required this.onPageSelected,
    required this.onToggleZoomControls,
    required this.onToggleNightMode,
    required this.nightMode,
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
              leading: Icon(bookmarkManager.isBookmarked(currentPage) 
                  ? Icons.bookmark 
                  : Icons.bookmark_border),
              title: Text(bookmarkManager.isBookmarked(currentPage) 
                  ? s.removeBookmark 
                  : s.addBookmark),
              onTap: () {
                Navigator.pop(ctx);
                bookmarkManager.toggleBookmark(currentPage);
              },
            ),
            ListTile(
              leading: const Icon(Icons.note_add_outlined),
              title: Text(s.addNote),
              onTap: () {
                Navigator.pop(ctx);
                bookmarkManager.showEditNoteDialog(context, currentPage, '');
              },
            ),
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
              leading: const Icon(Icons.search),
              title: Text(s.searchInPdf),
              onTap: () {
                Navigator.pop(ctx);
                onStartSearch();
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
            ListTile(
              leading: const Icon(Icons.zoom_in),
              title: const Text('Zoom Controls'),
              onTap: () {
                Navigator.pop(ctx);
                onToggleZoomControls();
              },
            ),
            ListTile(
              leading: Icon(nightMode 
                  ? Icons.nightlight 
                  : Icons.nightlight_outlined),
              title: Text(nightMode ? 'Day Mode' : 'Night Mode'),
              onTap: () {
                Navigator.pop(ctx);
                onToggleNightMode();
              },
            ),
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