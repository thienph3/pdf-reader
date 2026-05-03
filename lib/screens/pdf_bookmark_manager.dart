import 'package:flutter/material.dart';
import '../services/book_service.dart';
import '../models/book.dart';
import '../l10n/app_strings.dart';
import 'widgets/bookmark_sheet.dart';

/// Manages bookmark-related functionality for PDF viewer.
class PdfBookmarkManager {
  final BookService? bookService;
  final String? bookId;
  final VoidCallback? onBookmarksUpdated;

  PdfBookmarkManager({
    required this.bookService,
    required this.bookId,
    this.onBookmarksUpdated,
  });

  /// Checks if the current page is bookmarked.
  bool isBookmarked(int currentPage) {
    if (bookId == null || bookService == null) return false;
    return bookService!.isBookmarked(bookId!, currentPage);
  }

  /// Toggles bookmark for the current page.
  void toggleBookmark(int currentPage) {
    if (bookId == null || bookService == null) return;
    
    if (isBookmarked(currentPage)) {
      bookService!.removeBookmark(bookId!, currentPage);
    } else {
      bookService!.addBookmark(bookId!, currentPage);
    }
    
    onBookmarksUpdated?.call();
  }

  /// Adds or updates a note for a bookmark.
  Future<void> addOrUpdateBookmarkNote(
    BuildContext context,
    int page,
    String note,
  ) async {
    if (bookId == null || bookService == null) return;
    
    // First ensure the page is bookmarked
    if (!isBookmarked(page)) {
      bookService!.addBookmark(bookId!, page);
      onBookmarksUpdated?.call();
    }
    
    // Update the note
    await bookService!.updateBookmarkNote(bookId!, page, note);
  }

  /// Shows a dialog to edit bookmark note.
  void showEditNoteDialog(
    BuildContext context,
    int currentPage,
    String initialNote,
  ) {
    final controller = TextEditingController(text: initialNote);
    final s = AppStrings.of(context);
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.editNote),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: s.noteHint,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.cancel),
          ),
          FilledButton(
            onPressed: () async {
              try {
                await addOrUpdateBookmarkNote(context, currentPage, controller.text.trim());
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                }
              } catch (error) {
                // Handle error
              }
            },
            child: Text(s.save),
          ),
        ],
      ),
    );
  }

  /// Shows the bookmarks list in a bottom sheet.
  void showBookmarksList(
    BuildContext context,
    int currentPage,
    ValueChanged<int> onPageSelected,
  ) {
    if (bookId == null || bookService == null) return;
    
    final book = bookService!.getById(bookId!);
    if (book == null) {
      final s = AppStrings.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.noBookmarks)),
      );
      return;
    }
    
    if (book.bookmarks.isEmpty) {
      final s = AppStrings.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.noBookmarks)),
      );
      return;
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.8,
        minChildSize: 0.3,
        expand: false,
        builder: (_, scrollCtrl) => BookmarkSheet(
          bookmarks: book.bookmarks,
          currentPage: currentPage,
          scrollController: scrollCtrl,
          onTap: (page) {
            Navigator.pop(ctx);
            onPageSelected(page);
          },
          onDelete: (page) {
            bookService!.removeBookmark(bookId!, page);
            Navigator.pop(ctx);
            onBookmarksUpdated?.call();
          },
          onEditNote: (page) {
            Navigator.pop(ctx);
            onPageSelected(page);
            Future.delayed(const Duration(milliseconds: 300), () {
              if (context.mounted) {
                final bookmark = book.bookmarks.firstWhere((b) => b.page == page);
                showEditNoteDialog(context, page, bookmark.note);
              }
            });
          },
        ),
      ),
    );
  }

  /// Gets all bookmarks for the book.
  List<Bookmark> getAllBookmarks() {
    if (bookId == null || bookService == null) return [];
    
    final book = bookService!.getById(bookId!);
    if (book == null) return [];
    
    return book.bookmarks;
  }
}