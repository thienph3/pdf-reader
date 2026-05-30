import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_reader/models/book.dart';
import 'package:pdf_reader/models/highlight.dart';

void main() {
  group('Book.fromMap/toMap roundtrip', () {
    test('basic book roundtrip', () {
      final now = DateTime(2024, 1, 15, 10, 30);
      final book = Book(
        id: 'test-id',
        title: 'Test Book',
        author: 'Author',
        format: BookFormat.ebook,
        filePath: '/path/to/file.pdf',
        createdAt: now,
        updatedAt: now,
      );
      final map = book.toMap();
      final restored = Book.fromMap(map);
      expect(restored.id, 'test-id');
      expect(restored.title, 'Test Book');
      expect(restored.author, 'Author');
      expect(restored.format, BookFormat.ebook);
      expect(restored.filePath, '/path/to/file.pdf');
    });

    test('book with highlights roundtrip', () {
      final now = DateTime(2024, 1, 15);
      final book = Book(
        id: 'h-book',
        title: 'Highlighted',
        highlights: [
          Highlight(id: 'h1', page: 0, startIndex: 0, endIndex: 10, text: 'hello', createdAt: now),
        ],
        createdAt: now,
        updatedAt: now,
      );
      final restored = Book.fromMap(book.toMap());
      expect(restored.highlights.length, 1);
      expect(restored.highlights.first.text, 'hello');
    });

    test('book with bookmarks roundtrip', () {
      final now = DateTime(2024, 1, 15);
      final book = Book(
        id: 'bm-book',
        title: 'Bookmarked',
        bookmarks: [Bookmark(page: 5, note: 'important', createdAt: now)],
        createdAt: now,
        updatedAt: now,
      );
      final restored = Book.fromMap(book.toMap());
      expect(restored.bookmarks.length, 1);
      expect(restored.bookmarks.first.page, 5);
      expect(restored.bookmarks.first.note, 'important');
    });
  });

  group('Book.progressPercent', () {
    test('returns 0 when totalPages is 0', () {
      final book = Book(id: '1', title: 't', createdAt: DateTime.now(), updatedAt: DateTime.now());
      expect(book.progressPercent, 0.0);
    });

    test('calculates correct progress', () {
      final book = Book(
        id: '1', title: 't', lastPage: 4, totalPages: 10,
        createdAt: DateTime.now(), updatedAt: DateTime.now(),
      );
      expect(book.progressPercent, 0.5);
    });

    test('clamps to 1.0 when lastPage exceeds totalPages', () {
      final book = Book(
        id: '1', title: 't', lastPage: 20, totalPages: 10,
        createdAt: DateTime.now(), updatedAt: DateTime.now(),
      );
      expect(book.progressPercent, 1.0);
    });
  });

  group('Book invalid data handling', () {
    test('handles missing optional fields', () {
      final book = Book.fromMap({'id': 'x', 'title': 'T', 'createdAt': '2024-01-01T00:00:00.000', 'updatedAt': '2024-01-01T00:00:00.000'});
      expect(book.author, '');
      expect(book.filePath, isNull);
      expect(book.lastPage, 0);
      expect(book.bookmarks, isEmpty);
      expect(book.highlights, isEmpty);
    });

    test('handles invalid format index gracefully', () {
      final book = Book.fromMap({
        'id': 'x', 'title': 'T', 'format': 99,
        'createdAt': '2024-01-01T00:00:00.000', 'updatedAt': '2024-01-01T00:00:00.000',
      });
      expect(book.format, BookFormat.paper);
    });

    test('handles null title as empty string', () {
      final book = Book.fromMap({
        'id': 'x', 'createdAt': '2024-01-01T00:00:00.000', 'updatedAt': '2024-01-01T00:00:00.000',
      });
      expect(book.title, '');
    });

    test('handles corrupt bookmark entries', () {
      final book = Book.fromMap({
        'id': 'x', 'title': 'T',
        'bookmarks': [{'invalid': true}, {'page': 1, 'createdAt': '2024-01-01T00:00:00.000'}],
        'createdAt': '2024-01-01T00:00:00.000', 'updatedAt': '2024-01-01T00:00:00.000',
      });
      expect(book.bookmarks.length, 1);
    });
  });

  group('Book properties', () {
    test('canRead requires ebook format and filePath', () {
      final book = Book(id: '1', title: 't', format: BookFormat.ebook, filePath: '/f.pdf', createdAt: DateTime.now(), updatedAt: DateTime.now());
      expect(book.canRead, true);
    });

    test('canRead false for paper format', () {
      final book = Book(id: '1', title: 't', format: BookFormat.paper, filePath: '/f.pdf', createdAt: DateTime.now(), updatedAt: DateTime.now());
      expect(book.canRead, false);
    });

    test('readingTimeFormatted shows hours and minutes', () {
      final book = Book(id: '1', title: 't', readingSeconds: 3661, createdAt: DateTime.now(), updatedAt: DateTime.now());
      expect(book.readingTimeFormatted, '1h 1m');
    });

    test('readingTimeFormatted shows minutes only', () {
      final book = Book(id: '1', title: 't', readingSeconds: 120, createdAt: DateTime.now(), updatedAt: DateTime.now());
      expect(book.readingTimeFormatted, '2m');
    });
  });
}
