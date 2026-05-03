import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import '../services/book_service.dart';
import '../services/reading_log_service.dart';
import '../main.dart';
import '../models/highlight.dart';
import '../utils/velocity_aware_scroll_physics.dart';
import 'widgets/search_results_bar.dart';
import 'pdf_highlight_manager.dart';
import 'pdf_bookmark_manager.dart';
import 'pdf_text_selection_manager.dart';
import 'pdf_view_ui_builder.dart';
import 'pdf_view_dialogs_manager.dart';
import 'pdf_view_highlights_ui.dart';
import 'pdf_view_search_ui.dart';
import '../services/tts_service.dart';

class PdfViewScreen extends StatefulWidget {
  final String filePath;
  final String fileName;
  final String? bookId;
  final int initialPage;

  const PdfViewScreen({
    super.key,
    required this.filePath,
    required this.fileName,
    this.bookId,
    this.initialPage = 0,
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
  
  // Managers
  late PdfHighlightManager _highlightManager;
  late PdfBookmarkManager _bookmarkManager;
  late PdfTextSelectionManager _textSelectionManager;
  
  // New UI Managers
  late PdfViewUiBuilder _uiBuilder;
  late PdfViewDialogsManager _dialogsManager;
  late PdfViewHighlightsUi _highlightsUi;

  int _totalPages = 0;
  int _currentPage = 0;
  bool _closed = false;
  bool _isSearching = false;
  bool _ttsActive = false;

  Timer? _saveDebounce;
  int _sessionSeconds = 0;
  int _sessionStartPage = 0;
  Timer? _readingTimer;

  final TextEditingController _searchCtrl = TextEditingController();
  PdfTextSearcher? _textSearcher;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _sessionStartPage = widget.initialPage;
    
    // Initialize managers
    _highlightManager = PdfHighlightManager(
      bookService: _bookService,
      bookId: widget.bookId,
      viewerController: _viewerController,
      onHighlightsUpdated: () {
        if (mounted) setState(() {});
      },
    );
    
    _bookmarkManager = PdfBookmarkManager(
      bookService: _bookService,
      bookId: widget.bookId,
      onBookmarksUpdated: () {
        if (mounted) setState(() {});
      },
    );
    
    _textSelectionManager = PdfTextSelectionManager(
      highlightManager: _highlightManager,
      onHighlightCreated: () {
        if (mounted) setState(() {});
      },
    );
    
    _readingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _sessionSeconds++;
    });
  }

  // ── TTS ──
  TtsService get _ttsService => TtsServiceScope.of(context);
  bool _ttsPageAdvancing = false;

  void _onTtsStateChanged() {
    if (!mounted || !_ttsActive) return;
    // Page finished → auto advance
    if (_ttsService.isStopped && _ttsService.currentText == null) {
      if (_currentPage + 1 < _totalPages) {
        _ttsPageAdvancing = true;
        _viewerController.goToPage(pageNumber: _currentPage + 2);
        Future.delayed(const Duration(milliseconds: 500), () {
          _ttsPageAdvancing = false;
          if (mounted && _ttsActive) _speakCurrentPage();
        });
      } else {
        setState(() => _ttsActive = false);
      }
    }
    if (mounted) setState(() {});
  }

  Future<void> _speakCurrentPage() async {
    final pageNumber = _currentPage + 1;
    if (_highlightManager.highlightTextCache.get(pageNumber) == null && _pdfDocument != null) {
      if (pageNumber >= 1 && pageNumber <= _pdfDocument!.pages.length) {
        try {
          final text = await _pdfDocument!.pages[pageNumber - 1].loadStructuredText();
          _highlightManager.highlightTextCache.put(pageNumber, text);
        } catch (_) {}
      }
    }
    final cached = _highlightManager.highlightTextCache.get(pageNumber);
    final text = cached?.fullText;
    if (text != null && text.trim().isNotEmpty) {
      _ttsService.speak(text);
    }
  }

  void _toggleTts() {
    if (_ttsActive) {
      _ttsService.stop();
      setState(() => _ttsActive = false);
    } else {
      setState(() => _ttsActive = true);
      _speakCurrentPage();
    }
  }

  bool _ttsListenerAdded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_ttsListenerAdded) {
      _ttsListenerAdded = true;
      _ttsService.addListener(_onTtsStateChanged);
    }
    if (widget.bookId != null) {
      _bookService = BookServiceScope.of(context);
      _readingLogService = ReadingLogServiceScope.of(context);
      
      // Update managers with services
      _highlightManager = PdfHighlightManager(
        bookService: _bookService,
        bookId: widget.bookId,
        viewerController: _viewerController,
        onHighlightsUpdated: () {
          if (mounted) setState(() {});
        },
      );
      
      _bookmarkManager = PdfBookmarkManager(
        bookService: _bookService,
        bookId: widget.bookId,
        onBookmarksUpdated: () {
          if (mounted) setState(() {});
        },
      );
      
      _textSelectionManager = PdfTextSelectionManager(
        highlightManager: _highlightManager,
        onHighlightCreated: () {
          if (mounted) setState(() {});
        },
      );
      
      // Reinitialize UI managers with updated services
      _initializeUiManagers();
    }
    try {
      _horizontalScroll = SettingsScope.of(context).isHorizontalScroll;
    } catch (_) {}
  }

  void _initializeUiManagers() {
    _uiBuilder = PdfViewUiBuilder(
      bookmarkManager: _bookmarkManager,
      fileName: widget.fileName,
      currentPage: _currentPage,
      totalPages: _totalPages,
      onClose: _closeAndPop,
      onStartSearch: _startSearch,
      onShowReaderActions: _showReaderActions,
      onToggleTts: _toggleTts,
      isTtsActive: _ttsActive,
      onToggleBookmark: (page) => _bookmarkManager.toggleBookmark(page),
    );
    
    _dialogsManager = PdfViewDialogsManager(
      highlightManager: _highlightManager,
      bookmarkManager: _bookmarkManager,
      viewerController: _viewerController,
      ttsService: _ttsService,
      currentPage: _currentPage,
      pdfDocument: _pdfDocument,
      onShowToc: _showToc,
      onShowHighlightsList: _showHighlightsList,
      onPageSelected: (page) => _viewerController.goToPage(pageNumber: page + 1),
      onTtsSpeedChanged: () {
        if (_ttsActive) _speakCurrentPage();
      },
    );
    
    _highlightsUi = PdfViewHighlightsUi(
      highlightManager: _highlightManager,
      viewerController: _viewerController,
      currentPage: _currentPage,
      onRefresh: () {
        if (mounted) setState(() {});
      },
    );
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
    _debouncedSaveProgress();
    _highlightManager.preloadTextAroundCurrentPage(_currentPage, _pdfDocument);
    
    // User manually changed page while TTS active → restart from new page
    if (_ttsActive && _ttsService.isPlaying && !_ttsPageAdvancing) {
      _ttsService.stop();
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && _ttsActive) _speakCurrentPage();
      });
    }
  }

  void _debouncedSaveProgress() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 500), _saveProgress);
  }

  void _saveProgress() {
    if (widget.bookId == null || _bookService == null) return;
    final flushSec = _flushSessionSeconds();
    _bookService!.saveProgress(widget.bookId!, _currentPage,
        totalPages: _totalPages, addSeconds: flushSec);
    // Log daily reading
    final pagesRead = (_currentPage - _sessionStartPage).abs();
    _sessionStartPage = _currentPage;
    _readingLogService?.logReading(seconds: flushSec, pages: pagesRead);
  }

  int _flushSessionSeconds() {
    final s = _sessionSeconds;
    _sessionSeconds = 0;
    return s;
  }

  void _startSearch() {
    setState(() => _isSearching = true);
  }

  void _doSearch(String query) {
    if (query.isEmpty) return;
    _textSearcher?.startTextSearch(query);
  }

  void _showReaderActions() {
    _dialogsManager.showReaderActions(context);
  }

  void _showToc() {
    _dialogsManager.showToc(context);
  }

  void _showHighlightsList() {
    _highlightsUi.showHighlightsList(
      context: context,
      onPageSelected: (page) => _viewerController.goToPage(pageNumber: page + 1),
    );
  }

  void _showCurrentPageHighlights() {
    _highlightsUi.showCurrentPageHighlights(
      context: context,
      currentPage: _currentPage,
    );
  }

  void _closeAndPop() {
    if (_closed) return;
    _closed = true;
    _saveDebounce?.cancel();
    _readingTimer?.cancel();
    _saveProgress();
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    _readingTimer?.cancel();
    _searchCtrl.dispose();
    _textSearcher?.dispose();
    _ttsService.removeListener(_onTtsStateChanged);
    if (!_closed) _saveProgress();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild UI builder với giá trị mới nhất
    _uiBuilder = PdfViewUiBuilder(
      bookmarkManager: _bookmarkManager,
      fileName: widget.fileName,
      currentPage: _currentPage,
      totalPages: _totalPages,
      onClose: _closeAndPop,
      onStartSearch: _startSearch,
      onShowReaderActions: _showReaderActions,
      onToggleTts: _toggleTts,
      isTtsActive: _ttsActive,
      onToggleBookmark: (page) => _bookmarkManager.toggleBookmark(page),
    );

    _dialogsManager = PdfViewDialogsManager(
      highlightManager: _highlightManager,
      bookmarkManager: _bookmarkManager,
      viewerController: _viewerController,
      ttsService: _ttsService,
      currentPage: _currentPage,
      pdfDocument: _pdfDocument,
      onShowToc: _showToc,
      onShowHighlightsList: _showHighlightsList,
      onPageSelected: (page) => _viewerController.goToPage(pageNumber: page + 1),
      onTtsSpeedChanged: () {
        if (_ttsActive) _speakCurrentPage();
      },
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          if (_isSearching) {
            setState(() => _isSearching = false);
            _searchCtrl.clear();
            _textSearcher?.resetTextSearch();
          } else {
            _closeAndPop();
          }
        }
      },
      child: Scaffold(
        appBar: _isSearching 
            ? _uiBuilder.buildSearchBar(
                context: context,
                searchController: _searchCtrl,
                textSearcher: _textSearcher,
                onBackPressed: () {
                  setState(() => _isSearching = false);
                  _searchCtrl.clear();
                  _textSearcher?.resetTextSearch();
                },
                onSearchSubmitted: _doSearch,
              )
            : _uiBuilder.buildAppBar(context),
        floatingActionButton: _uiBuilder.buildHighlightsFAB(
          highlightManager: _highlightManager,
          currentPage: _currentPage,
          onPressed: _showCurrentPageHighlights,
        ),
        body: Stack(
          children: [
            PdfViewer.file(
                  widget.filePath,
                  controller: _viewerController,
                  params: PdfViewerParams(
                    layoutPages: _horizontalScroll ? _horizontalLayout : null,
                    panAxis: _horizontalScroll ? PanAxis.horizontal : PanAxis.free,
                    pageAnchor: _horizontalScroll ? PdfPageAnchor.all : PdfPageAnchor.top,
                    scrollByMouseWheel: _horizontalScroll ? 1.0 : 0.2,
                    onPageChanged: (page) {
                      if (page == null) return;
                      final zeroIndexed = page - 1;
                      if (zeroIndexed != _currentPage) {
                        _onPageChanged(zeroIndexed);
                      }
                    },
                    pagePaintCallbacks: [
                      (canvas, rect, page) => _highlightManager.paintHighlights(canvas, rect, page, _pdfDocument),
                      (canvas, rect, page) => PdfViewSearchUi.paintSearchMatches(canvas, rect, page, _textSearcher, _isSearching),
                    ],
                    // Enable text selection with default parameters
                    textSelectionParams: const PdfTextSelectionParams(
                      enabled: true,
                      magnifier: PdfViewerSelectionMagnifierParams(
                        enabled: true,
                      ),
                    ),
                    // Add highlight option to context menu
                    customizeContextMenuItems: (params, items) {
                      if (params.contextMenuFor == PdfViewerPart.selectedText &&
                          params.textSelectionDelegate.hasSelectedText) {
                        items.add(_textSelectionManager.buildHighlightButton(context, params));
                      }
                    },
                    // Tap on highlight to edit
                    onGeneralTap: (context, controller, details) {
                      if (details.type != PdfViewerGeneralTapType.tap) return false;
                      final hit = controller.getPdfPageHitTestResult(
                        details.documentPosition,
                        useDocumentLayoutCoordinates: true,
                      );
                      if (hit == null) return false;
                      final tapped = _findTappedHighlight(hit);
                      if (tapped == null) return false;
                      _highlightsUi.showEditMenuForHighlight(
                        context: this.context,
                        highlight: tapped,
                      );
                      return true;
                    },
                    onViewerReady: (document, controller) {
                      _pdfDocument = document;
                      _textSearcher = PdfTextSearcher(_viewerController);
                      _textSearcher!.addListener(() {
                        if (mounted) setState(() {}); // repaint search highlights
                      });
                      setState(() {
                        _totalPages = document.pages.length;
                        if (_currentPage >= _totalPages) _currentPage = 0;
                      });
                      if (widget.bookId != null && _bookService != null) {
                        _bookService!.saveProgress(widget.bookId!, _currentPage,
                            totalPages: _totalPages);
                      }
                      if (widget.initialPage > 0 &&
                          widget.initialPage < _totalPages) {
                        controller.goToPage(pageNumber: widget.initialPage + 1);
                      }
                      // Center page đầu tiên khi cuộn ngang
                      if (_horizontalScroll) {
                        Future.delayed(const Duration(milliseconds: 100), () {
                          if (!mounted) return;
                          controller.goToPage(
                            pageNumber: (widget.initialPage > 0 ? widget.initialPage : _currentPage) + 1,
                          );
                        });
                      }
                      // Preload text for initial page and surrounding pages
                      _highlightManager.preloadTextAroundCurrentPage(_currentPage, _pdfDocument);
                      
                    },
                    // Velocity-aware scroll physics: tăng tốc scroll & fling
                    scrollPhysics: VelocityAwareScrollPhysics(
                      velocityMultiplier: _horizontalScroll ? 1.8 : 1.5,
                      flingMultiplier: _horizontalScroll ? 2.5 : 2.0,
                    ),
                    // Snap to page khi cuộn ngang
                    onInteractionEnd: _horizontalScroll
                        ? (_) => _snapToCurrentPage()
                        : null,
                  ),
                ),
            // Search results overlay
            if (_isSearching && _textSearcher != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SearchResultsBar(textSearcher: _textSearcher!),
              ),
          ],
        ),
      ),
    );
  }

  Highlight? _findTappedHighlight(PdfPageHitTestResult hit) {
    final pageIndex = hit.page.pageNumber - 1;
    final highlights = _highlightManager.getHighlightsForCurrentPage(pageIndex);
    if (highlights.isEmpty) return null;

    final text = _highlightManager.highlightTextCache.get(hit.page.pageNumber);
    if (text == null) return null;

    for (final h in highlights) {
      if (h.startIndex < 0 || h.endIndex > text.charRects.length) continue;
      for (var i = h.startIndex; i < h.endIndex; i++) {
        if (text.charRects[i].containsPoint(hit.offset)) {
          return h;
        }
      }
    }
    return null;
  }

  void _snapToCurrentPage() {
    // Đợi fling animation settle rồi snap
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted || !_horizontalScroll) return;
      final pageNumber = _viewerController.pageNumber;
      if (pageNumber != null && pageNumber > 0) {
        _viewerController.goToPage(
          pageNumber: pageNumber,
          duration: const Duration(milliseconds: 200),
        );
      }
    });
  }

  static PdfPageLayout _horizontalLayout(
      List<PdfPage> pages, PdfViewerParams params) {
    final margin = params.margin;
    final height = pages.fold<double>(
            0.0, (prev, page) => prev > page.height ? prev : page.height) +
        margin * 2;
    final pageLayouts = <Rect>[];
    double x = margin;
    for (final page in pages) {
      pageLayouts.add(Rect.fromLTWH(
        x,
        (height - page.height) / 2,
        page.width,
        page.height,
      ));
      x += page.width + margin;
    }
    return PdfPageLayout(
        pageLayouts: pageLayouts, documentSize: Size(x, height));
  }
}