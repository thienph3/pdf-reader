import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import '../models/highlight.dart';
import 'pdf_highlight_manager.dart';

/// UI components for highlights in PDF viewer.
class PdfViewHighlightsUi {
  final PdfHighlightManager highlightManager;
  final PdfViewerController viewerController;
  final int currentPage;
  final VoidCallback onRefresh;

  PdfViewHighlightsUi({
    required this.highlightManager,
    required this.viewerController,
    required this.currentPage,
    required this.onRefresh,
  });

  /// Shows edit menu when user taps on a highlight in the PDF.
  void showEditMenuForHighlight({
    required BuildContext context,
    required Highlight highlight,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                highlight.text.length > 60
                    ? '${highlight.text.substring(0, 60)}...'
                    : highlight.text,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit_note),
              title: const Text('Edit Note'),
              onTap: () {
                Navigator.pop(ctx);
                _editNote(context, highlight);
              },
            ),
            ListTile(
              leading: const Icon(Icons.color_lens),
              title: const Text('Change Color'),
              onTap: () {
                Navigator.pop(ctx);
                _changeColor(context, highlight);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(ctx);
                _delete(context, highlight);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Shows all highlights list.
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
        builder: (_, scrollCtrl) => _buildList(
          context: context,
          highlights: highlights,
          scrollController: scrollCtrl,
          sheetContext: ctx,
          onPageSelected: onPageSelected,
        ),
      ),
    );
  }

  /// Shows current page highlights.
  void showCurrentPageHighlights({
    required BuildContext context,
    required int currentPage,
  }) {
    final items = highlightManager.getHighlightsForCurrentPage(currentPage);
    if (items.isEmpty) {
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
        builder: (_, scrollCtrl) => _buildList(
          context: context,
          highlights: items,
          scrollController: scrollCtrl,
          sheetContext: ctx,
          title: 'Highlights on Page ${currentPage + 1}',
        ),
      ),
    );
  }

  Widget _buildList({
    required BuildContext context,
    required List<Highlight> highlights,
    required ScrollController scrollController,
    required BuildContext sheetContext,
    ValueChanged<int>? onPageSelected,
    String title = 'Highlights',
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        Expanded(
          child: ListView.builder(
            controller: scrollController,
            itemCount: highlights.length,
            itemBuilder: (_, i) {
              final h = highlights[i];
              return ListTile(
                leading: Container(
                  width: 24, height: 24,
                  decoration: BoxDecoration(
                    color: Color(h.colorValue),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Theme.of(context).colorScheme.outline),
                  ),
                ),
                title: Text(
                  h.text.length > 80 ? '${h.text.substring(0, 80)}...' : h.text,
                  maxLines: 2, overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (onPageSelected != null)
                      Text('Page ${h.page + 1}',
                          style: Theme.of(context).textTheme.bodySmall),
                    if (h.note.isNotEmpty)
                      Text(h.note,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontStyle: FontStyle.italic)),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20),
                  onSelected: (value) {
                    Navigator.pop(sheetContext);
                    switch (value) {
                      case 'edit_note':
                        _editNote(context, h);
                      case 'change_color':
                        _changeColor(context, h);
                      case 'delete':
                        _delete(context, h);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit_note', child: Text('Edit Note')),
                    PopupMenuItem(value: 'change_color', child: Text('Change Color')),
                    PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  if (onPageSelected != null) {
                    onPageSelected(h.page);
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _editNote(BuildContext context, Highlight highlight) {
    final controller = TextEditingController(text: highlight.note);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Note'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Add a note...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await highlightManager.editHighlightNote(
                  context, highlight, controller.text.trim());
              if (ctx.mounted) Navigator.pop(ctx);
              onRefresh();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _changeColor(BuildContext context, Highlight highlight) {
    highlightManager.showColorPicker(context, onColorSelected: (color) async {
      await highlightManager.changeHighlightColor(context, highlight, color);
      onRefresh();
      viewerController.invalidate();
    });
  }

  void _delete(BuildContext context, Highlight highlight) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Highlight'),
        content: const Text('Delete this highlight?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await highlightManager.deleteHighlight(context, highlight);
              if (ctx.mounted) Navigator.pop(ctx);
              onRefresh();
              viewerController.invalidate();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
