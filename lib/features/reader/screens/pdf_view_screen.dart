import 'dart:async';
import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import '../../../services/book_service.dart';
import '../../../services/reading_log_service.dart';
import '../../../app/main.dart';
import '../../../models/highlight.dart';
import '../widgets/search_results_bar.dart';
import '../controllers/pdf_highlight_manager.dart';
import '../controllers/pdf_bookmark_manager.dart';
import '../controllers/pdf_text_selection_manager.dart';
import '../widgets/pdf_view_ui_builder.dart';
import '../controllers/pdf_view_dialogs_manager.dart';
import '../controllers/pdf_view_highlights_ui.dart';
import '../controllers/pdf_tts_controller.dart';
import '../controllers/pdf_ocr_controller.dart';
import '../controllers/pdf_text_view.dart';
import '../widgets/pdf_page_thumbnails.dart';
import '../widgets/pdf_ocr_overlay.dart';
import '../widgets/pdf_viewer_body.dart';
import '../../../services/tts_service.dart';

class PdfViewScreen extends StatefulWidget {
  final String filePath;
  final String fileName;
  final String? bookId;
  final int initialPage;

  const PdfViewScreen({
    super.key, required this.filePath, required this.fileName,
    this.bookId, this.initialPage = 0,
  });

  @override
  State<PdfViewScreen> createState() => _PdfViewScreenState();
}

class _PdfViewScreenState extends State<PdfViewScreen> {
  final PdfViewerController _viewerController = PdfViewerController();
  BookService? _bookService;
  ReadingLogService? _readingLogService;
  PdfDocument? _pdfDocument;
  bool _horizontalScroll = false;

  late PdfHighlightManager _highlightManager;
  late PdfBookmarkManager _bookmarkManager;
  late PdfTextSelectionManager _textSelectionManager;
  late PdfTtsController _ttsController;
  late PdfOcrController _ocrController;
  late PdfTextViewController _textViewController;
  late PdfViewUiBuilder _uiBuilder;
  late PdfViewDialogsManager _dialogsManager;
  late PdfViewHighlightsUi _highlightsUi;

  int _totalPages = 0, _currentPage = 0, _readingMode = 0;
  bool _closed = false, _isSearching = false, _pdfLoading = true;
  String? _pdfError;
  Timer? _saveDebounce;
  int _sessionSeconds = 0, _sessionStartPage = 0;
  Timer? _readingTimer;
  final TextEditingController _searchCtrl = TextEditingController();
  PdfTextSearcher? _textSearcher;
  bool _ttsListenerAdded = false;

