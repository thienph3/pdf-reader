import 'package:flutter/material.dart';
import '../main.dart';
import '../models/category.dart';
import '../services/category_service.dart';
import '../l10n/app_strings.dart';

const _presetColors = [
  0xFF6366F1, // indigo
  0xFFEF4444, // red
  0xFFF97316, // orange
  0xFFEAB308, // yellow
  0xFF22C55E, // green
  0xFF06B6D4, // cyan
  0xFF3B82F6, // blue
  0xFF8B5CF6, // violet
  0xFFEC4899, // pink
  0xFF78716C, // stone
];

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<Category> _categories = [];
  bool _initialized = false;

  CategoryService get _catService => CategoryServiceScope.of(context);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _refresh();
    }
  }

  void _refresh() => setState(() => _categories = _catService.getAll());

  Future<void> _addCategory() async {
    final result = await _showCategoryDialog();
    if (result == null) return;
    await _catService.create(name: result.name, colorValue: result.color);
    _refresh();
  }

  Future<void> _editCategory(Category cat) async {
    final result =
        await _showCategoryDialog(initialName: cat.name, initialColor: cat.colorValue);
    if (result == null) return;
    await _catService.update(cat.copyWith(name: result.name, colorValue: result.color));
    _refresh();
  }

  Future<void> _deleteCategory(Category cat) async {
    final s = AppStrings.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.deleteCategory),
        content: Text(s.deleteCategoryConfirm(cat.name)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(s.cancel)),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(s.delete)),
        ],
      ),
    );
    if (confirm == true) {
      await _catService.delete(cat.id);
      _refresh();
    }
  }

  Future<_CategoryDialogResult?> _showCategoryDialog({
    String initialName = '',
    int initialColor = 0xFF6366F1,
  }) {
    final s = AppStrings.of(context);
    final ctrl = TextEditingController(text: initialName);
    int selectedColor = initialColor;

    return showDialog<_CategoryDialogResult>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(initialName.isEmpty ? s.addCategory : s.editCategory),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ctrl,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: s.categoryName,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _presetColors.map((color) {
                  final isSelected = selectedColor == color;
                  return GestureDetector(
                    onTap: () => setDialogState(() => selectedColor = color),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Color(color),
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(
                                color: Theme.of(ctx).colorScheme.onSurface,
                                width: 3)
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 18)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx), child: Text(s.cancel)),
            FilledButton(
              onPressed: () {
                final name = ctrl.text.trim();
                if (name.isEmpty) return;
                Navigator.pop(
                    ctx, _CategoryDialogResult(name: name, color: selectedColor));
              },
              child: Text(s.save),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(s.categories)),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCategory,
        child: const Icon(Icons.add),
      ),
      body: _categories.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.folder_outlined,
                      size: 64,
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  Text(s.noCategoriesYet,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: _categories.length,
              itemBuilder: (_, i) {
                final cat = _categories[i];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(cat.colorValue),
                    child: const Icon(Icons.folder, color: Colors.white),
                  ),
                  title: Text(cat.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editCategory(cat),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _deleteCategory(cat),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _CategoryDialogResult {
  final String name;
  final int color;
  const _CategoryDialogResult({required this.name, required this.color});
}
