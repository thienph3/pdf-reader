import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:screen_brightness/screen_brightness.dart';
import '../../../services/book_service.dart';
import '../../../services/reading_log_service.dart';
import '../../../services/book_settings_service.dart';
import '../../../app/main.dart';
import '../../../services/tts_service.dart';
import '../../../core/l10n/app_strings.dart';
import '../providers/content_provider.dart';
import '../providers/pdf_content_provider.dart';
import '../providers/epub_content_provider.dart';
import '../providers/text_content_provider.dart';
import '../providers/cbz_content_provider.dart';
import '../controllers/tts_controller.dart';
import '../controllers/reader_ui_state.dart';
import 'reader_screen_body.dart';

part 'reader_screen_logic.dart';

class ReaderScreen extends StatefulWidget {
  final String filePath;
  final String fileName;
  final String? bookId;
  final int initialPage;

  const ReaderScreen({
    super.key, required this.filePath, required this.fileName,
    this.bookId, this.initialPage = 0,
  });

  @override
  State<ReaderScreen> createState() => ReaderScreenState();
}

class ReaderScreenState extends State<ReaderScreen> {
  late final bool _isEpub;
  late final ContentProvider _provider;
  PdfContentProvider? _pdfProvider;
  EpubContentProvider? _epubProvider;
  PageController? _epubPageController;

  BookService? _bookService;
  ReadingLogService? _readingLogService;
  BookSettingsService? _bookSettingsService;

  // ignore: unused_field
  final _ui = ReaderUiState();

  int _currentPage = 0, _totalPages = 0;
  bool _closed = false, _fullscreen = false, _pdfLoading = true;
  bool _isSearching = false, _showBrightnessIndicator = false;
  bool _showTimer = false;
  double _brightness = 0.5;
  int _readingMode = 0, _cropMargins = 0;
  bool _horizontalScroll = false;
  Timer? _saveDebounce;
  int _sessionSeconds = 0, _sessionStartPage = 0;
  Timer? _readingTimer;
  bool _ttsListenerAdded = false;

  TtsService get ttsService => TtsServiceScope.of(context);
  bool get isEpub => _isEpub;
  bool get isPdf => !_isEpub;
  ContentProvider get provider => _provider;
  PdfContentProvider? get pdfProvider => _pdfProvider;
  EpubContentProvider? get epubProvider => _epubProvider;
  PageController? get epubPageController => _epubPageController;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get fullscreen => _fullscreen;
  bool get isSearching => _isSearching;
  bool get showBrightnessIndicator => _showBrightnessIndicator;
  double get brightness => _brightness;
  int get readingMode => _readingMode;
  int get cropMargins => _cropMargins;
  bool get horizontalScroll => _horizontalScroll;
  bool get pdfLoading => _pdfLoading;
  bool get showTimer => _showTimer;
  int get sessionSeconds => _sessionSeconds;

  @override
  void initState() {
    super.initState();
    try { WakelockPlus.enable(); } catch (_) {}
    try {
      ScreenBrightness().application.then((v) {
        if (mounted) setState(() => _brightness = v);
      });
    } catch (_) {}
    _currentPage = widget.initialPage;
    _sessionStartPage = widget.initialPage;
    final ext = widget.filePath.toLowerCase().split('.').last;
    _isEpub = ext != 'pdf';

    if (ext == 'epub') {
      _epubProvider = EpubContentProvider(filePath: widget.filePath);
      _provider = _epubProvider!;
      _epubPageController = PageController(initialPage: widget.initialPage);
      _epubProvider!.load().then((_) {
        if (!mounted) return;
        setState(() { _pdfLoading = false; _totalPages = _epubProvider!.totalPages; });
        _restoreEpubProgress();
      });
    } else if (ext == 'txt' || ext == 'md') {
      final textProvider = TextContentProvider(filePath: widget.filePath);
      _provider = textProvider;
      _epubPageController = PageController(initialPage: widget.initialPage);
      textProvider.load().then((_) {
        if (!mounted) return;
        setState(() { _pdfLoading = false; _totalPages = textProvider.totalPages; });
      });
    } else if (ext == 'cbz' || ext == 'cbr') {
      final cbzProvider = CbzContentProvider(filePath: widget.filePath);
      _provider = cbzProvider;
      _epubPageController = PageController(initialPage: widget.initialPage);
      cbzProvider.load().then((_) {
        if (!mounted) return;
        setState(() { _pdfLoading = false; _totalPages = cbzProvider.totalPages; });
      });
    } else {
      _pdfProvider = PdfContentProvider(
        filePath: widget.filePath, bookId: widget.bookId,
      );
      _provider = _pdfProvider!;
    }
    _readingTimer = Timer.periodic(
      const Duration(seconds: 1), (_) => _sessionSeconds++,
    );
  }

  void _restoreEpubProgress() {
    if (widget.bookId == null) return;
    final bookService = BookServiceScope.of(context);
    final saved = bookService.getById(widget.bookId!);
    if (saved != null && saved.lastPage < _totalPages && saved.lastPage > 0) {
      _currentPage = saved.lastPage;
      _epubPageController?.jumpToPage(saved.lastPage);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_ttsListenerAdded && !_isEpub) {
      _ttsListenerAdded = true;
      ttsService.addListener(_onTtsStateChanged);
    }
    if (!_isEpub) {
      _pdfProvider!.initControllers(
        bookService: _bookService,
        onStateChanged: () { if (mounted) setState(() {}); },
      );
      _pdfProvider!.ttsController = PdfTtsController(
        ttsService: ttsService,
        highlightManager: _pdfProvider!.highlightManager,
        viewerController: _pdfProvider!.viewerController,
        bookId: widget.bookId,
        onStateChanged: () { if (mounted) setState(() {}); },
      );
    }
    if (widget.bookId != null) {
      final s = BookServiceScope.of(context);
      _readingLogService = ReadingLogServiceScope.of(context);
      if (_bookService != s) {
        _bookService = s;
        if (!_isEpub) {
          _pdfProvider!.highlightManager.updateService(s);
          _pdfProvider!.bookmarkManager.updateService(s);
        }
      }
    }
    loadBookSettings();
  }

  void _onTtsStateChanged() => handleTtsStateChanged();

  @override
  void dispose() {
    _saveDebounce?.cancel();
    _readingTimer?.cancel();
    _epubPageController?.dispose();
    if (!_isEpub) ttsService.removeListener(_onTtsStateChanged);
    if (!_closed) saveProgress();
    _provider.dispose();
    try { WakelockPlus.disable(); } catch (_) {}
    try { ScreenBrightness().resetApplicationScreenBrightness(); } catch (_) {}
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ReaderScreenBody(state: this);
}
