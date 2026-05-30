import 'package:flutter/material.dart';
import '../main.dart';
import '../models/category.dart';
import '../services/category_service.dart';
import '../l10n/app_strings.dart';
import 'category_dialog.dart';

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
    if (!_initialized) { _initialized = true; _refresh(); }
  }

  void _refresh() => setState(() => _categories = _catService.getAll());

  Future<void> _addCategory() async {
    final result = await showCategoryDialog(context);
    if (result == null) return;
    await _catService.create(name: result.name, colorValue: result.color);
    _refresh();
  }

  Future<void> _editCategory(Category cat) async {
    final result = await showCategoryDialog(context, initialName: cat.name, initialColor: cat.colorValue);
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
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(s.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(s.delete)),
        ],
      ),
    );
    if (confirm == true) {
      if (!mounted) return;
      final bookService = BookServiceScope.of(context);
      for (final book in bookService.getAll().where((b) => b.categoryId == cat.id)) {
        await bookService.update(book.copyWith(categoryId: () => null));
      }
      await _catService.delete(cat.id);
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(s.categories)),
      floatingActionButton: FloatingActionButton(heroTag: 'addCategory', onPressed: _addCategory, child: const Icon(Icons.add)),
      body: _categories.isEmpty
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.folder_outlined, size: 64, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
              const SizedBox(height: 16),
              Text(s.noCategoriesYet, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
            ]))
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: _categories.length,
              itemBuilder: (_, i) {
                final cat = _categories[i];
                return ListTile(
                  leading: CircleAvatar(backgroundColor: Color(cat.colorValue), child: const Icon(Icons.folder, color: Colors.white)),
                  title: Text(cat.name),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(icon: const Icon(Icons.edit), onPressed: () => _editCategory(cat)),
                    IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _deleteCategory(cat)),
                  ]),
                );
              },
            ),
    );
  }
}
