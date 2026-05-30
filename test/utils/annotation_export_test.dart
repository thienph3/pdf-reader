import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_reader/core/utils/annotation_export.dart';
import 'package:pdf_reader/models/book.dart';
import 'package:pdf_reader/models/highlight.dart';

void main() {
  final now = DateTime(2024, 1, 1);

  group('exportAnnotationsAsMarkdown', () {
    test('includes title as h1', () {
      final book = Book(id: '1', title: 'My Book', createdAt: now, updatedAt: now);
      final md = exportAnnotationsAsMarkdown(book);
      expect(md, startsWith('# My Book\n'));
    });

    test('formats highlights with page and text', () {
      final book = Book(
        id: '1',
        title: 'T',
        highlights: [
          Highlight(id: 'h1', page: 2, startIndex: 0, endIndex: 5, text: 'hello', createdAt: now),
        ],
        createdAt: now,
        updatedAt: now,
      );
      final md = exportAnnotationsAsMarkdown(book);
      expect(md, contains('## Highlights'));
      expect(md, contains('Page 3: "hello"'));
    });

    test('includes highlight note', () {
      final book = Book(
        id: '1',
        title: 'T',
        highlights: [
          Highlight(id: 'h1', page: 0, startIndex: 0, endIndex: 3, text: 'hi', note: 'important', createdAt: now),
        ],
        createdAt: now,
        updatedAt: now,
      );
      final md = exportAnnotationsAsMarkdown(book);
      expect(md, contains('— important'));
    });

    test('formats bookmarks with page', () {
      final book = Book(
        id: '1',
        title: 'T',
        bookmarks: [Bookmark(page: 4, note: 'chapter 2', createdAt: now)],
        createdAt: now,
        updatedAt: now,
      );
      final md = exportAnnotationsAsMarkdown(book);
      expect(md, contains('## Bookmarks'));
      expect(md, contains('Page 5: chapter 2'));
    });

    test('empty book has no sections', () {
      final book = Book(id: '1', title: 'Empty', createdAt: now, updatedAt: now);
      final md = exportAnnotationsAsMarkdown(book);
      expect(md, '# Empty\n');
    });
  });
}
