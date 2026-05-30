import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_reader/models/highlight.dart';

void main() {
  final now = DateTime(2024, 3, 10);

  group('Highlight serialization', () {
    test('toMap/fromMap roundtrip', () {
      final h = Highlight(
        id: 'h1',
        page: 3,
        startIndex: 10,
        endIndex: 25,
        text: 'selected text',
        colorValue: 0x80FF0000,
        note: 'my note',
        type: AnnotationType.underline,
        createdAt: now,
      );
      final restored = Highlight.fromMap(h.toMap());
      expect(restored.id, 'h1');
      expect(restored.page, 3);
      expect(restored.startIndex, 10);
      expect(restored.endIndex, 25);
      expect(restored.text, 'selected text');
      expect(restored.colorValue, 0x80FF0000);
      expect(restored.note, 'my note');
      expect(restored.type, AnnotationType.underline);
    });

    test('defaults to highlight type when missing', () {
      final h = Highlight.fromMap({
        'id': 'h2',
        'page': 0,
        'startIndex': 0,
        'endIndex': 5,
        'text': 'hi',
        'createdAt': now.toIso8601String(),
      });
      expect(h.type, AnnotationType.highlight);
      expect(h.colorValue, 0x80FFEB3B);
      expect(h.note, '');
    });
  });

  group('Highlight.copyWith', () {
    test('changes color only', () {
      final h = Highlight(id: 'h1', page: 0, startIndex: 0, endIndex: 5, text: 'x', createdAt: now);
      final updated = h.copyWith(colorValue: 0x80FF0000);
      expect(updated.colorValue, 0x80FF0000);
      expect(updated.note, '');
      expect(updated.id, 'h1');
    });

    test('changes note only', () {
      final h = Highlight(id: 'h1', page: 0, startIndex: 0, endIndex: 5, text: 'x', note: 'old', createdAt: now);
      final updated = h.copyWith(note: 'new');
      expect(updated.note, 'new');
      expect(updated.colorValue, h.colorValue);
    });
  });
}
