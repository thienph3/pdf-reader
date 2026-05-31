import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_reader/core/l10n/app_strings.dart';

void main() {
  group('App supports Vietnamese and English', () {
    test('Vietnamese locale shows Vietnamese text', () {
      final strings = AppStrings.fromLocale(const Locale('vi'));
      expect(strings.library, 'Thư viện sách');
      expect(strings.cancel, 'Huỷ');
      expect(strings.save, 'Lưu');
      expect(strings.delete, 'Xoá');
      expect(strings.addBook, 'Thêm sách');
      expect(strings.settings, 'Cài đặt');
    });

    test('English locale shows English text', () {
      final strings = AppStrings.fromLocale(const Locale('en'));
      expect(strings.library, 'Library');
      expect(strings.cancel, 'Cancel');
      expect(strings.save, 'Save');
      expect(strings.delete, 'Delete');
      expect(strings.addBook, 'Add book');
      expect(strings.settings, 'Settings');
    });

    test('all key strings are non-empty in Vietnamese', () {
      final strings = AppStrings.fromLocale(const Locale('vi'));
      expect(strings.library.isNotEmpty, isTrue);
      expect(strings.searchHint.isNotEmpty, isTrue);
      expect(strings.noBooks.isNotEmpty, isTrue);
      expect(strings.addBook.isNotEmpty, isTrue);
      expect(strings.bookTitle.isNotEmpty, isTrue);
      expect(strings.readingGoals.isNotEmpty, isTrue);
      expect(strings.statistics.isNotEmpty, isTrue);
      expect(strings.tts.isNotEmpty, isTrue);
      expect(strings.highlight.isNotEmpty, isTrue);
      expect(strings.exportAnnotations.isNotEmpty, isTrue);
    });

    test('all key strings are non-empty in English', () {
      final strings = AppStrings.fromLocale(const Locale('en'));
      expect(strings.library.isNotEmpty, isTrue);
      expect(strings.searchHint.isNotEmpty, isTrue);
      expect(strings.noBooks.isNotEmpty, isTrue);
      expect(strings.addBook.isNotEmpty, isTrue);
      expect(strings.bookTitle.isNotEmpty, isTrue);
      expect(strings.readingGoals.isNotEmpty, isTrue);
      expect(strings.statistics.isNotEmpty, isTrue);
      expect(strings.tts.isNotEmpty, isTrue);
      expect(strings.highlight.isNotEmpty, isTrue);
      expect(strings.exportAnnotations.isNotEmpty, isTrue);
    });

    test('parameterized strings work correctly', () {
      final vi = AppStrings.fromLocale(const Locale('vi'));
      final en = AppStrings.fromLocale(const Locale('en'));
      expect(vi.importSuccess(5), contains('5'));
      expect(en.importSuccess(5), contains('5'));
      expect(vi.page(10), contains('10'));
      expect(en.page(10), contains('10'));
    });

    test('delegate supports vi and en', () {
      const delegate = AppStringsDelegate();
      expect(delegate.isSupported(const Locale('vi')), isTrue);
      expect(delegate.isSupported(const Locale('en')), isTrue);
      expect(delegate.isSupported(const Locale('fr')), isFalse);
    });
  });
}
