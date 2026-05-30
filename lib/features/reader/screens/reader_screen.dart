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
import '../controllers/pdf_tts_controller.dart';
import 'reader_screen_body.dart';

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

  int _currentPage = 0, _totalPages = 0;
  bool _closed = false, _fullscreen = false, _pdfLoading = true;
  bool _isSearching = false, _showBrightnessIndicator = false;
  double _brightness = 0.5;
  int _readingMode = 0, _cropMargins = 0;
  bool _horizontalScroll = false;
  Timer? _saveDebounce;
  int _sessionSeconds = 0, _sessionStartPage = 0;
  Timer? _readingTimer;
  bool _ttsListenerAdded = false;

  TtsService get ttsService => TtsServiceScope.of(context);
  bool get isEpub => _isEpub;
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

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    ScreenBrightness().application.then((v) {
      if (mounted) setState(() => _brightness = v);
    });
    _currentPage = widget.initialPage;
    _sessionStartPage = widget.initialPage;
    _isEpub = widget.filePath.toLowerCase().endsWith('.epub');

    if (_isEpub) {
      _epubProvider = EpubContentProvider(filePath: widget.filePath);
      _provider = _epubProvider!;
      _epubPageController = PageController(initialPage: widget.initialPage);
      _epubProvider!.load().then((_) {
        if (!mounted) return;
        setState(() {
          _pdfLoading = false;
          _totalPages = _epubProvider!.totalPages;
        });
        _restoreEpubProgress();
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
    _loadBookSettings();
  }

  void _loadBookSettings() {
    try {
      _horizontalScroll = SettingsScope.of(context).isHorizontalScroll;
      _readingMode = SettingsScope.of(context).readingMode;
    } catch (_) {}
    if (_bookSettingsService == null && widget.bookId != null) {
      _bookSettingsService = BookSettingsServiceScope.of(context);
      final bs = _bookSettingsService!.getSettings(widget.bookId!);
      _readingMode = bs.readingMode;
      _horizontalScroll = bs.horizontalScroll;
      _cropMargins = bs.cropMargins;
      if (bs.brightness >= 0) {
        _brightness = bs.brightness;
        ScreenBrightness().setApplicationScreenBrightness(bs.brightness);
      }
    }
  }

  void _onTtsStateChanged() {
    if (_isEpub) return;
    _pdfProvider!.ttsController.onTtsStateChanged(_currentPage, _totalPages);
    if (_pdfProvider!.ttsController.ttsActive && ttsService.isStopped &&
        ttsService.currentText == null && _currentPage + 1 < _totalPages) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && _pdfProvider!.ttsController.ttsActive) {
          _pdfProvider!.ttsController.speakCurrentPage(
            context, _currentPage, _pdfProvider!.pdfDocument,
            _pdfProvider!.ocrController.setOcrInProgress,
          );
        }
      });
    }
    if (mounted) setState(() {});
  }

  void onPageChanged(int page) {
    setState(() { _currentPage = page; _totalPages = _provider.totalPages; });
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 500), _saveProgress);
    if (!_isEpub) {
      _pdfProvider!.highlightManager
          .preloadTextAroundCurrentPage(_currentPage, _pdfProvider!.pdfDocument);
      _pdfProvider!.ttsController.onPageChangedWhileTts(
        context, _currentPage, _pdfProvider!.pdfDocument,
        _pdfProvider!.ocrController.setOcrInProgress,
      );
      if (_pdfProvider!.textViewController.textViewMode) {
        _pdfProvider!.textViewController
            .loadPage(context, _currentPage, _pdfProvider!.pdfDocument);
      }
    }
  }

  void onContentReady() {
    setState(() {
      _pdfLoading = false;
      _totalPages = _provider.totalPages;
      if (_currentPage >= _totalPages) _currentPage = 0;
    });
    if (!_isEpub && widget.bookId != null && _bookService != null) {
      _bookService!.saveProgress(widget.bookId!, _currentPage,
          totalPages: _totalPages);
    }
    if (!_isEpub) {
      _pdfProvider!.highlightManager
          .preloadTextAroundCurrentPage(_currentPage, _pdfProvider!.pdfDocument);
      _restoreZoom();
    }
  }

  void _restoreZoom() {
    if (widget.bookId == null || _bookSettingsService == null || _isEpub) return;
    final z = _bookSettingsService!.getSettings(widget.bookId!).lastZoom;
    if (z > 1.0) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _pdfProvider!.viewerController.setZoom(
            _pdfProvider!.viewerController.centerPosition, z,
          );
        }
      });
    }
  }

  void _saveProgress() {
    if (widget.bookId == null || _bookService == null) return;
    final s = _sessionSeconds; _sessionSeconds = 0;
    if (s == 0 && _currentPage == _sessionStartPage) return;
    if (_isEpub) {
      final book = _bookService!.getById(widget.bookId!);
      if (book != null) {
        _bookService!.update(book.copyWith(
          lastPage: _currentPage, totalPages: _totalPages,
          lastOpenedAt: () => DateTime.now(),
        ));
      }
    } else {
      _bookService!.saveProgress(widget.bookId!, _currentPage,
          totalPages: _totalPages, addSeconds: s > 0 ? s : null);
    }
    final p = (_currentPage > _sessionStartPage)
        ? _currentPage - _sessionStartPage : 0;
    _sessionStartPage = _currentPage;
    if (s > 0 || p > 0) _readingLogService?.logReading(seconds: s, pages: p);
    _saveBookSettings();
  }

  void saveBookSettings() => _saveBookSettings();

  void _saveBookSettings() {
    if (widget.bookId == null || _bookSettingsService == null || _isEpub) return;
    _bookSettingsService!.saveSettings(widget.bookId!, BookSettings(
      readingMode: _readingMode, horizontalScroll: _horizontalScroll,
      cropMargins: _cropMargins, brightness: _brightness,
      lastZoom: _pdfProvider!.viewerController.currentZoom,
    ));
  }

  void toggleFullscreen() {
    setState(() => _fullscreen = !_fullscreen);
    if (_fullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  void setSearching(bool v) => setState(() => _isSearching = v);
  void setReadingMode(int m) => setState(() => _readingMode = m);
  void setCropMargins(int c) { setState(() => _cropMargins = c); _saveBookSettings(); }
  void setBrightness(double v) {
    setState(() { _brightness = v; _showBrightnessIndicator = true; });
    ScreenBrightness().setApplicationScreenBrightness(v);
  }
  void hideBrightnessIndicator() =>
      setState(() => _showBrightnessIndicator = false);

  void closeAndPop() {
    if (_closed) return;
    _closed = true;
    _saveDebounce?.cancel();
    _readingTimer?.cancel();
    _saveProgress();
    if (mounted) Navigator.pop(context);
  }

  void showGoToPageDialog() {
    final s = AppStrings.of(context);
    final ctrl = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text(s.goToPage),
      content: TextField(controller: ctrl, keyboardType: TextInputType.number,
          autofocus: true, decoration: InputDecoration(hintText: '1 - $_totalPages')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(s.cancel)),
        TextButton(onPressed: () {
          final p = int.tryParse(ctrl.text);
          if (p != null && p >= 1 && p <= _totalPages) {
            Navigator.pop(ctx);
            if (_isEpub) {
              _epubPageController?.jumpToPage(p - 1);
            } else {
              _pdfProvider!.viewerController.goToPage(pageNumber: p);
            }
          }
        }, child: Text(s.go)),
      ],
    ));
  }

  void snapToCurrentPage() {
    if (_isEpub) return;
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted || !_horizontalScroll) return;
      final p = _pdfProvider!.viewerController.pageNumber;
      if (p != null && p > 0) {
        _pdfProvider!.viewerController.goToPage(
          pageNumber: p, duration: const Duration(milliseconds: 200),
        );
      }
    });
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    _readingTimer?.cancel();
    _epubPageController?.dispose();
    if (!_isEpub) ttsService.removeListener(_onTtsStateChanged);
    if (!_closed) _saveProgress();
    _provider.dispose();
    WakelockPlus.disable();
    ScreenBrightness().resetApplicationScreenBrightness();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ReaderScreenBody(state: this);
}
