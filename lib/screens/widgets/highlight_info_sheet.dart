import 'package:flutter/material.dart';
import '../../models/highlight.dart';
import '../../l10n/app_strings.dart';

/// Standalone widget for displaying highlight details in a bottom sheet.
class HighlightInfoSheet extends StatelessWidget {
  final Highlight highlight;
  final VoidCallback onEditNote;
  final VoidCallback onDelete;

  const HighlightInfoSheet({
    super.key,
    required this.highlight,
    required this.onEditNote,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Color indicator + page
            Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Color(highlight.colorValue),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(s.page(highlight.page + 1),
                    style: Theme.of(context).textTheme.labelMedium),
              ],
            ),
            const SizedBox(height: 12),
            // Highlighted text
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(highlight.colorValue).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '"${highlight.text}"',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            // Note
            if (highlight.note.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(highlight.note,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      )),
            ],
            const SizedBox(height: 16),
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.edit_note, size: 18),
                  label: Text(s.editNote),
                  onPressed: onEditNote,
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  icon: Icon(Icons.delete_outline,
                      size: 18, color: colorScheme.error),
                  label: Text(s.removeHighlight,
                      style: TextStyle(color: colorScheme.error)),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
