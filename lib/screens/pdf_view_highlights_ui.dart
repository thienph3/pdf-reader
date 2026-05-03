import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import '../models/highlight.dart';
import 'pdf_highlight_manager.dart';
import 'pdf_text_selection_manager.dart';

/// UI components for highlights in PDF viewer.
class PdfViewHighlightsUi {
  final PdfHighlightManager highlightManager;
  final PdfTextSelectionManager textSelectionManager;
  final PdfViewerController viewerController;
  final int currentPage;
  final VoidCallback onRefresh;

  PdfViewHighlightsUi({
    required this.highlightManager,
    required this.textSelectionManager,
    required this.viewerController,
    required this.currentPage,
    required this.onRefresh,
  });

  /// Shows the highlights list.
  void showHighlightsList({
    required BuildContext context,
    required ValueChanged<int> onPageSelected,
  }) {
    final highlights = highlightManager.getAllHighlights();
    if (highlights.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No highlights found')),
      );
      return;
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.8,
        minChildSize: 0.3,
        expand: false,
        builder: (_, scrollCtrl) => _buildHighlightsListView(
          context: context,
          highlights: highlights,
          scrollController: scrollCtrl,
          sheetContext: ctx,
          onPageSelected: onPageSelected,
        ),
      ),
    );
  }

  /// Builds the highlights list view.
  Widget _buildHighlightsListView({
    required BuildContext context,
    required List<Highlight> highlights,
    required ScrollController scrollController,
    required BuildContext sheetContext,
    required ValueChanged<int> onPageSelected,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Highlights',
              style: Theme.of(context).textTheme.titleMedium),
        ),
        Expanded(
          child: ListView.builder(
            controller: scrollController,
            itemCount: highlights.length,
            itemBuilder: (_, i) {
              final highlight = highlights[i];
              return ListTile(
                leading: GestureDetector(
                  onTap: () {
                    textSelectionManager.showHighlightEditMenu(
                      context,
                      highlight,
                      (action) {
                        _handleHighlightAction(action, highlight);
                      },
                    );
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Color(highlight.colorValue),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                        width: 1,
                      ),
                    ),
                  ),
                ),
                title: Text('Page ${highlight.page + 1}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (highlight.text.isNotEmpty)
                      Text(
                        highlight.text.length > 50 
                          ? '${highlight.text.substring(0, 50)}...' 
                          : highlight.text,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                      ),
                    if (highlight.note.isNotEmpty)
                      Text(
                        highlight.note,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit_note',
                      child: Row(
                        children: [
                          Icon(Icons.note, size: 20),
                          SizedBox(width: 8),
                          Text('Edit Note'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'change_color',
                      child: Row(
                        children: [
                          Icon(Icons.color_lens, size: 20),
                          SizedBox(width: 8),
                          Text('Change Color'),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) async {
                    switch (value) {
                      case 'edit_note':
                        _editHighlightNote(context, highlight);
                        break;
                      case 'change_color':
                        _changeHighlightColor(context, highlight);
                        break;
                      case 'delete':
                        _deleteHighlight(context, highlight);
                        break;
                    }
                  },
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  onPageSelected(highlight.page);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  /// Shows current page highlights.
  void showCurrentPageHighlights({
    required BuildContext context,
    required int currentPage,
    required ValueChanged<HighlightEditAction> Function(Highlight) onHighlightAction,
  }) {
    final currentPageHighlights = highlightManager.getHighlightsForCurrentPage(currentPage);
    
    if (currentPageHighlights.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No highlights on this page')),
      );
      return;
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        maxChildSize: 0.7,
        minChildSize: 0.3,
        expand: false,
        builder: (_, scrollCtrl) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Highlights on Page ${currentPage + 1}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollCtrl,
                itemCount: currentPageHighlights.length,
                itemBuilder: (_, i) {
                  final highlight = currentPageHighlights[i];
                  return ListTile(
                    leading: GestureDetector(
                      onTap: () => textSelectionManager.showHighlightEditMenu(
                        context,
                        highlight,
                        (action) => onHighlightAction(highlight)(action),
                      ),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Color(highlight.colorValue),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      highlight.text.length > 100 
                        ? '${highlight.text.substring(0, 100)}...' 
                        : highlight.text,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: highlight.note.isNotEmpty
                      ? Text(highlight.note)
                      : null,
                    trailing: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit_note',
                          child: Row(
                            children: [
                              Icon(Icons.note, size: 20),
                              SizedBox(width: 8),
                              Text('Edit Note'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'change_color',
                          child: Row(
                            children: [
                              Icon(Icons.color_lens, size: 20),
                              SizedBox(width: 8),
                              Text('Change Color'),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) async {
                        Navigator.pop(ctx); // Close bottom sheet first
                        switch (value) {
                          case 'edit_note':
                            _editHighlightNote(context, highlight);
                            break;
                          case 'change_color':
                            _changeHighlightColor(context, highlight);
                            break;
                          case 'delete':
                            _deleteHighlight(context, highlight);
                            break;
                        }
                      },
                    ),
                    onTap: () {
                      // Highlight the text in the PDF (optional)
                      // For now, just close the bottom sheet
                      Navigator.pop(ctx);
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

  /// Handles highlight actions.
  void _handleHighlightAction(HighlightEditAction action, Highlight highlight) {
    // This method should be implemented by the parent
    // to handle the actual actions
  }

  /// Edits a highlight note.
  void _editHighlightNote(BuildContext context, Highlight highlight) {
    // This method should be implemented by the parent
  }

  /// Changes a highlight color.
  void _changeHighlightColor(BuildContext context, Highlight highlight) {
    // This method should be implemented by the parent
  }

  /// Deletes a highlight.
  void _deleteHighlight(BuildContext context, Highlight highlight) {
    // This method should be implemented by the parent
  }
}