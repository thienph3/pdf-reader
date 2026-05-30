import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_reader/services/tts_text_cleaner.dart';

void main() {
  group('TtsTextCleaner.cleanPdfText', () {
    test('joins broken lines without punctuation', () {
      final result = TtsTextCleaner.cleanPdfText('this is a\nbroken line');
      expect(result, 'this is a broken line');
    });

    test('preserves line break after sentence-ending punctuation', () {
      final result = TtsTextCleaner.cleanPdfText('First sentence.\nSecond sentence.');
      expect(result, 'First sentence.\nSecond sentence.');
    });

    test('preserves paragraph breaks (empty lines)', () {
      final result = TtsTextCleaner.cleanPdfText('Paragraph one.\n\nParagraph two.');
      expect(result, 'Paragraph one.\n\nParagraph two.');
    });

    test('collapses multiple blank lines', () {
      final result = TtsTextCleaner.cleanPdfText('A.\n\n\n\nB.');
      expect(result, 'A.\n\nB.');
    });

    test('collapses multiple spaces', () {
      final result = TtsTextCleaner.cleanPdfText('too   many   spaces');
      expect(result, 'too many spaces');
    });

    test('handles empty input', () {
      expect(TtsTextCleaner.cleanPdfText(''), '');
    });

    test('trims whitespace', () {
      expect(TtsTextCleaner.cleanPdfText('  hello  '), 'hello');
    });
  });
}
