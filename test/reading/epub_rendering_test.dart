import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_reader/core/utils/html_to_markdown.dart';

void main() {
  group('EPUB rendering markdown output', () {
    test('h1 produces heading markup', () {
      final md = htmlToMarkdown('<h1>Title</h1>');
      expect(md, contains('Title'));
      expect(md, isNot(contains('<h1>')));
    });

    test('h2 produces heading markup', () {
      final md = htmlToMarkdown('<h2>Section</h2>');
      expect(md, contains('Section'));
      expect(md, isNot(contains('<h2>')));
    });

    test('img tags produce markdown image syntax', () {
      final md = htmlToMarkdown('<p>Before</p><img src="pic.png"/><p>After</p>');
      expect(md, contains('pic.png'));
      expect(md, isNot(contains('<img')));
    });

    test('img with attributes is handled', () {
      final md = htmlToMarkdown('<img alt="photo" src="x.jpg" width="100">');
      expect(md, contains('x.jpg'));
      expect(md, isNot(contains('<img')));
    });
  });
}
