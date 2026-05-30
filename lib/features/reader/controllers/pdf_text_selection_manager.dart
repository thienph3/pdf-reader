import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import '../../../core/l10n/app_strings.dart';
import './pdf_highlight_manager.dart';
import '../../../models/highlight.dart';

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
          onConfirm: (color, note, type) async {
            highlightManager!.currentHighlightColor = color;
            await highlightManager!.createHighlightFromSelection(
              range,
              selectedText,
              onHighlightCreated,
              note: note,
              type: type,
            );
            highlightManager!.viewerController.invalidate();
          },
        );
      },
      label: AppStrings.of(context).highlight,
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
    required Future<void> Function(int color, String note, AnnotationType type) onConfirm,
  }) {
    int selectedColor = highlightManager?.currentHighlightColor ?? 0x80FFEB3B;
    var selectedType = AnnotationType.highlight;
    final noteController = TextEditingController();

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
              Text(AppStrings.of(context).highlight,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _highlightColors.map((color) {
                  final isSelected = selectedColor == color;
                  return GestureDetector(
                    onTap: () => setSheetState(() => selectedColor = color),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Color(color),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outlineVariant,
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
              SegmentedButton<AnnotationType>(
                segments: const [
                  ButtonSegment(value: AnnotationType.highlight, icon: Icon(Icons.highlight), label: Text('Highlight')),
                  ButtonSegment(value: AnnotationType.underline, icon: Icon(Icons.format_underline), label: Text('Underline')),
                  ButtonSegment(value: AnnotationType.strikethrough, icon: Icon(Icons.format_strikethrough), label: Text('Strike')),
                ],
                selected: {selectedType},
                onSelectionChanged: (v) => setSheetState(() => selectedType = v.first),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: AppStrings.of(context).addNoteOptional,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    onConfirm(selectedColor, noteController.text.trim(), selectedType);
                  },
                  child: Text(AppStrings.of(context).save),
                ),
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
    final s = AppStrings.of(context);
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.color_lens),
              title: Text(s.changeColor),
              onTap: () {
                Navigator.pop(ctx);
                onActionSelected(HighlightEditAction.changeColor);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text(s.deleteHighlight,
                  style: const TextStyle(color: Colors.red)),
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
