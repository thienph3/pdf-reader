import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../models/highlight.dart';

const _highlightColors = [
  0x80FFEB3B, 0x8066BB6A, 0x8042A5F5,
  0x80EF5350, 0x80AB47BC, 0x80FF7043,
];

void showHighlightEditForm(
  BuildContext context,
  Highlight highlight, {
  required Future<void> Function(int newColor, String newNote) onSave,
  required Future<void> Function() onDelete,
}) {
  int selectedColor = highlight.colorValue;
  final noteCtrl = TextEditingController(text: highlight.note);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16, right: 16, top: 16),
      child: StatefulBuilder(
        builder: (ctx, setSheetState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              highlight.text.length > 100 ? '${highlight.text.substring(0, 100)}...' : highlight.text,
              style: Theme.of(context).textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _highlightColors.map((color) {
                final isSelected = selectedColor == color;
                return GestureDetector(
                  onTap: () => setSheetState(() => selectedColor = color),
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: Color(color), shape: BoxShape.circle,
                      border: Border.all(color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outlineVariant, width: isSelected ? 3 : 1),
                    ),
                    child: isSelected ? const Icon(Icons.check, size: 20, color: Colors.white) : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            TextField(controller: noteCtrl, maxLines: 2, decoration: InputDecoration(hintText: AppStrings.of(context).addNoteOptional, border: const OutlineInputBorder(), isDense: true)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: FilledButton(onPressed: () async { Navigator.pop(ctx); await onSave(selectedColor, noteCtrl.text.trim()); }, child: Text(AppStrings.of(context).save))),
              const SizedBox(width: 12),
              IconButton(onPressed: () { final text = highlight.note.isNotEmpty ? '${highlight.text}\n\n${highlight.note}' : highlight.text; Share.share(text); }, icon: const Icon(Icons.share), tooltip: 'Share'),
              IconButton(onPressed: () async { Navigator.pop(ctx); await onDelete(); }, icon: const Icon(Icons.delete_outline, color: Colors.red), tooltip: 'Delete'),
            ]),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );
}
