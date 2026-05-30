import 'package:flutter/material.dart';
import '../services/book_service.dart';
import '../l10n/app_strings.dart';
import '../utils/dialogs.dart';

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
    final confirmed = await showConfirmDialog(
      context,
      title: s.deleteBook,
      content: 'Delete ${selectedIds.length} books?',
      confirmLabel: s.delete,
      cancelLabel: s.cancel,
    );
    if (!confirmed) return;
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
