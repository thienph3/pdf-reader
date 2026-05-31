import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_reader/models/book.dart';
import 'package:pdf_reader/models/highlight.dart';
import 'package:pdf_reader/core/utils/annotation_export.dart';

void main() {
  group('Annotation export', () {
    final now = DateTime(2024, 1, 1);

    test('export includes all highlights with page numbers', () {
      final book = Book(
        id: '1', title: 'My Book', createdAt: now, updatedAt: now,
        highlights: [
          Highlight(id: 'h1', page: 2, startIndex: 0, endIndex: 10,
            text: 'First highlight', createdAt: now),
          Highlight(id: 'h2', page: 9, startIndex: 0, endIndex: 10,
            text: 'Second highlight', createdAt: now),
        ],
      );
      final md = exportAnnotationsAsMarkdown(book);
      expect(md, contains('Page 3')); // page is 0-indexed, display is 1-indexed
      expect(md, contains('Page 10'));
      expect(md, contains('First highlight'));
      expect(md, contains('Second highlight'));
    });

    test('export includes highlight notes', () {
      final book = Book(
        id: '1', title: 'My Book', createdAt: now, updatedAt: now,
        highlights: [
          Highlight(id: 'h1', page: 0, startIndex: 0, endIndex: 5,
            text: 'Text', note: 'Important!', createdAt: now),
        ],
      );
      final md = exportAnnotationsAsMarkdown(book);
      expect(md, contains('Important!'));
    });

    test('export includes bookmark notes', () {
      final book = Book(
        id: '1', title: 'My Book', createdAt: now, updatedAt: now,
        bookmarks: [
          Bookmark(page: 4, note: 'Start of chapter 2', createdAt: now),
        ],
      );
      final md = exportAnnotationsAsMarkdown(book);
      expect(md, contains('Page 5'));
      expect(md, contains('Start of chapter 2'));
    });

    test('export format is valid Markdown with title', () {
      final book = Book(
        id: '1', title: 'Test Book', createdAt: now, updatedAt: now,
        highlights: [
          Highlight(id: 'h1', page: 0, startIndex: 0, endIndex: 5,
            text: 'Hello', createdAt: now),
        ],
      );
      final md = exportAnnotationsAsMarkdown(book);
      expect(md, startsWith('# Test Book'));
      expect(md, contains('## Highlights'));
    });

    test('book with no annotations exports only title', () {
      final book = Book(
        id: '1', title: 'Empty Book', createdAt: now, updatedAt: now,
      );
      final md = exportAnnotationsAsMarkdown(book);
      expect(md, contains('# Empty Book'));
      expect(md, isNot(contains('## Highlights')));
      expect(md, isNot(contains('## Bookmarks')));
    });

    test('highlights are sorted by page number in export', () {
      final book = Book(
        id: '1', title: 'Book', createdAt: now, updatedAt: now,
        highlights: [
          Highlight(id: 'h2', page: 10, startIndex: 0, endIndex: 5,
            text: 'Later', createdAt: now),
          Highlight(id: 'h1', page: 1, startIndex: 0, endIndex: 5,
            text: 'Earlier', createdAt: now),
        ],
      );
      final md = exportAnnotationsAsMarkdown(book);
      final earlierIdx = md.indexOf('Earlier');
      final laterIdx = md.indexOf('Later');
      expect(earlierIdx, lessThan(laterIdx));
    });
  });
}
