import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/book_service.dart';
import '../l10n/app_strings.dart';
import 'shared_route.dart';
import 'book_form_screen.dart';
import 'pdf_view_screen.dart';

/// Manages book-related actions (open, edit, delete, etc.).
class BookActionsManager {
  final BookService bookService;

  BookActionsManager({required this.bookService});

  /// Opens a book for reading.
  Future<void> openBook(
    BuildContext context,
    Book book, {
    required Future<String?> Function(BuildContext, Book, BookService) validateBookPath,
    required VoidCallback onRefresh,
  }) async {
    if (!book.canRead) return;
    
    final file = await validateBookPath(context, book, bookService);
    if (file != null) onRefresh(); // path may have been updated
    if (file == null) return;
    if (!context.mounted) return;
    
    await Navigator.push(
      context,
      buildPageRoute(PdfViewScreen(
        filePath: file,
        fileName: book.title,
        bookId: book.id,
        initialPage: book.lastPage,
      )),
    );
    
    onRefresh();
  }

  /// Opens the book form for adding a new book.
  Future<void> addBook(
    BuildContext context, {
    required VoidCallback onRefresh,
  }) async {
    final created = await Navigator.push<bool>(
      context,
      buildPageRoute(const BookFormScreen()),
    );
    
    if (created == true) onRefresh();
  }

  /// Opens the book form for editing an existing book.
  Future<void> editBook(
    BuildContext context,
    Book book, {
    required VoidCallback onRefresh,
  }) async {
    final updated = await Navigator.push<bool>(
      context,
      buildPageRoute(BookFormScreen(book: book)),
    );
    
    if (updated == true) onRefresh();
  }

  /// Shows a confirmation dialog and deletes a book.
  Future<void> confirmAndDeleteBook(
    BuildContext context,
    Book book, {
    required Future<void> Function(BuildContext, Book) onDelete,
  }) async {
    final s = AppStrings.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.deleteBook),
        content: Text(s.deleteBookConfirm(book.title)),
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
    
    if (confirm == true && context.mounted) {
      await onDelete(context, book);
    }
  }

  /// Exports books.
  Future<void> exportBooks(
    BuildContext context, {
    required Future<void> Function(BuildContext, BookService) exportFunction,
  }) async {
    await exportFunction(context, bookService);
  }

  /// Imports books.
  Future<void> importBooks(
    BuildContext context, {
    required Future<int> Function(BuildContext, BookService) importFunction,
    required VoidCallback onRefresh,
  }) async {
    final count = await importFunction(context, bookService);
    if (count > 0) onRefresh();
  }

  /// Shows a snackbar when a smart collection is tapped.
  void showSmartCollectionSnackbar(
    BuildContext context,
    String title,
    int bookCount,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title: $bookCount books'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}