  TtsService get _ttsService => TtsServiceScope.of(context);

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _sessionStartPage = widget.initialPage;
    if (!io.File(widget.filePath).existsSync()) _pdfError = 'File not found';
    _highlightManager = PdfHighlightManager(bookService: _bookService, bookId: widget.bookId, viewerController: _viewerController, onHighlightsUpdated: () { if (mounted) setState(() {}); });
    _bookmarkManager = PdfBookmarkManager(bookService: _bookService, bookId: widget.bookId, onBookmarksUpdated: () { if (mounted) setState(() {}); });
    _textSelectionManager = PdfTextSelectionManager(highlightManager: _highlightManager, onHighlightCreated: () { if (mounted) setState(() {}); });
    _readingTimer = Timer.periodic(const Duration(seconds: 1), (_) => _sessionSeconds++);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_ttsListenerAdded) { _ttsListenerAdded = true; _ttsService.addListener(_onTtsStateChanged); }
    _ttsController = PdfTtsController(ttsService: _ttsService, highlightManager: _highlightManager, viewerController: _viewerController, bookId: widget.bookId, onStateChanged: () { if (mounted) setState(() {}); });
    _ocrController = PdfOcrController(bookId: widget.bookId, highlightManager: _highlightManager, onStateChanged: () { if (mounted) setState(() {}); });
    _textViewController = PdfTextViewController(bookId: widget.bookId, highlightManager: _highlightManager, onStateChanged: () { if (mounted) setState(() {}); });
    if (widget.bookId != null) {
      final s = BookServiceScope.of(context);
      _readingLogService = ReadingLogServiceScope.of(context);
      if (_bookService != s) { _bookService = s; _highlightManager.updateService(s); _bookmarkManager.updateService(s); }
    }
    try { _horizontalScroll = SettingsScope.of(context).isHorizontalScroll; _readingMode = SettingsScope.of(context).readingMode; } catch (_) {}
  }

  void _onTtsStateChanged() {
    _ttsController.onTtsStateChanged(_currentPage, _totalPages);
    if (_ttsController.ttsActive && _ttsService.isStopped && _ttsService.currentText == null && _currentPage + 1 < _totalPages) {
      Future.delayed(const Duration(milliseconds: 500), () { if (mounted && _ttsController.ttsActive) _ttsController.speakCurrentPage(context, _currentPage, _pdfDocument, _ocrController.setOcrInProgress); });
    }
    if (mounted) setState(() {});
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 500), _saveProgress);
    _highlightManager.preloadTextAroundCurrentPage(_currentPage, _pdfDocument);
    _ttsController.onPageChangedWhileTts(context, _currentPage, _pdfDocument, _ocrController.setOcrInProgress);
    if (_textViewController.textViewMode) _textViewController.loadPage(context, _currentPage, _pdfDocument);
  }

  void _saveProgress() {
    if (widget.bookId == null || _bookService == null) return;
    final s = _sessionSeconds; _sessionSeconds = 0;
    if (s == 0 && _currentPage == _sessionStartPage) return;
    _bookService!.saveProgress(widget.bookId!, _currentPage, totalPages: _totalPages, addSeconds: s > 0 ? s : null);
    final p = (_currentPage > _sessionStartPage) ? _currentPage - _sessionStartPage : 0;
    _sessionStartPage = _currentPage;
    if (s > 0 || p > 0) _readingLogService?.logReading(seconds: s, pages: p);
  }

  Highlight? _findTappedHighlight(PdfPageHitTestResult hit) {
    final highlights = _highlightManager.getHighlightsForCurrentPage(hit.page.pageNumber - 1);
    if (highlights.isEmpty) return null;
    final text = _highlightManager.highlightTextCache.get(hit.page.pageNumber);
    if (text == null) return null;
    for (final h in highlights) {
      if (h.startIndex < 0 || h.endIndex > text.charRects.length) continue;
      for (var i = h.startIndex; i < h.endIndex; i++) { if (text.charRects[i].containsPoint(hit.offset)) return h; }
    }
    return null;
  }

  void _closeAndPop() { if (_closed) return; _closed = true; _saveDebounce?.cancel(); _readingTimer?.cancel(); _saveProgress(); if (mounted) Navigator.pop(context); }

  void _snapToCurrentPage() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted || !_horizontalScroll) return;
      final p = _viewerController.pageNumber;
      if (p != null && p > 0) _viewerController.goToPage(pageNumber: p, duration: const Duration(milliseconds: 200));
    });
  }

  @override
  void dispose() { _saveDebounce?.cancel(); _readingTimer?.cancel(); _searchCtrl.dispose(); _textSearcher?.dispose(); _ttsService.removeListener(_onTtsStateChanged); if (!_closed) _saveProgress(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    _uiBuilder = PdfViewUiBuilder(bookmarkManager: _bookmarkManager, fileName: widget.fileName, currentPage: _currentPage, totalPages: _totalPages, onClose: _closeAndPop, onStartSearch: () => setState(() => _isSearching = true), onShowReaderActions: () => _dialogsManager.showReaderActions(context), onToggleTts: () => _ttsController.toggle(context, _currentPage, _pdfDocument, _ocrController.setOcrInProgress), isTtsActive: _ttsController.ttsActive, onStartOcr: widget.bookId != null ? () => _ocrController.startOcrBatch(context, _pdfDocument) : null, isOcrRunning: _ocrController.ocrBatchRunning, onToggleTextView: widget.bookId != null ? () { _textViewController.toggle(_currentPage, _totalPages); _textViewController.loadPage(context, _currentPage, _pdfDocument); } : null, isTextViewMode: _textViewController.textViewMode, isTextViewLoading: _textViewController.textViewMode && !_textViewController.pages.containsKey(_currentPage), onToggleBookmark: (p) => _bookmarkManager.toggleBookmark(p), onShowThumbnails: _totalPages > 0 && _pdfDocument != null ? () => showPageThumbnails(context, pdfDocument: _pdfDocument!, totalPages: _totalPages, currentPage: _currentPage, viewerController: _viewerController) : null);
    _dialogsManager = PdfViewDialogsManager(highlightManager: _highlightManager, bookmarkManager: _bookmarkManager, viewerController: _viewerController, ttsService: _ttsService, currentPage: _currentPage, pdfDocument: _pdfDocument, onShowToc: () => _dialogsManager.showToc(context), onShowHighlightsList: () => _highlightsUi.showHighlightsList(context: context, onPageSelected: (p) => _viewerController.goToPage(pageNumber: p + 1)), onPageSelected: (p) => _viewerController.goToPage(pageNumber: p + 1), onTtsSpeedChanged: () { if (_ttsController.ttsActive) _ttsController.speakCurrentPage(context, _currentPage, _pdfDocument, _ocrController.setOcrInProgress); }, onCycleReadingMode: () => setState(() => _readingMode = (_readingMode + 1) % 3), readingMode: _readingMode);
    _highlightsUi = PdfViewHighlightsUi(highlightManager: _highlightManager, viewerController: _viewerController, currentPage: _currentPage, onRefresh: () { if (mounted) setState(() {}); });

    return PopScope(canPop: false, onPopInvokedWithResult: (didPop, _) { if (!didPop) { if (_isSearching) { setState(() => _isSearching = false); _searchCtrl.clear(); _textSearcher?.resetTextSearch(); } else { _closeAndPop(); } } },
      child: Scaffold(
        appBar: _isSearching ? _uiBuilder.buildSearchBar(context: context, searchController: _searchCtrl, textSearcher: _textSearcher, onBackPressed: () { setState(() => _isSearching = false); _searchCtrl.clear(); _textSearcher?.resetTextSearch(); }, onSearchSubmitted: (q) { if (q.isNotEmpty) _textSearcher?.startTextSearch(q); }) : _uiBuilder.buildAppBar(context),
        floatingActionButton: _uiBuilder.buildHighlightsFAB(highlightManager: _highlightManager, currentPage: _currentPage, onPressed: () => _highlightsUi.showCurrentPageHighlights(context: context, currentPage: _currentPage)),
        body: Stack(children: [
          if (_textViewController.textViewMode) _textViewController.buildTextView(context, horizontalScroll: _horizontalScroll, totalPages: _totalPages, currentPage: _currentPage, onPageChanged: (p) { setState(() => _currentPage = p); _saveDebounce?.cancel(); _saveDebounce = Timer(const Duration(milliseconds: 500), _saveProgress); _textViewController.loadPage(context, p, _pdfDocument); })
          else PdfViewerBody(filePath: widget.filePath, viewerController: _viewerController, horizontalScroll: _horizontalScroll, readingMode: _readingMode, currentPage: _currentPage, highlightManager: _highlightManager, textSelectionManager: _textSelectionManager, highlightsUi: _highlightsUi, textSearcher: _textSearcher, isSearching: _isSearching, pdfError: _pdfError, initialPage: widget.initialPage, bookId: widget.bookId, onPageChanged: _onPageChanged, onViewerReady: (doc, ctrl) { _pdfDocument = doc; _textSearcher = PdfTextSearcher(_viewerController); _textSearcher!.addListener(() { if (mounted) setState(() {}); }); setState(() { _pdfLoading = false; _totalPages = doc.pages.length; if (_currentPage >= _totalPages) _currentPage = 0; }); if (widget.bookId != null && _bookService != null) _bookService!.saveProgress(widget.bookId!, _currentPage, totalPages: _totalPages); if (widget.initialPage > 0 && widget.initialPage < _totalPages) ctrl.goToPage(pageNumber: widget.initialPage + 1); if (_horizontalScroll) Future.delayed(const Duration(milliseconds: 100), () { if (!mounted) return; ctrl.goToPage(pageNumber: (widget.initialPage > 0 ? widget.initialPage : _currentPage) + 1); }); _highlightManager.preloadTextAroundCurrentPage(_currentPage, _pdfDocument); }, onSnapToPage: _snapToCurrentPage, findTappedHighlight: _findTappedHighlight),
          if (_pdfLoading && _pdfError == null && !_textViewController.textViewMode) const Center(child: CircularProgressIndicator()),
          if (_isSearching && _textSearcher != null) Positioned(bottom: 0, left: 0, right: 0, child: SearchResultsBar(textSearcher: _textSearcher!)),
          PdfOcrOverlay(ocrInProgress: _ocrController.ocrInProgress, ocrBatchRunning: _ocrController.ocrBatchRunning, ocrBatchDone: _ocrController.ocrBatchDone, ocrBatchTotal: _ocrController.ocrBatchTotal, onCancelBatch: _ocrController.cancelBatch),
        ]),
      ),
    );
  }
}
