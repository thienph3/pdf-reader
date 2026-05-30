import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';

const presetColors = [
  0xFF6366F1, 0xFFEF4444, 0xFFF97316, 0xFFEAB308, 0xFF22C55E,
  0xFF06B6D4, 0xFF3B82F6, 0xFF8B5CF6, 0xFFEC4899, 0xFF78716C,
];

class CategoryDialogResult {
  final String name;
  final int color;
  const CategoryDialogResult({required this.name, required this.color});
}

Future<CategoryDialogResult?> showCategoryDialog(
  BuildContext context, {
  String initialName = '',
  int initialColor = 0xFF6366F1,
}) {
  final s = AppStrings.of(context);
  final ctrl = TextEditingController(text: initialName);
  int selectedColor = initialColor;

  return showDialog<CategoryDialogResult>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) => AlertDialog(
        title: Text(initialName.isEmpty ? s.addCategory : s.editCategory),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: ctrl, autofocus: true, decoration: InputDecoration(labelText: s.categoryName, border: const OutlineInputBorder())),
          const SizedBox(height: 16),
          Wrap(spacing: 8, runSpacing: 8, children: presetColors.map((color) {
            final isSelected = selectedColor == color;
            return GestureDetector(
              onTap: () => setDialogState(() => selectedColor = color),
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: Color(color), shape: BoxShape.circle, border: isSelected ? Border.all(color: Theme.of(ctx).colorScheme.onSurface, width: 3) : null),
                child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
              ),
            );
          }).toList()),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(s.cancel)),
          FilledButton(onPressed: () { final name = ctrl.text.trim(); if (name.isEmpty) return; Navigator.pop(ctx, CategoryDialogResult(name: name, color: selectedColor)); }, child: Text(s.save)),
        ],
      ),
    ),
  );
}
