import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import '../../../core/l10n/app_strings.dart';
import '../controllers/pdf_highlight_manager.dart';
import '../controllers/pdf_bookmark_manager.dart';
import './pdf_search_bar_builder.dart';

/// UI builder methods for PDF viewer screen.
class PdfViewUiBuilder {
  final PdfBookmarkManager bookmarkManager;
  final String fileName;
  final int currentPage;
  final int totalPages;
  final VoidCallback onClose;
  final VoidCallback onStartSearch;
  final VoidCallback onShowReaderActions;
  final VoidCallback onToggleTts;
  final bool isTtsActive;
  final VoidCallback? onStartOcr;
  final bool isOcrRunning;
  final VoidCallback? onToggleTextView;
  final bool isTextViewMode;
  final bool isTextViewLoading;
  final ValueChanged<int> onToggleBookmark;
  final VoidCallback? onShowThumbnails;
  final VoidCallback? onGoToPage;
  final VoidCallback? onCycleReadingMode;
  final int readingMode;

  PdfViewUiBuilder({
    required this.bookmarkManager, required this.fileName,
    required this.currentPage, required this.totalPages,
    required this.onClose, required this.onStartSearch,
    required this.onShowReaderActions, required this.onToggleTts,
    this.isTtsActive = false, this.onStartOcr, this.isOcrRunning = false,
    this.onToggleTextView, this.isTextViewMode = false,
    this.isTextViewLoading = false, required this.onToggleBookmark,
    this.onShowThumbnails, this.onGoToPage, this.onCycleReadingMode,
    this.readingMode = 0,
  });

  PreferredSizeWidget buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: onClose),
      title: GestureDetector(
        onTap: onGoToPage,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(fileName, style: Theme.of(context).textTheme.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
          if (totalPages > 0) Text('${currentPage + 1} / $totalPages', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ]),
      ),
      actions: [
        if (totalPages > 0) ...[
          IconButton(
            icon: Icon(_readingModeIcon()),
            tooltip: _readingModeLabel(context),
            onPressed: onCycleReadingMode,
          ),
          IconButton(
            icon: Icon(bookmarkManager.isBookmarked(currentPage) ? Icons.bookmark : Icons.bookmark_border, color: bookmarkManager.isBookmarked(currentPage) ? Theme.of(context).colorScheme.primary : null),
            onPressed: () => onToggleBookmark(currentPage),
          ),
          IconButton(icon: const Icon(Icons.search), onPressed: onStartSearch),
          IconButton(
            icon: Icon(isTtsActive ? Icons.stop_circle : Icons.record_voice_over, color: isTtsActive ? Theme.of(context).colorScheme.primary : null),
            tooltip: isTtsActive ? 'Stop Reading' : 'Read Aloud',
            onPressed: onToggleTts,
          ),
          if (onToggleTextView != null)
            IconButton(
              icon: isTextViewLoading || isOcrRunning
                  ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.primary))
                  : Icon(isTextViewMode ? Icons.picture_as_pdf : Icons.text_snippet_outlined, color: isTextViewMode ? Theme.of(context).colorScheme.primary : null),
              tooltip: isTextViewMode ? 'PDF View' : 'Text View',
              onPressed: (isTextViewLoading || isOcrRunning) ? null : onToggleTextView,
            ),
          if (onShowThumbnails != null) IconButton(icon: const Icon(Icons.grid_view), tooltip: 'Pages', onPressed: onShowThumbnails),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: onShowReaderActions),
        ],
      ],
    );
  }

  IconData _readingModeIcon() => switch (readingMode) {
    1 => Icons.wb_sunny_outlined,
    2 => Icons.dark_mode_outlined,
    _ => Icons.brightness_auto_outlined,
  };

  String _readingModeLabel(BuildContext context) {
    final s = AppStrings.of(context);
    return switch (readingMode) {
      1 => s.readingModeSepia,
      2 => s.readingModeDark,
      _ => s.readingModeNormal,
    };
  }

  PreferredSizeWidget buildSearchBar({
    required BuildContext context,
    required TextEditingController searchController,
    required PdfTextSearcher? textSearcher,
    required VoidCallback onBackPressed,
    required ValueChanged<String> onSearchSubmitted,
  }) => buildPdfSearchBar(context: context, searchController: searchController, textSearcher: textSearcher, onBackPressed: onBackPressed, onSearchSubmitted: onSearchSubmitted);

  Widget? buildHighlightsFAB({
    required PdfHighlightManager highlightManager,
    required int currentPage,
    required VoidCallback onPressed,
  }) {
    final highlights = highlightManager.getHighlightsForCurrentPage(currentPage);
    if (highlights.isEmpty) return null;
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: 'Page Highlights (${highlights.length})',
      child: Badge(label: Text(highlights.length.toString()), child: const Icon(Icons.highlight)),
    );
  }
}
