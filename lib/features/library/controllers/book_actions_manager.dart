import 'package:flutter/material.dart';
import '../../../models/book.dart';
import '../../../services/book_service.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/utils/dialogs.dart';
import '../../../core/routing/shared_route.dart';
import '../../reader/screens/epub_view_screen.dart';
import '../screens/book_form_screen.dart';

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
    
    if (file.toLowerCase().endsWith('.epub')) {
      await Navigator.push(context, buildPageRoute(EpubViewScreen(
        filePath: file,
        fileName: book.title,
        bookId: book.id,
      )));
    } else {
      await openPdfViewer(
        context,
        filePath: file,
        fileName: book.title,
        bookId: book.id,
        initialPage: book.lastPage,
      );
    }
    
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
    final confirm = await showConfirmDialog(
      context,
      title: s.deleteBook,
      content: s.deleteBookConfirm(book.title),
      confirmLabel: s.delete,
      cancelLabel: s.cancel,
    );
    
    if (confirm && context.mounted) {
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
    showAppSnackBar(context, '$title: ${AppStrings.of(context).nBooks(bookCount)}');
  }
}