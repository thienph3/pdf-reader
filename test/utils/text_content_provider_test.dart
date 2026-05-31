import 'package:flutter_test/flutter_test.dart';

/// Replicates TextContentProvider._splitIntoPages for unit testing.
/// The logic is identical to the private method in text_content_provider.dart.
List<String> splitIntoPages(String text, {int charsPerPage = 2000}) {
  if (text.length <= charsPerPage) return [text];
  final pages = <String>[];
  var start = 0;
  while (start < text.length) {
    var end = start + charsPerPage;
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
  group('splitIntoPages', () {
    test('short text returns 1 page', () {
      final pages = splitIntoPages('Hello world');
      expect(pages.length, 1);
      expect(pages[0], 'Hello world');
    });

    test('empty text returns 1 empty page', () {
      final pages = splitIntoPages('');
      expect(pages.length, 1);
      expect(pages[0], '');
    });

    test('long text splits at paragraph boundaries', () {
      // Create text with paragraph break near the split point
      final para1 = 'A' * 1800;
      final para2 = 'B' * 500;
      final text = '$para1\n\n$para2';
      final pages = splitIntoPages(text);
      expect(pages.length, 2);
      expect(pages[0], '$para1\n\n');
      expect(pages[1], para2);
    });

    test('very long text without paragraphs splits at char limit', () {
      final text = 'X' * 5000;
      final pages = splitIntoPages(text);
      expect(pages.length, 3);
      expect(pages[0].length, 2000);
      expect(pages[1].length, 2000);
      expect(pages[2].length, 1000);
    });

    test('text exactly at limit returns 1 page', () {
      final text = 'Y' * 2000;
      final pages = splitIntoPages(text);
      expect(pages.length, 1);
    });

    test('prefers paragraph break over hard split', () {
      // Paragraph break at position 1500, well before the 2000 limit
      final before = 'A' * 1500;
      final after = 'B' * 1000;
      final text = '$before\n\n$after';
      final pages = splitIntoPages(text);
      expect(pages.length, 2);
      expect(pages[0].endsWith('\n\n'), true);
    });
  });
}
