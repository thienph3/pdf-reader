import 'package:flutter_test/flutter_test.dart';

/// Extracted pagination logic from TextContentProvider
const _charsPerPage = 2000;

List<String> splitIntoPages(String text) {
  if (text.length <= _charsPerPage) return [text];
  final pages = <String>[];
  var start = 0;
  while (start < text.length) {
    var end = start + _charsPerPage;
    if (end >= text.length) {
      pages.add(text.substring(start));
      break;
    }
    final newline = text.lastIndexOf('\n\n', end);
    if (newline > start) end = newline + 2;
    pages.add(text.substring(start, end));
    start = end;
  }
  return pages;
}

void main() {
  group('Text files are paginated for comfortable reading', () {
    test('short text fits in one page', () {
      const text = 'Hello, this is a short text.';
      final pages = splitIntoPages(text);
      expect(pages.length, 1);
      expect(pages.first, text);
    });

    test('long text is split at paragraph boundaries', () {
      // Create text with paragraphs that total > 2000 chars
      final para1 = 'A' * 1500;
      final para2 = 'B' * 1500;
      final text = '$para1\n\n$para2';
      final pages = splitIntoPages(text);
      expect(pages.length, 2);
      // First page should end at paragraph boundary
      expect(pages[0].trimRight(), para1);
    });

    test('very long paragraphs are split at character limit', () {
      // Single paragraph with no breaks, > 2000 chars
      final text = 'X' * 5000;
      final pages = splitIntoPages(text);
      expect(pages.length, greaterThan(1));
      // All content is preserved
      expect(pages.join(), text);
    });

    test('empty text produces single empty page', () {
      final pages = splitIntoPages('');
      expect(pages.length, 1);
      expect(pages.first, '');
    });

    test('text exactly at page limit fits in one page', () {
      final text = 'Y' * _charsPerPage;
      final pages = splitIntoPages(text);
      expect(pages.length, 1);
    });
  });
}
