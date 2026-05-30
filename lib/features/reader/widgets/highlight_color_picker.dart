import 'package:flutter/material.dart';
import '../../../core/l10n/app_strings.dart';

const highlightColors = [
  0x80FFEB3B, 0x8066BB6A, 0x8042A5F5,
  0x80EF5350, 0x80AB47BC, 0x80FF7043,
];

void showHighlightColorPicker(
  BuildContext context, {
  required int currentColor,
  required ValueChanged<int> onColorSelected,
}) {
  final s = AppStrings.of(context);
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(s.selectHighlightColor),
      content: SizedBox(
        width: 300,
        child: Wrap(
          spacing: 8, runSpacing: 8,
          children: highlightColors.map((color) {
            return GestureDetector(
              onTap: () { onColorSelected(color); Navigator.pop(ctx); },
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: Color(color),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: currentColor == color ? Theme.of(context).colorScheme.primary : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text(s.cancel))],
    ),
  );
}
