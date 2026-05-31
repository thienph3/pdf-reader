import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_reader/core/utils/html_to_markdown.dart';

void main() {
  group('htmlToMarkdown', () {
    test('converts h1-h6 to markdown headings', () {
      expect(htmlToMarkdown('<h1>Title</h1>'), '# Title');
      expect(htmlToMarkdown('<h2>Sub</h2>'), '## Sub');
      expect(htmlToMarkdown('<h3>H3</h3>'), '### H3');
      expect(htmlToMarkdown('<h4>H4</h4>'), '#### H4');
      expect(htmlToMarkdown('<h5>H5</h5>'), '##### H5');
      expect(htmlToMarkdown('<h6>H6</h6>'), '###### H6');
    });

    test('converts p tags to paragraphs', () {
      final result = htmlToMarkdown('<p>First</p><p>Second</p>');
      expect(result, contains('First'));
      expect(result, contains('Second'));
    });

    test('converts em/i to italic', () {
      expect(htmlToMarkdown('<em>italic</em>'), '*italic*');
      expect(htmlToMarkdown('<i>italic</i>'), '*italic*');
    });

    test('converts strong/b to bold', () {
      expect(htmlToMarkdown('<strong>bold</strong>'), '**bold**');
      expect(htmlToMarkdown('<b>bold</b>'), '**bold**');
    });

    test('converts li to list items', () {
      final result = htmlToMarkdown('<li>Item one</li><li>Item two</li>');
      expect(result, contains('- Item one'));
      expect(result, contains('- Item two'));
    });

    test('strips unknown tags', () {
      expect(htmlToMarkdown('<div>content</div>'), 'content');
      expect(htmlToMarkdown('<span>text</span>'), 'text');
    });

    test('handles empty input', () {
      expect(htmlToMarkdown(''), '');
    });

    test('handles nested tags', () {
      final result = htmlToMarkdown('<p><strong>bold <em>and italic</em></strong></p>');
      expect(result, contains('**bold *and italic***'));
    });

    test('converts br to newline', () {
      expect(htmlToMarkdown('line1<br/>line2'), 'line1\nline2');
    });
  });
}
