import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_reader/services/tts_language_detector.dart';

void main() {
  group('TTS reads text in the correct language', () {
    test('Vietnamese text is detected and read in Vietnamese', () {
      expect(TtsLanguageDetector.detectLanguage('Xin chào thế giới'), 'vi');
      expect(TtsLanguageDetector.detectLanguage('Đây là tiếng Việt'), 'vi');
    });

    test('English text is detected and read in English', () {
      expect(TtsLanguageDetector.detectLanguage('Hello world'), 'en');
      expect(TtsLanguageDetector.detectLanguage('This is English text'), 'en');
    });

    test('Chinese characters trigger Chinese TTS', () {
      expect(TtsLanguageDetector.detectLanguage('你好世界这是中文'), 'zh');
    });

    test('Japanese hiragana triggers Japanese TTS', () {
      expect(TtsLanguageDetector.detectLanguage('こんにちは世界'), 'ja');
    });

    test('Korean text triggers Korean TTS', () {
      expect(TtsLanguageDetector.detectLanguage('안녕하세요 세계입니다'), 'ko');
    });

    test('Thai text triggers Thai TTS', () {
      expect(TtsLanguageDetector.detectLanguage('สวัสดีชาวโลก'), 'th');
    });

    test('mixed Vietnamese and English defaults to Vietnamese', () {
      expect(
        TtsLanguageDetector.detectLanguage('Đây là mixed text with English'),
        'vi',
      );
    });

    test('empty text defaults to English', () {
      expect(TtsLanguageDetector.detectLanguage(''), 'en');
    });

    test('language match finds correct locale', () {
      final available = ['vi-VN', 'en-US', 'zh-CN', 'ja-JP'];
      expect(
        TtsLanguageDetector.findBestLanguageMatch('vi', available),
        'vi-VN',
      );
      expect(
        TtsLanguageDetector.findBestLanguageMatch('en', available),
        'en-US',
      );
      expect(
        TtsLanguageDetector.findBestLanguageMatch('zh', available),
        'zh-CN',
      );
    });

    test('language match returns null when not available', () {
      expect(
        TtsLanguageDetector.findBestLanguageMatch('fr', ['en-US', 'vi-VN']),
        isNull,
      );
    });
  });
}
