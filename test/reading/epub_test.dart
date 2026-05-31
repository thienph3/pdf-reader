import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_reader/core/utils/html_to_markdown.dart';

void main() {
  group('EPUB reading', () {
    test('HTML content is converted to readable Markdown', () {
      const html = '<p>Hello world</p>';
      final md = htmlToMarkdown(html);
      expect(md, contains('Hello world'));
      expect(md, isNot(contains('<p>')));
    });

    test('headings are preserved in conversion', () {
      const html = '<h1>Chapter 1</h1><h2>Section A</h2>';
      final md = htmlToMarkdown(html);
      expect(md, contains('Chapter 1'));
      expect(md, contains('Section A'));
    });

    test('bold and italic are preserved', () {
      const html = '<strong>bold</strong> and <em>italic</em>';
      final md = htmlToMarkdown(html);
      expect(md, contains('**bold**'));
      expect(md, contains('italic'));
    });

    test('b and i tags also work', () {
      const html = '<b>bold</b> and <i>italic</i>';
      final md = htmlToMarkdown(html);
      expect(md, contains('**bold**'));
      expect(md, contains('italic'));
    });

    test('list items are converted to markdown lists', () {
      const html = '<ul><li>Item 1</li><li>Item 2</li></ul>';
      final md = htmlToMarkdown(html);
      expect(md, contains('Item 1'));
      expect(md, contains('Item 2'));
    });

    test('line breaks are converted', () {
      const html = 'Line 1<br/>Line 2';
      final md = htmlToMarkdown(html);
      expect(md, contains('Line 1'));
      expect(md, contains('Line 2'));
    });

    test('empty HTML produces empty output', () {
      expect(htmlToMarkdown(''), '');
    });

    test('remaining HTML tags are stripped', () {
      const html = '<div class="chapter"><span>Text</span></div>';
      final md = htmlToMarkdown(html);
      expect(md, isNot(contains('<')));
      expect(md, contains('Text'));
    });
  });
}
