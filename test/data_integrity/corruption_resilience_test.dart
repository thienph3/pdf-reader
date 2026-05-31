import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_reader/models/book.dart';
import 'package:pdf_reader/models/reading_log.dart';
import 'package:pdf_reader/models/reading_goal.dart';

void main() {
  group('App handles corrupt data gracefully', () {
    test('book with invalid format index loads as paper', () {
      final map = {
        'id': 'b1', 'title': 'Test', 'format': 99,
        'createdAt': '2024-01-01T00:00:00.000',
        'updatedAt': '2024-01-01T00:00:00.000',
      };
      final book = Book.fromMap(map);
      expect(book.format, BookFormat.paper);
    });

    test('book with corrupt bookmarks skips bad entries', () {
      final map = {
        'id': 'b1', 'title': 'Test', 'format': 0,
        'bookmarks': [
          {'page': 1, 'note': 'Good', 'createdAt': '2024-01-01T00:00:00.000'},
          {'page': 'invalid', 'note': 'Bad'},  // corrupt
          null,  // null entry
          42,    // wrong type
        ],
        'createdAt': '2024-01-01T00:00:00.000',
        'updatedAt': '2024-01-01T00:00:00.000',
      };
      final book = Book.fromMap(map);
      expect(book.bookmarks.length, 1);
      expect(book.bookmarks.first.page, 1);
    });

    test('book with invalid dates uses current time', () {
      final before = DateTime.now();
      final map = {
        'id': 'b1', 'title': 'Test',
        'createdAt': 'not-a-date',
        'updatedAt': 'also-invalid',
      };
      final book = Book.fromMap(map);
      expect(book.createdAt.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
      expect(book.updatedAt.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
    });

    test('missing required fields use safe defaults', () {
      final map = <String, dynamic>{
        'id': 'b1', 'title': 'Minimal',
        'createdAt': '2024-01-01T00:00:00.000',
        'updatedAt': '2024-01-01T00:00:00.000',
      };
      final book = Book.fromMap(map);
      expect(book.author, '');
      expect(book.notes, '');
      expect(book.lastPage, 0);
      expect(book.totalPages, 0);
      expect(book.readingSeconds, 0);
      expect(book.bookmarks, isEmpty);
      expect(book.highlights, isEmpty);
      expect(book.filePath, isNull);
      expect(book.categoryId, isNull);
    });

    test('reading log with missing fields uses zero defaults', () {
      final log = ReadingLog.fromMap({'date': '2024-01-01'});
      expect(log.seconds, 0);
      expect(log.pagesRead, 0);
    });

    test('reading goal with missing fields uses sensible defaults', () {
      final goal = ReadingGoal.fromMap({});
      expect(goal.dailyMinutes, 30);
      expect(goal.monthlyBooks, 2);
    });

    test('book with null title defaults to empty string', () {
      final map = {
        'id': 'b1',
        'createdAt': '2024-01-01T00:00:00.000',
        'updatedAt': '2024-01-01T00:00:00.000',
      };
      final book = Book.fromMap(map);
      expect(book.title, '');
    });

    test('book with corrupt highlights skips bad entries', () {
      final map = {
        'id': 'b1', 'title': 'Test',
        'highlights': [
          {
            'id': 'h1', 'page': 1, 'startIndex': 0, 'endIndex': 5,
            'text': 'Good', 'createdAt': '2024-01-01T00:00:00.000',
          },
          {'id': null, 'page': 'bad'},  // corrupt
        ],
        'createdAt': '2024-01-01T00:00:00.000',
        'updatedAt': '2024-01-01T00:00:00.000',
      };
      final book = Book.fromMap(map);
      expect(book.highlights.length, 1);
      expect(book.highlights.first.text, 'Good');
    });
  });
}
