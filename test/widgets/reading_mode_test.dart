import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_reader/features/reader/widgets/reading_mode.dart';

void main() {
  group('getReadingModeFilter', () {
    test('normal mode returns identity filter (transparent dst)', () {
      final filter = getReadingModeFilter(0);
      expect(filter,
          const ColorFilter.mode(Colors.transparent, BlendMode.dst));
    });

    test('sepia mode returns warm matrix filter', () {
      final filter = getReadingModeFilter(1);
      // Sepia has red channel offset of 30
      expect(filter, isA<ColorFilter>());
      expect(filter,
          isNot(const ColorFilter.mode(Colors.transparent, BlendMode.dst)));
    });

    test('dark mode returns invert matrix filter', () {
      final filter = getReadingModeFilter(2);
      expect(filter, isA<ColorFilter>());
      expect(filter, isNot(getReadingModeFilter(0)));
      expect(filter, isNot(getReadingModeFilter(1)));
    });

    test('unknown mode returns identity filter', () {
      final filter = getReadingModeFilter(99);
      expect(filter,
          const ColorFilter.mode(Colors.transparent, BlendMode.dst));
    });
  });
}
