import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_reader/models/book.dart';
import 'package:pdf_reader/models/highlight.dart';

/// Tests the cross-book search matching logic.
/// Extracted from CrossBookSearchScreen._search behavior.
List<Map<String, dynamic>> searchBooks(List<Book> books, String query) {
  if (query.trim().isEmpty) return [];
  final q = query.toLowerCase();
  final results = <Map<String, dynamic>>[];
  for (final book in books) {
    if (book.title.toLowerCase().contains(q)) {
      results.add({'book': book.title, 'page': book.lastPage, 'type': 'title'});
    }
    for (final h in book.highlights) {
      if (h.text.toLowerCase().contains(q) || h.note.toLowerCase().contains(q)) {
        results.add({'book': book.title, 'page': h.page, 'type': 'highlight'});
      }
    }
    for (final b in book.bookmarks) {
      if (b.note.toLowerCase().contains(q)) {
        results.add({'book': book.title, 'page': b.page, 'type': 'bookmark'});
      }
    }
  }
  return results;
}

void main() {
  final now = DateTime(2024, 1, 1);
  final books = [
    Book(id: '1', title: 'Flutter Development', createdAt: now, updatedAt: now,
      highlights: [Highlight(id: 'h1', page: 5, startIndex: 0, endIndex: 10, text: 'state management', createdAt: now)],
      bookmarks: [Bookmark(page: 10, note: 'important chapter', createdAt: now)],
    ),
    Book(id: '2', title: 'Vietnamese Cooking', createdAt: now, updatedAt: now,
      highlights: [Highlight(id: 'h2', page: 3, startIndex: 0, endIndex: 5, text: 'phở recipe', note: 'try this weekend', createdAt: now)],
    ),
    Book(id: '3', title: 'Empty Book', createdAt: now, updatedAt: now),
  ];

  group('Cross-book search finds relevant results', () {
    test('finds book by title', () {
      final results = searchBooks(books, 'flutter');
      expect(results.length, 1);
      expect(results[0]['book'], 'Flutter Development');
      expect(results[0]['type'], 'title');
    });

    test('finds highlight by text', () {
      final results = searchBooks(books, 'state management');
      expect(results.length, 1);
      expect(results[0]['page'], 5);
      expect(results[0]['type'], 'highlight');
    });

    test('finds highlight by note', () {
      final results = searchBooks(books, 'weekend');
      expect(results.length, 1);
      expect(results[0]['book'], 'Vietnamese Cooking');
    });

    test('finds bookmark by note', () {
      final results = searchBooks(books, 'important');
      expect(results.length, 1);
      expect(results[0]['type'], 'bookmark');
      expect(results[0]['page'], 10);
    });

    test('search is case-insensitive', () {
      final results = searchBooks(books, 'FLUTTER');
      expect(results.length, 1);
    });

    test('empty query returns no results', () {
      expect(searchBooks(books, ''), isEmpty);
      expect(searchBooks(books, '   '), isEmpty);
    });

    test('no match returns empty', () {
      expect(searchBooks(books, 'nonexistent xyz'), isEmpty);
    });

    test('finds results across multiple books', () {
      final results = searchBooks(books, 'e');
      expect(results.length, greaterThan(1));
    });
  });
}
