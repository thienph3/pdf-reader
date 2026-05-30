import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/book.dart';
import 'book_service_annotations.dart';

const _boxName = 'books';
const _uuid = Uuid();

class BookService with BookServiceAnnotations {
  late Box<Map> _box;
  List<Book>? _sortedCache;

  @override
  Box<Map> get box => _box;
  @override
  void invalidateCache() => _sortedCache = null;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<Map>(_boxName);
  }

  List<Book> getAll() {
    if (_sortedCache != null) return _sortedCache!;
    final books = <Book>[];
    for (final m in _box.values) {
      try { books.add(Book.fromMap(m)); } catch (e) { debugPrint('BookService: skipping corrupt book entry: $e'); }
    }
    books.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    _sortedCache = books;
    return _sortedCache!;
  }

  @override
  Book? getById(String id) {
    final map = _box.get(id);
    if (map == null) return null;
    return Book.fromMap(map);
  }

  Future<Book> create({
    required String title, String author = '', BookFormat format = BookFormat.paper,
    String? filePath, String? categoryId, String notes = '',
  }) async {
    final now = DateTime.now();
    final book = Book(id: _uuid.v4(), title: title, author: author, format: format, filePath: filePath, categoryId: categoryId, notes: notes, createdAt: now, updatedAt: now);
    await _box.put(book.id, book.toMap());
    invalidateCache();
    return book;
  }

  Future<Book> update(Book book) async {
    final updated = book.copyWith(updatedAt: DateTime.now());
    await _box.put(updated.id, updated.toMap());
    invalidateCache();
    return updated;
  }

  Future<Book> saveProgress(String bookId, int page, {int? totalPages, int? addSeconds}) async {
    final book = getById(bookId);
    if (book == null) throw StateError('Book not found: $bookId');
    final updated = book.copyWith(
      lastPage: page, totalPages: totalPages ?? book.totalPages,
      readingSeconds: addSeconds != null ? book.readingSeconds + addSeconds : null,
      lastOpenedAt: () => DateTime.now(), updatedAt: DateTime.now(),
    );
    await _box.put(updated.id, updated.toMap());
    invalidateCache();
    return updated;
  }

  List<Book> getRecentlyOpened({int limit = 5}) {
    final recent = getAll().where((b) => b.lastOpenedAt != null && b.canRead).toList()
      ..sort((a, b) => b.lastOpenedAt!.compareTo(a.lastOpenedAt!));
    return recent.take(limit).toList();
  }

  // --- Export / Import ---

  Future<File> backupToFile(String path) async {
    final json = await exportToJson();
    return File(path).writeAsString(json);
  }

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
      try {
        if (item is! Map) continue;
        if (item['id'] == null || item['id'] is! String) continue;
        if (item['title'] == null) continue;
        final formatIdx = item['format'] as int? ?? 0;
        if (formatIdx < 0 || formatIdx >= BookFormat.values.length) continue;
        final filePath = item['filePath'] as String?;
        if (filePath != null && (filePath.contains('..') || filePath.contains('\x00'))) item['filePath'] = null;
        final book = Book.fromMap(item);
        if (getById(book.id) != null) continue;
        await _box.put(book.id, book.toMap());
        count++;
      } catch (e) { debugPrint('Import: skipping invalid entry: $e'); }
    }
    invalidateCache();
    return count;
  }

  Future<int> importFromFile(String path) async {
    final json = await File(path).readAsString();
    return importFromJson(json);
  }

  Future<void> delete(String id) async { await _box.delete(id); invalidateCache(); }
  Future<void> restore(Book book) async { await _box.put(book.id, book.toMap()); invalidateCache(); }
}
