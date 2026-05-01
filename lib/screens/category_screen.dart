import 'package:flutter/material.dart';
import '../main.dart';
import '../models/category.dart';
import '../services/category_service.dart';
import '../l10n/app_strings.dart';

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
    final name = await _showNameDialog();
    if (name == null || name.trim().isEmpty) return;
    await _catService.create(name: name.trim());
    _refresh();
  }

  Future<void> _editCategory(Category cat) async {
    final name = await _showNameDialog(initial: cat.name);
    if (name == null || name.trim().isEmpty) return;
    await _catService.update(cat.copyWith(name: name.trim()));
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
            child: Text(s.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.delete),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _catService.delete(cat.id);
      _refresh();
    }
  }

  Future<String?> _showNameDialog({String initial = ''}) {
    final s = AppStrings.of(context);
    final ctrl = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(initial.isEmpty ? s.addCategory : s.editCategory),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(
            labelText: s.categoryName,
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text),
            child: Text(s.save),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.categories)),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCategory,
        child: const Icon(Icons.add),
      ),
      body: _categories.isEmpty
          ? Center(
              child: Text(
                s.noCategoriesYet,
                textAlign: TextAlign.center,
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
