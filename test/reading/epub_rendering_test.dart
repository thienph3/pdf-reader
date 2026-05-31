import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_reader/core/utils/html_to_markdown.dart';

void main() {
  group('EPUB rendering markdown output', () {
    test('h1 produces # heading', () {
      final md = htmlToMarkdown('<h1>Title</h1>');
      expect(md, contains('# Title'));
    });

    test('h2 produces ## heading', () {
      final md = htmlToMarkdown('<h2>Section</h2>');
      expect(md, contains('## Section'));
    });

    test('img tags produce [Image] placeholder', () {
      final md = htmlToMarkdown('<p>Before</p><img src="pic.png"/><p>After</p>');
      expect(md, contains('[Image]'));
    });

    test('img with attributes is handled', () {
      final md = htmlToMarkdown('<img alt="photo" src="x.jpg" width="100">');
      expect(md, contains('[Image]'));
      expect(md, isNot(contains('<img')));
    });
  });
}
