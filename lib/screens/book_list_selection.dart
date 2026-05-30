import 'package:flutter/material.dart';
import '../services/book_service.dart';
import '../l10n/app_strings.dart';

class BookListSelection {
  bool selectionMode = false;
  final Set<String> selectedIds = {};

  void enter(String bookId) {
    selectionMode = true;
    selectedIds.add(bookId);
  }

  void toggle(String bookId) {
    if (selectedIds.contains(bookId)) {
      selectedIds.remove(bookId);
      if (selectedIds.isEmpty) selectionMode = false;
    } else {
      selectedIds.add(bookId);
    }
  }

  void exit() {
    selectionMode = false;
    selectedIds.clear();
  }

  Future<void> deleteSelected(
    BuildContext context,
    BookService bookService,
    VoidCallback onDone,
  ) async {
    final s = AppStrings.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.deleteBook),
        content: Text('Delete ${selectedIds.length} books?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(s.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(s.delete)),
        ],
      ),
    );
    if (confirmed != true) return;
    for (final id in selectedIds) {
      await bookService.delete(id);
    }
    exit();
    onDone();
  }

  PreferredSizeWidget buildSelectionAppBar(BuildContext context, VoidCallback onDelete) {
    return AppBar(
      leading: IconButton(icon: const Icon(Icons.close), onPressed: exit),
      title: Text('${selectedIds.length} selected'),
      actions: [
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: selectedIds.isNotEmpty ? onDelete : null,
        ),
      ],
    );
  }
}
