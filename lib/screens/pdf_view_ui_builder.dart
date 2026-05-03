import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import '../l10n/app_strings.dart';
import 'pdf_highlight_manager.dart';
import 'pdf_bookmark_manager.dart';
import 'pdf_ui_controls.dart';

/// UI builder methods for PDF viewer screen.
class PdfViewUiBuilder {
  final PdfBookmarkManager bookmarkManager;
  final PdfUiControls uiControls;
  final String fileName;
  final int currentPage;
  final int totalPages;
  final VoidCallback onClose;
  final VoidCallback onStartSearch;
  final VoidCallback onShowReaderActions;
  final ValueChanged<int> onToggleBookmark;

  PdfViewUiBuilder({
    required this.bookmarkManager,
    required this.uiControls,
    required this.fileName,
    required this.currentPage,
    required this.totalPages,
    required this.onClose,
    required this.onStartSearch,
    required this.onShowReaderActions,
    required this.onToggleBookmark,
  });

  /// Builds the main app bar for PDF viewer.
  PreferredSizeWidget buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: onClose,
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            fileName,
            style: Theme.of(context).textTheme.titleSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (totalPages > 0)
            Text(
              '${currentPage + 1} / $totalPages',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
        ],
      ),
      actions: [
        if (totalPages > 0) ...[
          // Bookmark toggle always visible
          IconButton(
            icon: Icon(
              bookmarkManager.isBookmarked(currentPage) ? Icons.bookmark : Icons.bookmark_border,
              color: bookmarkManager.isBookmarked(currentPage)
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
            onPressed: () => onToggleBookmark(currentPage),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: onStartSearch,
          ),
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: uiControls.toggleZoomControls,
            tooltip: 'Zoom Controls',
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: onShowReaderActions,
          ),
        ],
      ],
    );
  }

  /// Builds the search bar for PDF viewer.
  PreferredSizeWidget buildSearchBar({
    required BuildContext context,
    required TextEditingController searchController,
    required PdfTextSearcher? textSearcher,
    required VoidCallback onBackPressed,
    required ValueChanged<String> onSearchSubmitted,
  }) {
    final s = AppStrings.of(context);
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: onBackPressed,
      ),
      title: TextField(
        controller: searchController,
        autofocus: true,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: s.searchHintPdf,
          border: InputBorder.none,
        ),
        onSubmitted: onSearchSubmitted,
      ),
      actions: [
        if (textSearcher != null)
          ListenableBuilder(
            listenable: textSearcher,
            builder: (context, child) {
              final matches = textSearcher.matches;
              final currentIdx = textSearcher.currentIndex;
              final hasMatches = matches.isNotEmpty && currentIdx != null;
              final isFirst = !hasMatches || currentIdx <= 0;
              final isLast = !hasMatches || currentIdx >= matches.length - 1;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasMatches)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Text(
                        '${currentIdx + 1}/${matches.length}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.navigate_before),
                    onPressed:
                        hasMatches && !isFirst ? () => textSearcher.goToPrevMatch() : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.navigate_next),
                    onPressed:
                        hasMatches && !isLast ? () => textSearcher.goToNextMatch() : null,
                  ),
                ],
              );
            },
          ),
      ],
    );
  }

  /// Builds a floating action button for page highlights.
  Widget? buildHighlightsFAB({
    required PdfHighlightManager highlightManager,
    required int currentPage,
    required VoidCallback onPressed,
  }) {
    final currentPageHighlights = highlightManager.getHighlightsForCurrentPage(currentPage);
    
    if (currentPageHighlights.isEmpty) return null;
    
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: 'Page Highlights (${currentPageHighlights.length})',
      child: Badge(
        label: Text(currentPageHighlights.length.toString()),
        child: const Icon(Icons.highlight),
      ),
    );
  }
}