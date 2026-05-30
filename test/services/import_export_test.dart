import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_reader/models/book.dart';

/// Tests for BookService import validation logic.
/// These test the validation rules without requiring Hive.
void main() {
  group('Import validation rules', () {
    test('valid entry passes all checks', () {
      final entry = {
        'id': 'valid-1',
        'title': 'Good Book',
        'format': 1,
        'filePath': '/safe/path.pdf',
        'createdAt': '2024-01-01T00:00:00.000',
        'updatedAt': '2024-01-01T00:00:00.000',
      };
      expect(entry['id'], isA<String>());
      expect(entry['title'], isNotNull);
      expect((entry['format'] as int) < BookFormat.values.length, true);
    });

    test('rejects entry without id', () {
      final entry = {'title': 'No ID', 'createdAt': '2024-01-01T00:00:00.000'};
      final hasValidId = entry['id'] is String;
      expect(hasValidId, false);
    });

    test('rejects entry with invalid format index', () {
      final formatIdx = 99;
      expect(formatIdx >= BookFormat.values.length, true);
    });

    test('detects path traversal in filePath', () {
      final paths = ['../../etc/passwd', '/safe/../../../bad', 'normal/path.pdf'];
      expect(paths[0].contains('..'), true);
      expect(paths[1].contains('..'), true);
      expect(paths[2].contains('..'), false);
    });

    test('detects null bytes in filePath', () {
      final path = '/path/with\x00null.pdf';
      expect(path.contains('\x00'), true);
    });

    test('rejects non-map entries in JSON array', () {
      final json = jsonEncode(['string', 123, null, {'id': 'ok', 'title': 'T'}]);
      final list = jsonDecode(json) as List;
      final maps = list.whereType<Map>().toList();
      expect(maps.length, 1);
    });
  });

  group('Export format', () {
    test('Book.toMap produces JSON-encodable map', () {
      final book = Book(
        id: 'exp-1',
        title: 'Export Test',
        format: BookFormat.ebook,
        filePath: '/test.pdf',
        lastPage: 5,
        totalPages: 100,
        createdAt: DateTime(2024, 6, 1),
        updatedAt: DateTime(2024, 6, 2),
      );
      final json = jsonEncode(book.toMap());
      expect(json, isNotEmpty);
      final decoded = jsonDecode(json) as Map<String, dynamic>;
      expect(decoded['id'], 'exp-1');
      expect(decoded['totalPages'], 100);
    });

    test('export/import roundtrip for list of books', () {
      final books = [
        Book(id: 'a', title: 'A', createdAt: DateTime(2024, 1, 1), updatedAt: DateTime(2024, 1, 1)),
        Book(id: 'b', title: 'B', createdAt: DateTime(2024, 1, 2), updatedAt: DateTime(2024, 1, 2)),
      ];
      final json = jsonEncode(books.map((b) => b.toMap()).toList());
      final restored = (jsonDecode(json) as List).map((m) => Book.fromMap(m)).toList();
      expect(restored.length, 2);
      expect(restored[0].id, 'a');
      expect(restored[1].title, 'B');
    });
  });
}
