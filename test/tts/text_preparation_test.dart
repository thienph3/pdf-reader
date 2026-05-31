import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_reader/services/tts_text_cleaner.dart';

void main() {
  group('TTS text is cleaned for natural reading', () {
    test('broken lines from PDF layout are joined', () {
      const raw = 'This is a sen-\ntence that was\nbroken by PDF layout.';
      final cleaned = TtsTextCleaner.cleanPdfText(raw);
      // Lines without sentence-ending punctuation should be joined with space
      expect(cleaned, contains('sen- tence'));
      expect(cleaned, isNot(contains('sen-\ntence')));
    });

    test('paragraph breaks are preserved', () {
      const raw = 'First paragraph.\n\nSecond paragraph.';
      final cleaned = TtsTextCleaner.cleanPdfText(raw);
      expect(cleaned, contains('\n\n'));
      expect(cleaned, contains('First paragraph.'));
      expect(cleaned, contains('Second paragraph.'));
    });

    test('excessive whitespace is collapsed', () {
      const raw = 'Hello     world';
      final cleaned = TtsTextCleaner.cleanPdfText(raw);
      expect(cleaned, isNot(contains('     ')));
      expect(cleaned, contains('Hello world'));
    });

    test('excessive newlines are collapsed', () {
      const raw = 'Para 1.\n\n\n\n\nPara 2.';
      final cleaned = TtsTextCleaner.cleanPdfText(raw);
      // Should not have more than 2 consecutive newlines
      expect(cleaned, isNot(contains('\n\n\n')));
    });

    test('Vietnamese diacritics are preserved', () {
      const raw = 'Xin chào thế giới.\n\nĐây là tiếng Việt.';
      final cleaned = TtsTextCleaner.cleanPdfText(raw);
      expect(cleaned, contains('chào'));
      expect(cleaned, contains('Đây'));
      expect(cleaned, contains('Việt'));
    });

    test('sentence-ending punctuation starts new line', () {
      const raw = 'First sentence.\nSecond sentence.';
      final cleaned = TtsTextCleaner.cleanPdfText(raw);
      expect(cleaned, contains('First sentence.\nSecond sentence.'));
    });

    test('empty input produces empty output', () {
      expect(TtsTextCleaner.cleanPdfText(''), '');
    });
  });
}
