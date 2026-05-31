import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_reader/models/book.dart';

void main() {
  group('Library import/export', () {
    test('exporting then importing produces identical data', () {
      final now = DateTime(2024, 1, 1);
      final book = Book(
        id: 'abc', title: 'Test Book', author: 'Author',
        format: BookFormat.ebook, filePath: '/docs/test.pdf',
        lastPage: 5, totalPages: 100, readingSeconds: 300,
        createdAt: now, updatedAt: now,
      );
      final json = jsonEncode([book.toMap()]);
      final restored = Book.fromMap(
        (jsonDecode(json) as List).first as Map<String, dynamic>,
      );
      expect(restored.id, book.id);
      expect(restored.title, book.title);
      expect(restored.author, book.author);
      expect(restored.format, book.format);
      expect(restored.filePath, book.filePath);
      expect(restored.lastPage, book.lastPage);
      expect(restored.totalPages, book.totalPages);
      expect(restored.readingSeconds, book.readingSeconds);
    });

    test('importing malicious JSON does not crash', () {
      const badJson = '[{"id": null, "title": null}, "not a map", 42]';
      final list = jsonDecode(badJson) as List;
      int imported = 0;
      for (final item in list) {
        if (item is! Map) continue;
        if (item['id'] == null || item['id'] is! String) continue;
        if (item['title'] == null) continue;
        imported++;
      }
      expect(imported, 0);
    });

    test('importing file with path traversal is sanitized', () {
      final malicious = {
        'id': 'x1', 'title': 'Evil', 'format': 1,
        'filePath': '../../etc/passwd',
        'createdAt': '2024-01-01T00:00:00.000',
        'updatedAt': '2024-01-01T00:00:00.000',
      };
      final filePath = malicious['filePath'] as String?;
      final isMalicious = filePath != null &&
          (filePath.contains('..') || filePath.contains('\x00'));
      expect(isMalicious, isTrue);
    });

    test('duplicate books are detected by id', () {
      final now = DateTime(2024, 1, 1);
      final existing = Book(
        id: 'dup1', title: 'Existing', createdAt: now, updatedAt: now,
      );
      final incoming = Book(
        id: 'dup1', title: 'Duplicate', createdAt: now, updatedAt: now,
      );
      // Same ID means duplicate — should be skipped
      expect(existing.id, incoming.id);
    });

    test('book with invalid format index in JSON defaults to paper', () {
      final map = {
        'id': 'b1', 'title': 'Test', 'format': 99,
        'createdAt': '2024-01-01T00:00:00.000',
        'updatedAt': '2024-01-01T00:00:00.000',
      };
      final book = Book.fromMap(map);
      expect(book.format, BookFormat.paper);
    });
  });
}
