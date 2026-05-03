import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../l10n/app_strings.dart';
import '../models/book.dart';
import '../services/book_service.dart';

/// Validates a book's file path. If invalid, prompts user to pick a new file.
Future<String?> validateBookPath(BuildContext context, Book book, BookService bookService) async {
  final path = book.filePath;
  if (path != null && path.isNotEmpty) {
    if (await io.File(path).exists()) return path;
  }
  if (!context.mounted) return null;
  final s = AppStrings.of(context);
  final shouldRepick = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(s.fileNotFound),
      content: Text(s.fileInvalidMessage),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.cancel)),
        FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.repick)),
      ],
    ),
  );
  if (shouldRepick != true || !context.mounted) return null;
  final result = await FilePicker.pickFiles(
      type: FileType.custom, allowedExtensions: ['pdf']);
  if (result != null && result.files.single.path != null) {
    final newPath = result.files.single.path!;
    await bookService.update(book.copyWith(filePath: () => newPath));
    return newPath;
  }
  return null;
}

/// Exports all books to a JSON file chosen by user.
Future<void> exportBooks(BuildContext context, BookService bookService) async {
  final s = AppStrings.of(context);
  final path = await FilePicker.saveFile(
    dialogTitle: s.exportLib,
    fileName: 'books_backup.json',
  );
  if (path == null) return;
  await bookService.exportToFile(path);
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(s.exportSuccess)),
  );
}

/// Imports books from a JSON file chosen by user. Returns count imported.
Future<int> importBooks(BuildContext context, BookService bookService) async {
  final result = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['json'],
  );
  if (result == null || result.files.single.path == null) return 0;
  final count = await bookService.importFromFile(result.files.single.path!);
  if (!context.mounted) return count;
  final s = AppStrings.of(context);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(s.importSuccess(count))),
  );
  return count;
}