import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_reader/models/highlight.dart';

void main() {
  group('Highlights', () {
    late Highlight highlight;

    setUp(() {
      highlight = Highlight(
        id: 'h1', page: 5, startIndex: 10, endIndex: 50,
        text: 'Important passage', colorValue: 0x80FFEB3B,
        note: '', createdAt: DateTime(2024, 1, 1),
      );
    });

    test('highlight stores selected text and page', () {
      expect(highlight.text, 'Important passage');
      expect(highlight.page, 5);
      expect(highlight.startIndex, 10);
      expect(highlight.endIndex, 50);
    });

    test('highlight color can be changed without data loss', () {
      final updated = highlight.copyWith(colorValue: 0x80FF0000);
      expect(updated.colorValue, 0x80FF0000);
      expect(updated.text, 'Important passage');
      expect(updated.page, 5);
      expect(updated.note, '');
      expect(updated.id, 'h1');
    });

    test('highlight note can be edited', () {
      final updated = highlight.copyWith(note: 'This is key');
      expect(updated.note, 'This is key');
      expect(updated.text, 'Important passage');
      expect(updated.colorValue, highlight.colorValue);
    });

    test('highlight type can be changed', () {
      final underline = highlight.copyWith(type: AnnotationType.underline);
      expect(underline.type, AnnotationType.underline);
      expect(underline.text, highlight.text);
    });

    test('highlight serializes and deserializes correctly', () {
      final withNote = highlight.copyWith(note: 'My note');
      final map = withNote.toMap();
      final restored = Highlight.fromMap(map);
      expect(restored.id, withNote.id);
      expect(restored.page, withNote.page);
      expect(restored.text, withNote.text);
      expect(restored.note, 'My note');
      expect(restored.colorValue, withNote.colorValue);
      expect(restored.type, withNote.type);
    });
  });
}
