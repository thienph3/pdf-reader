import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_reader/models/book.dart';
import 'package:pdf_reader/features/library/controllers/book_smart_collections.dart';

class _TestCollection with BookSmartCollections {
  @override
  final List<Book> books;
  _TestCollection(this.books);
}

Book _makeBook({double progress = 0.0, int seconds = 0, DateTime? createdAt}) {
  final now = DateTime.now();
  return Book(
    id: 'b${now.microsecondsSinceEpoch}',
    title: 'Test',
    lastPage: (progress * 100).toInt(),
    totalPages: 100,
    readingSeconds: seconds,
    createdAt: createdAt ?? now,
    updatedAt: now,
  );
}

void main() {
  group('BookSmartCollections', () {
    test('unreadBooks filters progress < 0.1', () {
      final coll = _TestCollection([
        _makeBook(progress: 0.0),
        _makeBook(progress: 0.05),
        _makeBook(progress: 0.5),
      ]);
      expect(coll.unreadBooks.length, 2);
    });

    test('almostFinished filters 0.7 <= progress < 1.0', () {
      final coll = _TestCollection([
        _makeBook(progress: 0.7),
        _makeBook(progress: 0.9),
        _makeBook(progress: 1.0),
        _makeBook(progress: 0.5),
      ]);
      expect(coll.almostFinished.length, 2);
    });

    test('frequentlyRead filters readingSeconds > 3600', () {
      final coll = _TestCollection([
        _makeBook(seconds: 7200),
        _makeBook(seconds: 100),
      ]);
      expect(coll.frequentlyRead.length, 1);
    });

    test('recentlyAdded filters books from last 7 days', () {
      final coll = _TestCollection([
        _makeBook(createdAt: DateTime.now().subtract(const Duration(days: 1))),
        _makeBook(createdAt: DateTime.now().subtract(const Duration(days: 30))),
      ]);
      expect(coll.recentlyAdded.length, 1);
    });

    test('getSmartCollections returns 4 collections', () {
      final coll = _TestCollection([]);
      expect(coll.getSmartCollections().length, 4);
    });
  });
}
