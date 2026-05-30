import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import '../l10n/app_strings.dart';
import '../models/highlight.dart';
import '../utils/dialogs.dart';
import 'pdf_highlight_manager.dart';
import 'pdf_highlight_edit_form.dart';

/// UI components for highlights in PDF viewer.
class PdfViewHighlightsUi {
  final PdfHighlightManager highlightManager;
  final PdfViewerController viewerController;
  final int currentPage;
  final VoidCallback onRefresh;

  PdfViewHighlightsUi({
    required this.highlightManager, required this.viewerController,
    required this.currentPage, required this.onRefresh,
  });

  void showEditMenuForHighlight({required BuildContext context, required Highlight highlight}) {
    showHighlightEditForm(context, highlight,
      onSave: (newColor, newNote) => _saveHighlight(context, highlight, newColor, newNote),
      onDelete: () => _deleteWithConfirm(context, highlight),
    );
  }

  void showHighlightsList({required BuildContext context, required ValueChanged<int> onPageSelected}) {
    final highlights = highlightManager.getAllHighlights();
    if (highlights.isEmpty) {
      showAppSnackBar(context, AppStrings.of(context).noHighlightsFound);
      return;
    }
    _showList(context: context, highlights: highlights, showPage: true, onPageSelected: onPageSelected);
  }

  void showCurrentPageHighlights({required BuildContext context, required int currentPage}) {
    final items = highlightManager.getHighlightsForCurrentPage(currentPage);
    if (items.isEmpty) {
      showAppSnackBar(context, AppStrings.of(context).noHighlightsOnPage);
      return;
    }
    _showList(context: context, highlights: items, showPage: false, title: AppStrings.of(context).highlightsOnPage(currentPage + 1));
  }

  Future<void> _saveHighlight(BuildContext context, Highlight highlight, int newColor, String newNote) async {
    if (newColor != highlight.colorValue) await highlightManager.changeHighlightColor(context, highlight, newColor);
    if (newNote != highlight.note) {
      final updated = highlightManager.getAllHighlights().where((h) => h.page == highlight.page && h.startIndex == highlight.startIndex).firstOrNull ?? highlight;
      if (!context.mounted) return;
      await highlightManager.editHighlightNote(context, updated, newNote);
    }
    onRefresh();
    viewerController.invalidate();
  }

  Future<void> _deleteWithConfirm(BuildContext context, Highlight highlight) async {
    final s = AppStrings.of(context);
    final confirmed = await showConfirmDialog(
      context,
      title: s.deleteHighlight,
      content: s.deleteHighlightConfirm,
      confirmLabel: s.delete,
      cancelLabel: s.cancel,
    );
    if (!confirmed || !context.mounted) return;
    await highlightManager.deleteHighlight(context, highlight);
    onRefresh();
    viewerController.invalidate();
  }

  void _showList({
    required BuildContext context, required List<Highlight> highlights,
    required bool showPage, ValueChanged<int>? onPageSelected, String? title,
  }) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      builder: (sheetCtx) => DraggableScrollableSheet(
        initialChildSize: 0.5, maxChildSize: 0.8, minChildSize: 0.3, expand: false,
        builder: (_, scrollCtrl) => Column(children: [
          Padding(padding: const EdgeInsets.all(16), child: Text(title ?? AppStrings.of(context).highlights, style: Theme.of(context).textTheme.titleMedium)),
          Expanded(child: ListView.builder(
            controller: scrollCtrl, itemCount: highlights.length,
            itemBuilder: (_, i) {
              final h = highlights[i];
              return ListTile(
                leading: Container(width: 24, height: 24, decoration: BoxDecoration(color: Color(h.colorValue), borderRadius: BorderRadius.circular(4), border: Border.all(color: Theme.of(context).colorScheme.outline))),
                title: Text(h.text.length > 80 ? '${h.text.substring(0, 80)}...' : h.text, maxLines: 2, overflow: TextOverflow.ellipsis),
                subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (showPage) Text(AppStrings.of(context).page(h.page + 1), style: Theme.of(context).textTheme.bodySmall),
                  if (h.note.isNotEmpty) Text(h.note, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
                ]),
                trailing: IconButton(icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red), onPressed: () async { Navigator.pop(sheetCtx); await _deleteWithConfirm(context, h); }),
                onTap: () { Navigator.pop(sheetCtx); if (onPageSelected != null) onPageSelected(h.page); Future.delayed(const Duration(milliseconds: 300), () { if (context.mounted) showEditMenuForHighlight(context: context, highlight: h); }); },
              );
            },
          )),
        ]),
      ),
    );
  }
}
