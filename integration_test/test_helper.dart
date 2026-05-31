import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pdf_reader/app/main.dart';
import 'package:pdf_reader/services/book_service.dart';
import 'package:pdf_reader/services/category_service.dart';
import 'package:pdf_reader/services/reading_log_service.dart';
import 'package:pdf_reader/services/settings_service.dart';
import 'package:pdf_reader/services/thumbnail_service.dart';
import 'package:pdf_reader/services/tts_service.dart';
import 'package:pdf_reader/services/ocr_service.dart';
import 'package:pdf_reader/services/highlight_service.dart';
import 'package:pdf_reader/services/streak_service.dart';
import 'package:pdf_reader/services/book_settings_service.dart';
import 'package:pdf_reader/services/page_notes_service.dart';
import 'package:pdf_reader/services/reading_queue_service.dart';
import 'package:pdf_reader/services/reminder_service.dart';

class TestServices {
  final BookService bookService;
  final CategoryService categoryService;
  final SettingsService settingsService;
  final ReadingLogService readingLogService;
  final ThumbnailService thumbnailService;
  final TtsService ttsService;
  final OcrService ocrService;
  final HighlightService highlightService;
  final StreakService streakService;
  final BookSettingsService bookSettingsService;
  final PageNotesService pageNotesService;
  final ReadingQueueService readingQueueService;
  final ReminderService reminderService;

  TestServices._({
    required this.bookService,
    required this.categoryService,
    required this.settingsService,
    required this.readingLogService,
    required this.thumbnailService,
    required this.ttsService,
    required this.ocrService,
    required this.highlightService,
    required this.streakService,
    required this.bookSettingsService,
    required this.pageNotesService,
    required this.readingQueueService,
    required this.reminderService,
  });
}

late TestServices _services;
TestServices get services => _services;

Future<Widget> createTestApp() async {
  // Services init (Hive.initFlutter called inside BookService.init)
  final bookService = BookService();
  final categoryService = CategoryService();
  final settingsService = SettingsService();
  final readingLogService = ReadingLogService();
  final ttsService = TtsService();
  final ocrService = OcrService();
  final bookSettingsService = BookSettingsService();
  final pageNotesService = PageNotesService();
  final readingQueueService = ReadingQueueService();

  await Future.wait([
    bookService.init(),
    categoryService.init(),
    settingsService.init(),
    readingLogService.init(),
    ttsService.init(),
    ocrService.init(),
    bookSettingsService.init(),
    pageNotesService.init(),
    readingQueueService.init(),
  ]);

  final thumbnailService = ThumbnailService();
  final highlightService = HighlightService(bookService);
  final streakService = StreakService(readingLogService, bookService);
  final reminderService = ReminderService();
  await reminderService.init();

  _services = TestServices._(
    bookService: bookService,
    categoryService: categoryService,
    settingsService: settingsService,
    readingLogService: readingLogService,
    thumbnailService: thumbnailService,
    ttsService: ttsService,
    ocrService: ocrService,
    highlightService: highlightService,
    streakService: streakService,
    bookSettingsService: bookSettingsService,
    pageNotesService: pageNotesService,
    readingQueueService: readingQueueService,
    reminderService: reminderService,
  );

  return PdfReaderApp(
    bookService: bookService,
    categoryService: categoryService,
    settingsService: settingsService,
    readingLogService: readingLogService,
    thumbnailService: thumbnailService,
    ttsService: ttsService,
    ocrService: ocrService,
    highlightService: highlightService,
    streakService: streakService,
    bookSettingsService: bookSettingsService,
    pageNotesService: pageNotesService,
    readingQueueService: readingQueueService,
    reminderService: reminderService,
  );
}

Future<void> cleanupTest() async {
  // Delete all known boxes so next test starts fresh
  await Hive.deleteBoxFromDisk('books');
  await Hive.deleteBoxFromDisk('categories');
  await Hive.deleteBoxFromDisk('settings');
  await Hive.deleteBoxFromDisk('reading_logs');
  await Hive.deleteBoxFromDisk('reading_queue');
  await Hive.deleteBoxFromDisk('book_settings');
  await Hive.deleteBoxFromDisk('page_notes');
  await Hive.deleteBoxFromDisk('ocr_text');
  await Hive.deleteBoxFromDisk('ocr_md');
  await Hive.close();
}

/// Pumps the app and waits for splash screen to transition to main shell.
Future<void> pumpAndSettle(WidgetTester tester, Widget app) async {
  await tester.pumpWidget(app);
  // Wait for splash animation (1.2s) + transition (0.5s)
  await tester.pump(const Duration(milliseconds: 1800));
  await tester.pumpAndSettle();
}
