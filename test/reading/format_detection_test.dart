import 'package:flutter_test/flutter_test.dart';

/// Format detection logic extracted from ReaderScreen.initState
String _detectReaderType(String filePath) {
  final ext = filePath.toLowerCase().split('.').last;
  switch (ext) {
    case 'pdf':
      return 'pdf';
    case 'epub':
      return 'epub';
    case 'txt':
    case 'md':
      return 'text';
    case 'cbz':
    case 'cbr':
      return 'comic';
    default:
      return 'unknown';
  }
}

void main() {
  group('Opening a file in the correct reader', () {
    test('PDF files open in PDF viewer', () {
      expect(_detectReaderType('/books/novel.pdf'), 'pdf');
      expect(_detectReaderType('/books/REPORT.PDF'), 'pdf');
    });

    test('EPUB files open in EPUB viewer', () {
      expect(_detectReaderType('/books/novel.epub'), 'epub');
      expect(_detectReaderType('/books/Novel.EPUB'), 'epub');
    });

    test('TXT files open in text viewer', () {
      expect(_detectReaderType('/books/notes.txt'), 'text');
    });

    test('MD files open in text viewer', () {
      expect(_detectReaderType('/books/readme.md'), 'text');
      expect(_detectReaderType('/books/README.MD'), 'text');
    });

    test('CBZ files open in comic viewer', () {
      expect(_detectReaderType('/comics/issue1.cbz'), 'comic');
    });

    test('CBR files open in comic viewer', () {
      expect(_detectReaderType('/comics/issue2.cbr'), 'comic');
    });

    test('unknown extension returns unknown', () {
      expect(_detectReaderType('/files/data.xlsx'), 'unknown');
      expect(_detectReaderType('/files/image.png'), 'unknown');
    });
  });
}
