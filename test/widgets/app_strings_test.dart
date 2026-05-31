import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_reader/core/l10n/app_strings.dart';

void main() {
  group('AppStrings', () {
    test('Vietnamese strings differ from English', () {
      final vi = const AppStrings(Locale('vi'));
      final en = const AppStrings(Locale('en'));
      expect(vi.library, isNot(equals(en.library)));
      expect(vi.settings, isNot(equals(en.settings)));
      expect(vi.cancel, isNot(equals(en.cancel)));
    });

    test('English string getters return non-empty', () {
      final s = const AppStrings(Locale('en'));
      expect(s.library, isNotEmpty);
      expect(s.settings, isNotEmpty);
      expect(s.cancel, isNotEmpty);
      expect(s.save, isNotEmpty);
      expect(s.delete, isNotEmpty);
      expect(s.addBook, isNotEmpty);
      expect(s.statistics, isNotEmpty);
      expect(s.highlights, isNotEmpty);
    });

    test('appName is same for both locales', () {
      final vi = const AppStrings(Locale('vi'));
      final en = const AppStrings(Locale('en'));
      expect(vi.appName, equals(en.appName));
      expect(en.appName, 'PDF Reader');
    });

    test('parameterized strings work', () {
      final s = const AppStrings(Locale('en'));
      expect(s.ocrProgress(3, 10), contains('3'));
      expect(s.ocrProgress(3, 10), contains('10'));
      expect(s.searchResults(5), contains('5'));
    });
  });

  group('AppStringsDelegate', () {
    test('supports vi and en', () {
      const delegate = AppStringsDelegate();
      expect(delegate.isSupported(const Locale('vi')), isTrue);
      expect(delegate.isSupported(const Locale('en')), isTrue);
      expect(delegate.isSupported(const Locale('fr')), isFalse);
    });

    test('shouldReload returns false', () {
      const delegate = AppStringsDelegate();
      expect(delegate.shouldReload(delegate), isFalse);
    });
  });
}
