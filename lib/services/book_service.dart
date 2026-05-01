import 'dart:convert';
import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/book.dart';

const _boxName = 'books';
const _uuid = Uuid();

class BookService {
  late Box<Map> _box;
  List<Book>? _sortedCache;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<Map>(_boxName);
  }

  void _invalidateCache() => _sortedCache = null;

  List<Book> getAll() {
    if (_sortedCache != null) return _sortedCache!;
    _sortedCache = _box.values.map((m) => Book.fromMap(m)).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return _sortedCache!;
  }

  Book? getById(String id) {
    final map = _box.get(id);
    if (map == null) return null;
    return Book.fromMap(map);
  }

  Future<Book> create({
    required String title,
    String author = '',
    BookFormat format = BookFormat.paper,
    String? filePath,
    String notes = '',
  }) async {
    final now = DateTime.now();
    final book = Book(
      id: _uuid.v4(),
      title: title,
      author: author,
      format: format,
      filePath: filePath,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
    await _box.put(book.id, book.toMap());
    _invalidateCache();
    return book;
  }

  Future<Book> update(Book book) async {
    final updated = book.copyWith(updatedAt: DateTime.now());
    await _box.put(updated.id, updated.toMap());
    _invalidateCache();
    return updated;
  }

  Future<Book> saveProgress(String bookId, int page,
      {int? totalPages, int? addSeconds}) async {
    final book = getById(bookId);
    if (book == null) throw StateError('Book not found: $bookId');
    final updated = book.copyWith(
      lastPage: page,
      totalPages: totalPages ?? book.totalPages,
      readingSeconds:
          addSeconds != null ? book.readingSeconds + addSeconds : null,
      updatedAt: DateTime.now(),
    );
    await _box.put(updated.id, updated.toMap());
    _invalidateCache();
    return updated;
  }

  // --- Bookmarks ---

  Future<Book> addBookmark(String bookId, int page, {String note = ''}) async {
    final book = getById(bookId);
    if (book == null) throw StateError('Book not found: $bookId');
    // Don't duplicate same page
    if (book.bookmarks.any((b) => b.page == page)) return book;
    final bm = Bookmark(page: page, note: note, createdAt: DateTime.now());
    final updated = book.copyWith(
      bookmarks: [...book.bookmarks, bm],
      updatedAt: DateTime.now(),
    );
    await _box.put(updated.id, updated.toMap());
    _invalidateCache();
    return updated;
  }

  Future<Book> removeBookmark(String bookId, int page) async {
    final book = getById(bookId);
    if (book == null) throw StateError('Book not found: $bookId');
    final updated = book.copyWith(
      bookmarks: book.bookmarks.where((b) => b.page != page).toList(),
      updatedAt: DateTime.now(),
    );
    await _box.put(updated.id, updated.toMap());
    _invalidateCache();
    return updated;
  }

  bool isBookmarked(String bookId, int page) {
    final book = getById(bookId);
    return book?.bookmarks.any((b) => b.page == page) ?? false;
  }

  // --- Export / Import ---

  Future<String> exportToJson() async {
    final books = getAll().map((b) => b.toMap()).toList();
    return jsonEncode(books);
  }

  Future<File> exportToFile(String path) async {
    final json = await exportToJson();
    return File(path).writeAsString(json);
  }

  Future<int> importFromJson(String json) async {
    final list = jsonDecode(json) as List;
    int count = 0;
    for (final item in list) {
      final book = Book.fromMap(item as Map);
      // Skip if already exists
      if (getById(book.id) != null) continue;
      await _box.put(book.id, book.toMap());
      count++;
    }
    _invalidateCache();
    return count;
  }

  Future<int> importFromFile(String path) async {
    final json = await File(path).readAsString();
    return importFromJson(json);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
    _invalidateCache();
  }

  Future<void> restore(Book book) async {
    await _box.put(book.id, book.toMap());
    _invalidateCache();
  }
}
