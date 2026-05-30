import 'package:hive_flutter/hive_flutter.dart';
import '../models/book.dart';
import '../models/highlight.dart';

/// Mixin providing bookmark and highlight operations for BookService.
mixin BookServiceAnnotations {
  Box<Map> get box;
  Book? getById(String id);
  void invalidateCache();

  // --- Bookmarks ---

  Future<Book> addBookmark(String bookId, int page, {String note = ''}) async {
    final book = getById(bookId);
    if (book == null) throw StateError('Book not found: $bookId');
    if (book.bookmarks.any((b) => b.page == page)) return book;
    final bm = Bookmark(page: page, note: note, createdAt: DateTime.now());
    final updated = book.copyWith(bookmarks: [...book.bookmarks, bm], updatedAt: DateTime.now());
    await box.put(updated.id, updated.toMap());
    invalidateCache();
    return updated;
  }

  Future<Book> removeBookmark(String bookId, int page) async {
    final book = getById(bookId);
    if (book == null) throw StateError('Book not found: $bookId');
    final updated = book.copyWith(bookmarks: book.bookmarks.where((b) => b.page != page).toList(), updatedAt: DateTime.now());
    await box.put(updated.id, updated.toMap());
    invalidateCache();
    return updated;
  }

  bool isBookmarked(String bookId, int page) {
    final book = getById(bookId);
    return book?.bookmarks.any((b) => b.page == page) ?? false;
  }

  Future<Book> updateBookmarkNote(String bookId, int page, String note) async {
    final book = getById(bookId);
    if (book == null) throw StateError('Book not found: $bookId');
    final updated = book.copyWith(bookmarks: book.bookmarks.map((b) => b.page == page ? b.copyWith(note: note) : b).toList(), updatedAt: DateTime.now());
    await box.put(updated.id, updated.toMap());
    invalidateCache();
    return updated;
  }

  // --- Highlights ---

  Future<Book> addHighlight(String bookId, Highlight highlight) async {
    final book = getById(bookId);
    if (book == null) throw StateError('Book not found: $bookId');
    final updated = book.copyWith(highlights: [...book.highlights, highlight], updatedAt: DateTime.now());
    await box.put(updated.id, updated.toMap());
    invalidateCache();
    return updated;
  }

  Future<Book> removeHighlight(String bookId, String highlightId) async {
    final book = getById(bookId);
    if (book == null) throw StateError('Book not found: $bookId');
    final updated = book.copyWith(highlights: book.highlights.where((h) => h.id != highlightId).toList(), updatedAt: DateTime.now());
    await box.put(updated.id, updated.toMap());
    invalidateCache();
    return updated;
  }

  Future<Book> updateHighlightNote(String bookId, String highlightId, String note) async {
    final book = getById(bookId);
    if (book == null) throw StateError('Book not found: $bookId');
    final updated = book.copyWith(highlights: book.highlights.map((h) => h.id == highlightId ? h.copyWith(note: note) : h).toList(), updatedAt: DateTime.now());
    await box.put(updated.id, updated.toMap());
    invalidateCache();
    return updated;
  }

  Future<Book> updateHighlightColor(String bookId, String highlightId, int colorValue) async {
    final book = getById(bookId);
    if (book == null) throw StateError('Book not found: $bookId');
    final updated = book.copyWith(highlights: book.highlights.map((h) => h.id == highlightId ? h.copyWith(colorValue: colorValue) : h).toList(), updatedAt: DateTime.now());
    await box.put(updated.id, updated.toMap());
    invalidateCache();
    return updated;
  }

  List<Highlight> getHighlightsForPage(String bookId, int page) {
    final book = getById(bookId);
    if (book == null) return [];
    return book.highlights.where((h) => h.page == page).toList();
  }
}
