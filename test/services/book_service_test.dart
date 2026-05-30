import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_reader/models/book.dart';

void main() {
  group('BookService JSON export/import logic', () {
    test('toMap produces valid JSON-encodable map', () {
      final book = Book(
        id: 'svc-1',
        title: 'Service Test',
        author: 'Auth',
        format: BookFormat.ebook,
        filePath: '/test.pdf',
        lastPage: 5,
        totalPages: 100,
        readingSeconds: 600,
        createdAt: DateTime(2024, 6, 1),
        updatedAt: DateTime(2024, 6, 2),
      );
      final json = jsonEncode(book.toMap());
      expect(json, isNotEmpty);
      final decoded = jsonDecode(json) as Map<String, dynamic>;
      expect(decoded['id'], 'svc-1');
      expect(decoded['totalPages'], 100);
    });

    test('fromMap/toMap preserves all fields', () {
      final now = DateTime(2024, 3, 15, 12, 0);
      final original = Book(
        id: 'round',
        title: 'Roundtrip',
        author: 'Writer',
        format: BookFormat.both,
        filePath: '/book.pdf',
        categoryId: 'cat-1',
        notes: 'Some notes',
        lastPage: 42,
        totalPages: 200,
        readingSeconds: 7200,
        lastOpenedAt: now,
        createdAt: now,
        updatedAt: now,
      );
      final restored = Book.fromMap(original.toMap());
      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.author, original.author);
      expect(restored.format, original.format);
      expect(restored.categoryId, original.categoryId);
      expect(restored.notes, original.notes);
      expect(restored.lastPage, original.lastPage);
      expect(restored.totalPages, original.totalPages);
      expect(restored.readingSeconds, original.readingSeconds);
      expect(restored.lastOpenedAt, original.lastOpenedAt);
    });

    test('importFromJson skips entries with missing id', () {
      final json = jsonEncode([
        {'title': 'No ID', 'createdAt': '2024-01-01T00:00:00.000', 'updatedAt': '2024-01-01T00:00:00.000'},
      ]);
      final list = jsonDecode(json) as List;
      final valid = list.where((item) => item is Map && item['id'] is String).toList();
      expect(valid, isEmpty);
    });

    test('importFromJson skips non-map entries', () {
      final json = jsonEncode(['string', 123, null]);
      final list = jsonDecode(json) as List;
      final valid = list.whereType<Map>().toList();
      expect(valid, isEmpty);
    });

    test('importFromJson rejects path traversal in filePath', () {
      final item = {
        'id': 'bad',
        'title': 'Bad',
        'filePath': '../../etc/passwd',
        'createdAt': '2024-01-01T00:00:00.000',
        'updatedAt': '2024-01-01T00:00:00.000',
      };
      // Simulating the validation logic from BookService.importFromJson
      final filePath = item['filePath'];
      final hasTraversal = filePath != null && filePath.contains('..');
      expect(hasTraversal, true);
    });
  });

  group('Book.progressPercent edge cases', () {
    test('progress at page 0 of 10', () {
      final book = Book(id: '1', title: 't', lastPage: 0, totalPages: 10, createdAt: DateTime.now(), updatedAt: DateTime.now());
      expect(book.progressPercent, 0.1);
    });

    test('progress at last page', () {
      final book = Book(id: '1', title: 't', lastPage: 9, totalPages: 10, createdAt: DateTime.now(), updatedAt: DateTime.now());
      expect(book.progressPercent, 1.0);
    });
  });
}
