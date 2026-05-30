import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_reader/models/book.dart';
import 'package:pdf_reader/models/highlight.dart';

void main() {
  final now = DateTime(2024, 1, 15, 10, 30);

  group('Book serialization', () {
    test('toMap/fromMap roundtrip preserves all fields', () {
      final book = Book(
        id: 'test-id',
        title: 'Test Book',
        author: 'Author',
        format: BookFormat.both,
        filePath: '/path/to/file.pdf',
        categoryId: 'cat-1',
        notes: 'Some notes',
        lastPage: 42,
        totalPages: 200,
        readingSeconds: 7200,
        lastOpenedAt: now,
        createdAt: now,
        updatedAt: now,
      );
      final restored = Book.fromMap(book.toMap());

      expect(restored.id, book.id);
      expect(restored.title, book.title);
      expect(restored.author, book.author);
      expect(restored.format, book.format);
      expect(restored.filePath, book.filePath);
      expect(restored.categoryId, book.categoryId);
      expect(restored.notes, book.notes);
      expect(restored.lastPage, book.lastPage);
      expect(restored.totalPages, book.totalPages);
      expect(restored.readingSeconds, book.readingSeconds);
      expect(restored.lastOpenedAt, book.lastOpenedAt);
    });

    test('roundtrip with highlights', () {
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
      expect(restored.highlights.first.id, 'h1');
    });

    test('roundtrip with bookmarks', () {
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

  group('Book.fromMap resilience', () {
    test('handles missing optional fields', () {
      final book = Book.fromMap({
        'id': 'x',
        'createdAt': '2024-01-01T00:00:00.000',
        'updatedAt': '2024-01-01T00:00:00.000',
      });
      expect(book.title, '');
      expect(book.author, '');
      expect(book.filePath, isNull);
      expect(book.lastPage, 0);
      expect(book.bookmarks, isEmpty);
      expect(book.highlights, isEmpty);
    });

    test('invalid format index defaults to paper', () {
      final book = Book.fromMap({
        'id': 'x',
        'title': 'T',
        'format': 99,
        'createdAt': '2024-01-01T00:00:00.000',
        'updatedAt': '2024-01-01T00:00:00.000',
      });
      expect(book.format, BookFormat.paper);
    });

    test('corrupt bookmarks are skipped', () {
      final book = Book.fromMap({
        'id': 'x',
        'title': 'T',
        'bookmarks': [
          {'invalid': true},
          {'page': 1, 'createdAt': '2024-01-01T00:00:00.000'},
        ],
        'createdAt': '2024-01-01T00:00:00.000',
        'updatedAt': '2024-01-01T00:00:00.000',
      });
      expect(book.bookmarks.length, 1);
    });

    test('invalid dates default to now', () {
      final book = Book.fromMap({
        'id': 'x',
        'title': 'T',
        'createdAt': 'not-a-date',
        'updatedAt': null,
      });
      expect(book.createdAt.year, DateTime.now().year);
    });
  });

  group('Book computed properties', () {
    test('progressPercent 0 when totalPages is 0', () {
      final book = Book(id: '1', title: 't', createdAt: now, updatedAt: now);
      expect(book.progressPercent, 0.0);
    });

    test('progressPercent correct at midpoint', () {
      final book = Book(id: '1', title: 't', lastPage: 4, totalPages: 10, createdAt: now, updatedAt: now);
      expect(book.progressPercent, 0.5);
    });

    test('progressPercent clamped to 1.0', () {
      final book = Book(id: '1', title: 't', lastPage: 20, totalPages: 10, createdAt: now, updatedAt: now);
      expect(book.progressPercent, 1.0);
    });

    test('canRead requires ebook format + filePath', () {
      expect(
        Book(id: '1', title: 't', format: BookFormat.ebook, filePath: '/f.pdf', createdAt: now, updatedAt: now).canRead,
        true,
      );
      expect(
        Book(id: '1', title: 't', format: BookFormat.paper, filePath: '/f.pdf', createdAt: now, updatedAt: now).canRead,
        false,
      );
      expect(
        Book(id: '1', title: 't', format: BookFormat.ebook, createdAt: now, updatedAt: now).canRead,
        false,
      );
    });

    test('readingTimeFormatted', () {
      expect(
        Book(id: '1', title: 't', readingSeconds: 3661, createdAt: now, updatedAt: now).readingTimeFormatted,
        '1h 1m',
      );
      expect(
        Book(id: '1', title: 't', readingSeconds: 120, createdAt: now, updatedAt: now).readingTimeFormatted,
        '2m',
      );
      expect(
        Book(id: '1', title: 't', readingSeconds: 45, createdAt: now, updatedAt: now).readingTimeFormatted,
        '45s',
      );
    });
  });
}
