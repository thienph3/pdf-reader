import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_reader/core/utils/pdf_file_utils.dart';

void main() {
  group('fileNameFromPath', () {
    test('extracts filename from unix path', () {
      expect(fileNameFromPath('/home/user/docs/book.pdf'), 'book.pdf');
    });

    test('extracts filename from windows path', () {
      expect(fileNameFromPath('C:\\Users\\docs\\book.pdf'), 'book.pdf');
    });

    test('handles filename only (no directory)', () {
      expect(fileNameFromPath('book.pdf'), 'book.pdf');
    });

    test('handles path with spaces', () {
      expect(fileNameFromPath('/path/to/my book.pdf'), 'my book.pdf');
    });
  });
}
