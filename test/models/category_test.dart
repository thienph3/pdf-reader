import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_reader/models/category.dart';

void main() {
  group('Category', () {
    test('toMap/fromMap roundtrip', () {
      final cat = Category(
        id: 'cat1',
        name: 'Fiction',
        colorValue: 0xFFFF0000,
        createdAt: DateTime(2024, 1, 15),
      );
      final restored = Category.fromMap(cat.toMap());
      expect(restored.id, 'cat1');
      expect(restored.name, 'Fiction');
      expect(restored.colorValue, 0xFFFF0000);
      expect(restored.createdAt, DateTime(2024, 1, 15));
    });

    test('fromMap uses default colorValue when missing', () {
      final cat = Category.fromMap({
        'id': 'cat2',
        'name': 'Science',
        'createdAt': '2024-03-01T00:00:00.000',
      });
      expect(cat.colorValue, 0xFF6366F1);
    });

    test('copyWith updates fields', () {
      final cat = Category(id: 'x', name: 'Old', createdAt: DateTime(2024));
      final updated = cat.copyWith(name: 'New', colorValue: 0xFF00FF00);
      expect(updated.name, 'New');
      expect(updated.colorValue, 0xFF00FF00);
      expect(updated.id, 'x');
    });
  });
}
