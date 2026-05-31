import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_reader/services/tts_language_detector.dart';

void main() {
  group('TtsLanguageDetector.detectLanguage', () {
    test('detects Vietnamese', () {
      expect(TtsLanguageDetector.detectLanguage('Xin chào thế giới, đây là tiếng Việt'), 'vi');
    });

    test('detects English', () {
      expect(TtsLanguageDetector.detectLanguage('Hello world, this is English text'), 'en');
    });

    test('detects Chinese', () {
      expect(TtsLanguageDetector.detectLanguage('你好世界这是中文文本'), 'zh');
    });

    test('detects Japanese', () {
      expect(TtsLanguageDetector.detectLanguage('こんにちは世界'), 'ja');
    });

    test('detects Korean', () {
      expect(TtsLanguageDetector.detectLanguage('안녕하세요 세계입니다'), 'ko');
    });

    test('detects Thai', () {
      expect(TtsLanguageDetector.detectLanguage('สวัสดีชาวโลก'), 'th');
    });

    test('empty string defaults to en', () {
      expect(TtsLanguageDetector.detectLanguage(''), 'en');
    });

    test('numbers only defaults to en', () {
      expect(TtsLanguageDetector.detectLanguage('123456789'), 'en');
    });
  });

  group('TtsLanguageDetector.detectLanguage edge cases', () {
    test('mixed Vietnamese + English detects Vietnamese', () {
      expect(TtsLanguageDetector.detectLanguage('Hello đây là mixed text với English'), 'vi');
    });

    test('text with only punctuation defaults to en', () {
      expect(TtsLanguageDetector.detectLanguage('...!!! ???'), 'en');
    });

    test('very long text truncates to 500 chars', () {
      // Vietnamese chars beyond 500 should be ignored
      final longEnglish = 'a' * 500;
      final vietnamese = 'đ' * 100;
      expect(TtsLanguageDetector.detectLanguage(longEnglish + vietnamese), 'en');
    });

    test('Vietnamese within first 500 chars is detected', () {
      final text = 'Đây là văn bản tiếng Việt rất dài ' * 20;
      expect(TtsLanguageDetector.detectLanguage(text), 'vi');
    });
  });

  group('TtsLanguageDetector.findBestLanguageMatch', () {
    test('finds exact match', () {
      expect(
        TtsLanguageDetector.findBestLanguageMatch('vi', ['en-US', 'vi-VN', 'ja-JP']),
        'vi-VN',
      );
    });

    test('falls back to prefix match', () {
      expect(
        TtsLanguageDetector.findBestLanguageMatch('en', ['en-GB', 'vi-VN']),
        'en-GB',
      );
    });

    test('returns null when no match', () {
      expect(
        TtsLanguageDetector.findBestLanguageMatch('ko', ['en-US', 'vi-VN']),
        isNull,
      );
    });
  });
}
