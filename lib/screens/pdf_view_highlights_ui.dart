import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import '../l10n/app_strings.dart';
import '../models/highlight.dart';
import 'pdf_highlight_manager.dart';

/// UI components for highlights in PDF viewer.
class PdfViewHighlightsUi {
  final PdfHighlightManager highlightManager;
  final PdfViewerController viewerController;
  final int currentPage;
  final VoidCallback onRefresh;

  static const _highlightColors = [
    0x80FFEB3B, 0x8066BB6A, 0x8042A5F5,
    0x80EF5350, 0x80AB47BC, 0x80FF7043,
  ];

  PdfViewHighlightsUi({
    required this.highlightManager,
    required this.viewerController,
    required this.currentPage,
    required this.onRefresh,
  });

  /// Shows edit form for a highlight (tap on highlight or tap in list).
  void showEditMenuForHighlight({
    required BuildContext context,
    required Highlight highlight,
  }) {
    _showHighlightForm(context, highlight);
  }

  /// Shows all highlights list.
  void showHighlightsList({
    required BuildContext context,
    required ValueChanged<int> onPageSelected,
  }) {
    final highlights = highlightManager.getAllHighlights();
    if (highlights.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.of(context).noHighlightsFound)),
      );
      return;
    }
    _showList(
      context: context,
      highlights: highlights,
      showPage: true,
      onPageSelected: onPageSelected,
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
        SnackBar(content: Text(AppStrings.of(context).noHighlightsOnPage)),
      );
      return;
    }
    _showList(
      context: context,
      highlights: items,
      showPage: false,
      title: AppStrings.of(context).highlightsOnPage(currentPage + 1),
    );
  }

  // ── Highlight edit form (color + note + save + delete) ──

  void _showHighlightForm(BuildContext context, Highlight highlight) {
    int selectedColor = highlight.colorValue;
    final noteCtrl = TextEditingController(text: highlight.note);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 16, right: 16, top: 16,
        ),
        child: StatefulBuilder(
          builder: (ctx, setSheetState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selected text preview
              Text(
                highlight.text.length > 100
                    ? '${highlight.text.substring(0, 100)}...'
                    : highlight.text,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              // Color picker
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _highlightColors.map((color) {
                  final isSelected = selectedColor == color;
                  return GestureDetector(
                    onTap: () => setSheetState(() => selectedColor = color),
                    child: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: Color(color),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade300,
                          width: isSelected ? 3 : 1,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, size: 20, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              // Note field
              TextField(
                controller: noteCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: AppStrings.of(context).addNoteOptional,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              // Save + Delete buttons
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await _saveHighlight(context, highlight, selectedColor, noteCtrl.text.trim());
                      },
                      child: Text(AppStrings.of(context).save),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await _deleteWithConfirm(context, highlight);
                    },
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    tooltip: 'Delete',
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveHighlight(
    BuildContext context, Highlight highlight, int newColor, String newNote,
  ) async {
    if (newColor != highlight.colorValue) {
      await highlightManager.changeHighlightColor(context, highlight, newColor);
    }
    if (newNote != highlight.note) {
      final updated = highlightManager.getAllHighlights()
          .where((h) => h.page == highlight.page && h.startIndex == highlight.startIndex)
          .firstOrNull ?? highlight;
      if (!context.mounted) return;
      await highlightManager.editHighlightNote(context, updated, newNote);
    }
    onRefresh();
    viewerController.invalidate();
  }

  Future<void> _deleteWithConfirm(BuildContext context, Highlight highlight) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.of(context).deleteHighlight),
        content: Text(AppStrings.of(context).deleteHighlightConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppStrings.of(context).cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppStrings.of(context).delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;
    await highlightManager.deleteHighlight(context, highlight);
    onRefresh();
    viewerController.invalidate();
  }

  // ── Highlight list ──

  void _showList({
    required BuildContext context,
    required List<Highlight> highlights,
    required bool showPage,
    ValueChanged<int>? onPageSelected,
    String title = 'Highlights',
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetCtx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.8,
        minChildSize: 0.3,
        expand: false,
        builder: (_, scrollCtrl) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(title, style: Theme.of(context).textTheme.titleMedium),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollCtrl,
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
                        if (showPage)
                          Text(AppStrings.of(context).page(h.page + 1),
                              style: Theme.of(context).textTheme.bodySmall),
                        if (h.note.isNotEmpty)
                          Text(h.note,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontStyle: FontStyle.italic)),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                      onPressed: () async {
                        Navigator.pop(sheetCtx);
                        await _deleteWithConfirm(context, h);
                      },
                    ),
                    onTap: () {
                      Navigator.pop(sheetCtx);
                      if (onPageSelected != null) {
                        onPageSelected(h.page);
                      }
                      // Show edit form
                      Future.delayed(const Duration(milliseconds: 300), () {
                        if (context.mounted) {
                          _showHighlightForm(context, h);
                        }
                      });
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
