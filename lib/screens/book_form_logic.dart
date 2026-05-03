import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/book.dart';
import '../l10n/app_strings.dart';
import '../main.dart';

class BookFormLogic {
  final Book? book;
  final TextEditingController titleCtrl;
  final TextEditingController authorCtrl;
  final TextEditingController notesCtrl;
  BookFormat format;
  String? filePath;
  String? categoryId;

  final String origTitle;
  final String origAuthor;
  final String origNotes;
  final BookFormat origFormat;
  final String? origFilePath;
  final String? origCategoryId;

  BookFormLogic({
    required this.book,
    required this.titleCtrl,
    required this.authorCtrl,
    required this.notesCtrl,
    required this.format,
    required this.filePath,
    required this.categoryId,
  })  : origTitle = titleCtrl.text,
        origAuthor = authorCtrl.text,
        origNotes = notesCtrl.text,
        origFormat = format,
        origFilePath = filePath,
        origCategoryId = categoryId;

  bool get isEditing => book != null;

  bool get hasChanges {
    return titleCtrl.text != origTitle ||
        authorCtrl.text != origAuthor ||
        notesCtrl.text != origNotes ||
        format != origFormat ||
        filePath != origFilePath ||
        categoryId != origCategoryId;
  }

  bool get showFilePicker => format == BookFormat.ebook || format == BookFormat.both;

  Future<void> pickFile({
    required BuildContext context,
    required Function(String) onFilePicked,
  }) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      final name = result.files.single.name;
      final path = result.files.single.path!;
      
      onFilePicked(path);
      
      // Auto-fill title from filename if empty
      if (titleCtrl.text.trim().isEmpty) {
        // Remove .pdf extension
        final title = name.endsWith('.pdf')
            ? name.substring(0, name.length - 4)
            : name;
        titleCtrl.text = title;
      }
    }
  }

  Future<bool> showDiscardDialog(BuildContext context) async {
    final s = AppStrings.of(context);
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.discardTitle),
        content: Text(s.discardMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.continueEditing),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.discard),
          ),
        ],
      ),
    );
    return discard ?? false;
  }

  Future<void> save({
    required BuildContext context,
    required Function(Book) onUpdate,
    required Function({
      required String title,
      required String author,
      required BookFormat format,
      required String? filePath,
      required String? categoryId,
      required String notes,
    }) onCreate,
    required Function(String) evictThumbnail,
    required Function({required String bookId, required String filePath, required int width}) getThumbnail,
  }) async {
    final svc = BookServiceScope.of(context);
    final thumbSvc = ThumbnailServiceScope.of(context);
    final path = showFilePicker ? filePath : null;

    if (isEditing) {
      final updated = book!.copyWith(
        title: titleCtrl.text.trim(),
        author: authorCtrl.text.trim(),
        format: format,
        filePath: () => path,
        categoryId: () => categoryId,
        notes: notesCtrl.text.trim(),
      );
      await svc.update(updated);
      onUpdate(updated);
    } else {
      await svc.create(
        title: titleCtrl.text.trim(),
        author: authorCtrl.text.trim(),
        format: format,
        filePath: path,
        categoryId: categoryId,
        notes: notesCtrl.text.trim(),
      );
      onCreate(
        title: titleCtrl.text.trim(),
        author: authorCtrl.text.trim(),
        format: format,
        filePath: path,
        categoryId: categoryId,
        notes: notesCtrl.text.trim(),
      );
    }

    // Evict old thumbnail if file changed
    final origPath = origFilePath;
    if (isEditing && origPath != null && origPath != path) {
      thumbSvc.evict(book!.id);
      evictThumbnail(book!.id);
    }

    // Pre-render thumbnail for existing books when file changes
    if (isEditing && path != null && path.isNotEmpty) {
      thumbSvc.getThumbnail(
          bookId: book!.id, filePath: path, width: 300);
      getThumbnail(bookId: book!.id, filePath: path, width: 300);
    }
  }

  String fileNameFromPath(String path) {
    final sep = path.contains('\\') ? '\\' : '/';
    return path.split(sep).last;
  }
}