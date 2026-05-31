import '../models/book.dart';

/// Repository contract for Book persistence.
/// Future migration target: replace Hive with SQLite/Drift.
abstract class BookRepository {
  List<Book> getAll();
  Book? getById(String id);
  Future<Book> create({
    required String title,
    String author = '',
    BookFormat format = BookFormat.paper,
    String? filePath,
    String? categoryId,
    String notes = '',
  });
  Future<Book> update(Book book);
  Future<void> delete(String id);
}
