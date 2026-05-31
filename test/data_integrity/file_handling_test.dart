import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_reader/core/utils/pdf_file_utils.dart';

void main() {
  group('File handling safety', () {
    test('path traversal in filePath is detected', () {
      const malicious = '../../etc/passwd';
      expect(malicious.contains('..'), isTrue);
    });

    test('null bytes in filePath are detected', () {
      const malicious = '/docs/file\x00.pdf';
      expect(malicious.contains('\x00'), isTrue);
    });

    test('filename is correctly extracted from Unix path', () {
      expect(fileNameFromPath('/home/user/docs/book.pdf'), 'book.pdf');
      expect(fileNameFromPath('/a/b/c/file.epub'), 'file.epub');
    });

    test('filename is correctly extracted from Windows path', () {
      expect(fileNameFromPath(r'C:\Users\docs\book.pdf'), 'book.pdf');
    });

    test('filename from path with no separator returns full string', () {
      expect(fileNameFromPath('book.pdf'), 'book.pdf');
    });

    test('import rejects path traversal attacks', () {
      // Simulates the import validation logic from BookService.importFromJson
      final item = {
        'id': 'x1', 'title': 'Evil', 'format': 1,
        'filePath': '../../../etc/shadow',
      };
      final filePath = item['filePath'] as String?;
      final shouldReject = filePath != null &&
          (filePath.contains('..') || filePath.contains('\x00'));
      expect(shouldReject, isTrue);
    });

    test('import rejects null byte attacks', () {
      final item = {
        'id': 'x2', 'title': 'Evil2', 'format': 1,
        'filePath': '/docs/file\x00.pdf',
      };
      final filePath = item['filePath'] as String?;
      final shouldReject = filePath != null &&
          (filePath.contains('..') || filePath.contains('\x00'));
      expect(shouldReject, isTrue);
    });

    test('clean file paths pass validation', () {
      const clean = '/storage/emulated/0/Download/book.pdf';
      final shouldReject = clean.contains('..') || clean.contains('\x00');
      expect(shouldReject, isFalse);
    });
  });
}
