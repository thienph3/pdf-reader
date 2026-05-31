import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_reader/services/book_settings_service.dart';

void main() {
  group('Per-book settings', () {
    test('reading mode is saved per book', () {
      const settings = BookSettings(readingMode: 2);
      final map = settings.toMap();
      final restored = BookSettings.fromMap(map);
      expect(restored.readingMode, 2);
    });

    test('crop level is saved per book', () {
      const settings = BookSettings(cropMargins: 20);
      final map = settings.toMap();
      final restored = BookSettings.fromMap(map);
      expect(restored.cropMargins, 20);
    });

    test('horizontal scroll preference is saved', () {
      const settings = BookSettings(horizontalScroll: true);
      final map = settings.toMap();
      final restored = BookSettings.fromMap(map);
      expect(restored.horizontalScroll, isTrue);
    });

    test('settings default to sensible values for new books', () {
      const settings = BookSettings();
      expect(settings.readingMode, 0);
      expect(settings.horizontalScroll, isFalse);
      expect(settings.cropMargins, 0);
      expect(settings.brightness, -1); // system brightness
      expect(settings.lastZoom, 1.0);
    });

    test('old boolean crop setting migrates to integer', () {
      // Old data stored cropMargins as bool (true = crop enabled)
      final oldMap = {
        'readingMode': 0,
        'horizontalScroll': false,
        'cropMargins': true,  // old boolean format
        'brightness': -1.0,
        'lastZoom': 1.0,
      };
      final settings = BookSettings.fromMap(oldMap);
      expect(settings.cropMargins, 20); // true migrates to 20%
    });

    test('old boolean crop false migrates to 0', () {
      final oldMap = {
        'cropMargins': false,
      };
      final settings = BookSettings.fromMap(oldMap);
      expect(settings.cropMargins, 0);
    });

    test('missing fields in stored map use defaults', () {
      final settings = BookSettings.fromMap({});
      expect(settings.readingMode, 0);
      expect(settings.horizontalScroll, isFalse);
      expect(settings.cropMargins, 0);
      expect(settings.brightness, -1);
      expect(settings.lastZoom, 1.0);
    });

    test('zoom level is preserved', () {
      const settings = BookSettings(lastZoom: 2.5);
      final map = settings.toMap();
      final restored = BookSettings.fromMap(map);
      expect(restored.lastZoom, 2.5);
    });

    test('brightness setting is preserved', () {
      const settings = BookSettings(brightness: 0.7);
      final map = settings.toMap();
      final restored = BookSettings.fromMap(map);
      expect(restored.brightness, closeTo(0.7, 0.001));
    });
  });
}
