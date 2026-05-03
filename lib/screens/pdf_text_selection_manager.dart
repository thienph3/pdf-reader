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
        // Capture selection data before dismissing
        final ranges = await delegate.getSelectedTextRanges();
        final selectedText = await delegate.getSelectedText();
        params.dismissContextMenu();

        if (ranges.isEmpty || highlightManager == null) return;
        if (!context.mounted) return;

        final range = ranges.first;

        // Show color picker bottom sheet
        _showHighlightColorPicker(
          context,
          onColorSelected: (color) async {
            highlightManager!.currentHighlightColor = color;
            await highlightManager!.createHighlightFromSelection(
              range,
              selectedText,
              onHighlightCreated,
            );
            // Force viewer repaint
            highlightManager!.viewerController.invalidate();
          },
        );
      },
      label: 'Highlight',
    );
  }

  static const _highlightColors = [
    0x80FFEB3B, // yellow
    0x8066BB6A, // green
    0x8042A5F5, // blue
    0x80EF5350, // red
    0x80AB47BC, // purple
    0x80FF7043, // orange
  ];

  void _showHighlightColorPicker(
    BuildContext context, {
    required Future<void> Function(int color) onColorSelected,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Highlight Color',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _highlightColors.map((color) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(ctx);
                      onColorSelected(color);
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Color(color),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: highlightManager?.currentHighlightColor == color
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade300,
                          width: 3,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
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
