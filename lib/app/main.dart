import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pdfrx/pdfrx.dart';
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
import 'service_scope.dart';
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
    runApp(PdfReaderApp(
      bookService: bookService, categoryService: categoryService,
      settingsService: settingsService, readingLogService: readingLogService,
      thumbnailService: thumbnailService, ttsService: ttsService,
      ocrService: ocrService, highlightService: highlightService,
      streakService: streakService, bookSettingsService: bookSettingsService,
      pageNotesService: pageNotesService, readingQueueService: readingQueueService,
    ));
  }, (error, stack) {
    CrashLogService.logCrash(error, stack);
  });
}

class PdfReaderApp extends StatefulWidget {
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

  const PdfReaderApp({
    super.key, required this.bookService, required this.categoryService,
    required this.settingsService, required this.readingLogService,
    required this.thumbnailService, required this.ttsService,
    required this.ocrService, required this.highlightService,
    required this.streakService, required this.bookSettingsService,
    required this.pageNotesService, required this.readingQueueService,
  });

  @override
  State<PdfReaderApp> createState() => _PdfReaderAppState();
}

class _PdfReaderAppState extends State<PdfReaderApp> {
  @override
  void initState() { super.initState(); widget.settingsService.addListener(_onSettingsChanged); }
  @override
  void dispose() { widget.settingsService.removeListener(_onSettingsChanged); super.dispose(); }
  void _onSettingsChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final settings = widget.settingsService;
    return ServiceScope(
      bookService: widget.bookService, categoryService: widget.categoryService,
      thumbnailService: widget.thumbnailService, readingLogService: widget.readingLogService,
      ttsService: widget.ttsService, ocrService: widget.ocrService,
      settingsService: settings, highlightService: widget.highlightService,
      streakService: widget.streakService, bookSettingsService: widget.bookSettingsService,
      pageNotesService: widget.pageNotesService, readingQueueService: widget.readingQueueService,
      child: SettingsScope(
        settingsService: settings,
        child: MaterialApp(
          title: 'PDF Reader', debugShowCheckedModeBanner: false,
          themeMode: settings.themeMode,
          theme: ThemeData(colorSchemeSeed: Colors.indigo, brightness: Brightness.light, useMaterial3: true),
          darkTheme: ThemeData(colorSchemeSeed: Colors.indigo, brightness: Brightness.dark, useMaterial3: true),
          locale: settings.locale,
          supportedLocales: const [Locale('vi'), Locale('en')],
          localizationsDelegates: const [
            AppStringsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
