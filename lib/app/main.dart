import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:provider/provider.dart';
import '../core/l10n/app_strings.dart';
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
import '../services/crash_log_service.dart';
import '../services/page_notes_service.dart';
import '../services/reading_queue_service.dart';
import '../services/reminder_service.dart';
import './splash_screen.dart';

export 'service_scope.dart';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    CrashLogService.appVersion = '1.0.0';

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      CrashLogService.logCrash(details.exception, details.stack ?? StackTrace.current);
    };

    ErrorWidget.builder = (FlutterErrorDetails details) {
      return Material(child: Center(child: Padding(padding: const EdgeInsets.all(16), child: Text('Something went wrong', style: const TextStyle(fontSize: 16), textAlign: TextAlign.center))));
    };

    pdfrxFlutterInitialize();
    await Hive.initFlutter();
    debugPrint('=== INIT START ===');
    final bookService = BookService();
    final categoryService = CategoryService();
    final settingsService = SettingsService();
    final readingLogService = ReadingLogService();
    final ttsService = TtsService();
    final ocrService = OcrService();
    final bookSettingsService = BookSettingsService();
    final pageNotesService = PageNotesService();
    final readingQueueService = ReadingQueueService();
    final reminderService = ReminderService();
    try {
      await Future.wait([
        bookService.init().then((_) => debugPrint('  ✓ bookService')),
        categoryService.init().then((_) => debugPrint('  ✓ categoryService')),
        settingsService.init().then((_) => debugPrint('  ✓ settingsService')),
        readingLogService.init().then((_) => debugPrint('  ✓ readingLogService')),
        ttsService.init().then((_) => debugPrint('  ✓ ttsService')),
        ocrService.init().then((_) => debugPrint('  ✓ ocrService')),
        bookSettingsService.init().then((_) => debugPrint('  ✓ bookSettingsService')),
        pageNotesService.init().then((_) => debugPrint('  ✓ pageNotesService')),
        readingQueueService.init().then((_) => debugPrint('  ✓ readingQueueService')),
        reminderService.init().then((_) => debugPrint('  ✓ reminderService')),
      ]);
    } catch (e, stack) {
      debugPrint('=== INIT FAILED: $e ===');
      debugPrint('$stack');
    }
    debugPrint('=== INIT DONE ===');
    if (settingsService.reminderEnabled) {
      debugPrint('=== SCHEDULING REMINDER ===');
      reminderService.scheduleDaily(settingsService.reminderHour, settingsService.reminderMinute);
    }
    final thumbnailService = ThumbnailService();
    final highlightService = HighlightService(bookService);
    final streakService = StreakService(readingLogService, bookService);
    debugPrint('=== RUNNING APP ===');
    runApp(PdfReaderApp(
      bookService: bookService, categoryService: categoryService,
      settingsService: settingsService, readingLogService: readingLogService,
      thumbnailService: thumbnailService, ttsService: ttsService,
      ocrService: ocrService, highlightService: highlightService,
      streakService: streakService, bookSettingsService: bookSettingsService,
      pageNotesService: pageNotesService, readingQueueService: readingQueueService,
      reminderService: reminderService,
    ));
  }, (error, stack) {
    CrashLogService.logCrash(error, stack);
  });
}

class PdfReaderApp extends StatelessWidget {
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

  const PdfReaderApp({
    super.key, required this.bookService, required this.categoryService,
    required this.settingsService, required this.readingLogService,
    required this.thumbnailService, required this.ttsService,
    required this.ocrService, required this.highlightService,
    required this.streakService, required this.bookSettingsService,
    required this.pageNotesService, required this.readingQueueService,
    required this.reminderService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<BookService>.value(value: bookService),
        Provider<CategoryService>.value(value: categoryService),
        Provider<ThumbnailService>.value(value: thumbnailService),
        Provider<ReadingLogService>.value(value: readingLogService),
        ChangeNotifierProvider<TtsService>.value(value: ttsService),
        ChangeNotifierProvider<OcrService>.value(value: ocrService),
        ChangeNotifierProvider<SettingsService>.value(value: settingsService),
        Provider<HighlightService>.value(value: highlightService),
        Provider<StreakService>.value(value: streakService),
        Provider<BookSettingsService>.value(value: bookSettingsService),
        Provider<PageNotesService>.value(value: pageNotesService),
        Provider<ReadingQueueService>.value(value: readingQueueService),
        Provider<ReminderService>.value(value: reminderService),
      ],
      child: Builder(builder: (context) {
        final settings = context.watch<SettingsService>();
        return MaterialApp(
          title: 'PDF Reader', debugShowCheckedModeBanner: false,
          themeMode: settings.themeMode,
          theme: ThemeData(colorSchemeSeed: Colors.indigo, brightness: Brightness.light, useMaterial3: true),
          darkTheme: ThemeData(colorSchemeSeed: Colors.indigo, brightness: Brightness.dark, useMaterial3: true),
          locale: settings.locale,
          supportedLocales: const [Locale('vi'), Locale('en')],
          localizationsDelegates: [
            const AppStringsDelegate(),
            ...AppLocalizations.localizationsDelegates,
          ],
          home: const SplashScreen(),
        );
      }),
    );
  }
}
