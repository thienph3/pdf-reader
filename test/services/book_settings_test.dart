import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_reader/services/book_settings_service.dart';

void main() {
  group('BookSettings', () {
    test('default values', () {
      const s = BookSettings();
      expect(s.readingMode, 0);
      expect(s.horizontalScroll, false);
      expect(s.cropMargins, 0);
      expect(s.brightness, -1);
      expect(s.lastZoom, 1.0);
    });

    test('toMap/fromMap roundtrip', () {
      const s = BookSettings(
        readingMode: 2,
        horizontalScroll: true,
        cropMargins: 15,
        brightness: 0.8,
        lastZoom: 2.5,
      );
      final restored = BookSettings.fromMap(s.toMap());
      expect(restored.readingMode, 2);
      expect(restored.horizontalScroll, true);
      expect(restored.cropMargins, 15);
      expect(restored.brightness, 0.8);
      expect(restored.lastZoom, 2.5);
    });

    test('backward compat: bool cropMargins true → 20', () {
      final s = BookSettings.fromMap({'cropMargins': true});
      expect(s.cropMargins, 20);
    });

    test('backward compat: bool cropMargins false → 0', () {
      final s = BookSettings.fromMap({'cropMargins': false});
      expect(s.cropMargins, 0);
    });

    test('fromMap handles missing fields with defaults', () {
      final s = BookSettings.fromMap({});
      expect(s.readingMode, 0);
      expect(s.horizontalScroll, false);
      expect(s.cropMargins, 0);
      expect(s.brightness, -1);
      expect(s.lastZoom, 1.0);
    });

    test('copyWith updates selected fields', () {
      const s = BookSettings();
      final updated = s.copyWith(readingMode: 1, lastZoom: 3.0);
      expect(updated.readingMode, 1);
      expect(updated.lastZoom, 3.0);
      expect(updated.horizontalScroll, false);
    });
  });
}
