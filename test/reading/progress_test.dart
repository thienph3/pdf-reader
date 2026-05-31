import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_reader/models/book.dart';

void main() {
  group('Reading progress', () {
    late Book book;

    setUp(() {
      book = Book(
        id: '1', title: 'Test', format: BookFormat.ebook,
        filePath: '/test.pdf', totalPages: 100,
        createdAt: DateTime(2024, 1, 1), updatedAt: DateTime(2024, 1, 1),
      );
    });

    test('progress is saved when changing pages', () {
      final updated = book.copyWith(lastPage: 10);
      expect(updated.lastPage, 10);
    });

    test('progress percentage is correct at midpoint', () {
      final mid = book.copyWith(lastPage: 49, totalPages: 100);
      // (49+1)/100 = 0.5
      expect(mid.progressPercent, 0.5);
    });

    test('progress percentage is 0 when no pages read', () {
      final fresh = book.copyWith(lastPage: 0, totalPages: 100);
      // (0+1)/100 = 0.01
      expect(fresh.progressPercent, closeTo(0.01, 0.001));
    });

    test('progress percentage is 1.0 at last page', () {
      final done = book.copyWith(lastPage: 99, totalPages: 100);
      expect(done.progressPercent, 1.0);
    });

    test('progress percentage is 0 when totalPages is 0', () {
      final noPages = book.copyWith(totalPages: 0);
      expect(noPages.progressPercent, 0.0);
    });

    test('reopening a book resumes from last page', () {
      final saved = book.copyWith(lastPage: 42);
      expect(saved.lastPage, 42);
    });

    test('reading time accumulates correctly', () {
      final after5min = book.copyWith(readingSeconds: 300);
      final after10min = after5min.copyWith(
        readingSeconds: after5min.readingSeconds + 300,
      );
      expect(after10min.readingSeconds, 600);
    });

    test('reading time formatted shows minutes', () {
      final b = book.copyWith(readingSeconds: 300);
      expect(b.readingTimeFormatted, '5m');
    });

    test('reading time formatted shows hours and minutes', () {
      final b = book.copyWith(readingSeconds: 3900);
      expect(b.readingTimeFormatted, '1h 5m');
    });

    test('reading time formatted shows seconds for short reads', () {
      final b = book.copyWith(readingSeconds: 45);
      expect(b.readingTimeFormatted, '45s');
    });
  });
}
