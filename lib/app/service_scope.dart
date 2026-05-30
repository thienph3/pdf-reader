import 'package:flutter/material.dart';
import '../services/book_service.dart';
import '../services/category_service.dart';
import '../services/reading_log_service.dart';
import '../services/settings_service.dart';
import '../services/thumbnail_service.dart';
import '../services/tts_service.dart';
import '../services/ocr_service.dart';
import '../services/highlight_service.dart';
import '../services/streak_service.dart';
import '../services/book_settings_service.dart';

class BookServiceScope extends InheritedWidget {
  final BookService bookService;
  const BookServiceScope({super.key, required this.bookService, required super.child});
  static BookService of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<ServiceScope>()!.bookService;
  @override
  bool updateShouldNotify(BookServiceScope oldWidget) => false;
}

class CategoryServiceScope extends InheritedWidget {
  final CategoryService categoryService;
  const CategoryServiceScope({super.key, required this.categoryService, required super.child});
  static CategoryService of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<ServiceScope>()!.categoryService;
  @override
  bool updateShouldNotify(CategoryServiceScope oldWidget) => false;
}

class ThumbnailServiceScope extends InheritedWidget {
  final ThumbnailService thumbnailService;
  const ThumbnailServiceScope({super.key, required this.thumbnailService, required super.child});
  static ThumbnailService of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<ServiceScope>()!.thumbnailService;
  @override
  bool updateShouldNotify(ThumbnailServiceScope oldWidget) => false;
}

class ReadingLogServiceScope extends InheritedWidget {
  final ReadingLogService readingLogService;
  const ReadingLogServiceScope({super.key, required this.readingLogService, required super.child});
  static ReadingLogService of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<ServiceScope>()!.readingLogService;
  @override
  bool updateShouldNotify(ReadingLogServiceScope oldWidget) => false;
}

class TtsServiceScope extends InheritedWidget {
  final TtsService ttsService;
  const TtsServiceScope({super.key, required this.ttsService, required super.child});
  static TtsService of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<ServiceScope>()!.ttsService;
  @override
  bool updateShouldNotify(TtsServiceScope oldWidget) => false;
}

class OcrServiceScope extends InheritedWidget {
  final OcrService ocrService;
  const OcrServiceScope({super.key, required this.ocrService, required super.child});
  static OcrService of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<ServiceScope>()!.ocrService;
  @override
  bool updateShouldNotify(OcrServiceScope oldWidget) => false;
}

class HighlightServiceScope {
  static HighlightService of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<ServiceScope>()!.highlightService;
}

class StreakServiceScope {
  static StreakService of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<ServiceScope>()!.streakService;
}

class SettingsScope extends InheritedWidget {
  final SettingsService settingsService;
  const SettingsScope({super.key, required this.settingsService, required super.child});
  static SettingsService of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<SettingsScope>()!.settingsService;
  @override
  bool updateShouldNotify(SettingsScope oldWidget) => settingsService != oldWidget.settingsService;
}

class BookSettingsServiceScope {
  static BookSettingsService of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<ServiceScope>()!.bookSettingsService;
}

/// Single InheritedWidget holding all services.
class ServiceScope extends InheritedWidget {
  final BookService bookService;
  final CategoryService categoryService;
  final ThumbnailService thumbnailService;
  final ReadingLogService readingLogService;
  final TtsService ttsService;
  final OcrService ocrService;
  final SettingsService settingsService;
  final HighlightService highlightService;
  final StreakService streakService;
  final BookSettingsService bookSettingsService;

  const ServiceScope({
    super.key, required this.bookService, required this.categoryService,
    required this.thumbnailService, required this.readingLogService,
    required this.ttsService, required this.ocrService,
    required this.settingsService, required this.highlightService,
    required this.streakService, required this.bookSettingsService,
    required super.child,
  });

  @override
  bool updateShouldNotify(ServiceScope oldWidget) => false;
}
