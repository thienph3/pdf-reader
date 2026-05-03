import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'pdf_highlight_manager.dart';
import '../models/highlight.dart';

/// Manages text selection and context menu functionality for PDF viewer.
class PdfTextSelectionManager {
  final PdfHighlightManager? highlightManager;
  final VoidCallback? onHighlightCreated;

  PdfTextSelectionManager({
    this.highlightManager,
    this.onHighlightCreated,
  });

  /// Creates highlight button for context menu.
  ContextMenuButtonItem buildHighlightButton(
    BuildContext context,
    PdfViewerContextMenuBuilderParams params,
  ) {
    final delegate = params.textSelectionDelegate;
    return ContextMenuButtonItem(
      onPressed: () async {
        debugPrint('Highlight button pressed');
        try {
          final ranges = await delegate.getSelectedTextRanges();
          debugPrint('ranges: ${ranges.length}');
          if (ranges.isEmpty) {
            params.dismissContextMenu();
            return;
          }
          final range = ranges.first;
          debugPrint('range: page=${range.pageNumber} start=${range.start} end=${range.end}');
          final selectedText = await delegate.getSelectedText();
          debugPrint('selectedText: $selectedText');
          debugPrint('highlightManager: $highlightManager, bookId: ${highlightManager?.bookId}');
          if (highlightManager != null) {
            await highlightManager!.createHighlightFromSelection(
              range,
              selectedText,
              onHighlightCreated,
            );
            debugPrint('Highlight created successfully');
          }
        } catch (e, st) {
          debugPrint('Create highlight error: $e');
          debugPrint('Stack trace: $st');
        }
        params.dismissContextMenu();
      },
      label: 'Highlight',
    );
  }

  /// Shows a quick edit menu for a highlight.
  void showHighlightEditMenu(
    BuildContext context,
    Highlight highlight,
    ValueChanged<HighlightEditAction> onActionSelected,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.color_lens),
              title: const Text('Change Color'),
              onTap: () {
                Navigator.pop(ctx);
                onActionSelected(HighlightEditAction.changeColor);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Highlight',
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(ctx);
                onActionSelected(HighlightEditAction.delete);
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Actions that can be performed on a highlight.
enum HighlightEditAction {
  changeColor,
  delete,
}
