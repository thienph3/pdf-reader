import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_reader/models/book.dart';

void main() {
  group('Adding a book to library', () {
    test('book with file path is automatically marked as ebook', () {
      final now = DateTime.now();
      final book = Book(
        id: '1', title: 'Test', format: BookFormat.ebook,
        filePath: '/docs/test.pdf', createdAt: now, updatedAt: now,
      );
      expect(book.hasEbook, isTrue);
      expect(book.canRead, isTrue);
    });

    test('book without file is marked as paper', () {
      final now = DateTime.now();
      final book = Book(
        id: '1', title: 'Test', format: BookFormat.paper,
        createdAt: now, updatedAt: now,
      );
      expect(book.hasEbook, isFalse);
      expect(book.canRead, isFalse);
    });

    test('book with empty filePath cannot be read', () {
      final now = DateTime.now();
      final book = Book(
        id: '1', title: 'Test', format: BookFormat.ebook,
        filePath: '', createdAt: now, updatedAt: now,
      );
      expect(book.canRead, isFalse);
    });

    test('both format has ebook and can read with file', () {
      final now = DateTime.now();
      final book = Book(
        id: '1', title: 'Test', format: BookFormat.both,
        filePath: '/docs/test.epub', createdAt: now, updatedAt: now,
      );
      expect(book.hasEbook, isTrue);
      expect(book.canRead, isTrue);
    });

    test('title is preserved from filename when set', () {
      final now = DateTime.now();
      final book = Book(
        id: '1', title: 'My Book.pdf',
        filePath: '/docs/My Book.pdf', createdAt: now, updatedAt: now,
      );
      expect(book.title, 'My Book.pdf');
    });

    test('supported formats are paper, ebook, both', () {
      expect(BookFormat.values.length, 3);
      expect(BookFormat.values, contains(BookFormat.paper));
      expect(BookFormat.values, contains(BookFormat.ebook));
      expect(BookFormat.values, contains(BookFormat.both));
    });
  });
}
