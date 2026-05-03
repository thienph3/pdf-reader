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

  /// Builds a custom context menu for text selection with "Create Highlight" option.
  Widget? buildTextSelectionContextMenu(
    BuildContext context,
    PdfViewerContextMenuBuilderParams params,
  ) {
    debugPrint('buildContextMenu called: contextMenuFor=${params.contextMenuFor}');
    
    // Only show for text selection
    if (params.contextMenuFor != PdfViewerPart.selectedText) {
      debugPrint('buildContextMenu: not selectedText, returning null');
      return null;
    }

    // Check if we have a highlight manager
    if (highlightManager == null) {
      debugPrint('buildContextMenu: highlightManager is null');
      return null;
    }

    // Get the text selection delegate
    final delegate = params.textSelectionDelegate;
    if (!delegate.hasSelectedText) {
      debugPrint('buildContextMenu: no selected text');
      return null;
    }

    debugPrint('buildContextMenu: building menu with selected text');

    // Build context menu items
    final items = <ContextMenuButtonItem>[
      // Copy option
      if (delegate.isCopyAllowed)
        ContextMenuButtonItem(
          onPressed: () {
            delegate.copyTextSelection();
            params.dismissContextMenu();
          },
          type: ContextMenuButtonType.copy,
        ),
      // Select All option
      if (!delegate.isSelectingAllText)
        ContextMenuButtonItem(
          onPressed: () {
            delegate.selectAllText();
            params.dismissContextMenu();
          },
          type: ContextMenuButtonType.selectAll,
        ),
      // Create Highlight option
      ContextMenuButtonItem(
        onPressed: () async {
          try {
            final ranges = await delegate.getSelectedTextRanges();
            if (ranges.isEmpty) {
              params.dismissContextMenu();
              return;
            }
            
            final range = ranges.first;
            final selectedText = await delegate.getSelectedText();
            
            if (context.mounted && highlightManager != null) {
              await highlightManager!.createHighlightFromSelection(
                context,
                range,
                selectedText,
                onHighlightCreated,
              );
            }
          } catch (e) {
            debugPrint('Create highlight error: $e');
          } finally {
            if (context.mounted) {
              params.dismissContextMenu();
            }
          }
        },
        label: 'Create Highlight',
      ),
      // Change Highlight Color option
      ContextMenuButtonItem(
        onPressed: () {
          params.dismissContextMenu();
          Future.delayed(const Duration(milliseconds: 200), () {
            if (context.mounted) {
              highlightManager!.showColorPicker(context, onColorSelected: (color) {
                highlightManager!.currentHighlightColor = color;
              });
            }
          });
        },
        label: 'Change Highlight Color',
      ),
    ];

    if (items.isEmpty) {
      return null;
    }

    debugPrint('buildContextMenu: returning toolbar with ${items.length} items');
    return AdaptiveTextSelectionToolbar.buttonItems(
      anchors: TextSelectionToolbarAnchors(
        primaryAnchor: params.anchorA,
        secondaryAnchor: params.anchorB,
      ),
      buttonItems: items,
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
              leading: const Icon(Icons.note),
              title: const Text('Edit Note'),
              onTap: () {
                Navigator.pop(ctx);
                onActionSelected(HighlightEditAction.editNote);
              },
            ),
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
              title: const Text('Delete Highlight', style: TextStyle(color: Colors.red)),
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
  editNote,
  changeColor,
  delete,
}