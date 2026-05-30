import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import '../../../core/utils/pdf_render_utils.dart';
import '../controllers/highlight_manager.dart';
import '../controllers/bookmark_manager.dart';
import '../controllers/text_selection_manager.dart';
import '../controllers/highlights_ui.dart';
import '../controllers/tts_controller.dart';
import '../controllers/ocr_controller.dart';
import '../controllers/text_view_controller.dart';
import '../widgets/pdf_viewer_body.dart';
import '../../../models/highlight.dart';
import '../../../services/book_service.dart';
import 'content_provider.dart';

/// PDF implementation of [ContentProvider].
class PdfContentProvider extends ContentProvider {
  final String filePath;
  final String? bookId;
  final PdfViewerController viewerController = PdfViewerController();

  PdfDocument? pdfDocument;
  PdfTextSearcher? textSearcher;
  late PdfHighlightManager highlightManager;
  late PdfBookmarkManager bookmarkManager;
  late PdfTextSelectionManager textSelectionManager;
  late PdfTtsController ttsController;
  late PdfOcrController ocrController;
  late PdfTextViewController textViewController;
  late PdfViewHighlightsUi highlightsUi;

  int _totalPages = 0;
  bool _loading = true;
  String? _error;

  @override
  int get totalPages => _totalPages;
  @override
  bool get isLoading => _loading;
  @override
  String? get error => _error;

  PdfContentProvider({required this.filePath, this.bookId}) {
    if (!io.File(filePath).existsSync()) _error = 'File not found';
  }

  void initControllers({
    required BookService? bookService,
    required VoidCallback onStateChanged,
  }) {
    highlightManager = PdfHighlightManager(
      bookService: bookService, bookId: bookId,
      viewerController: viewerController,
      onHighlightsUpdated: onStateChanged,
    );
    bookmarkManager = PdfBookmarkManager(
      bookService: bookService, bookId: bookId,
      onBookmarksUpdated: onStateChanged,
    );
    textSelectionManager = PdfTextSelectionManager(
      highlightManager: highlightManager,
      onHighlightCreated: onStateChanged,
    );
    ocrController = PdfOcrController(
      bookId: bookId, highlightManager: highlightManager,
      onStateChanged: onStateChanged,
    );
    textViewController = PdfTextViewController(
      bookId: bookId, highlightManager: highlightManager,
      onStateChanged: onStateChanged,
    );
    highlightsUi = PdfViewHighlightsUi(
      highlightManager: highlightManager,
      viewerController: viewerController,
      currentPage: 0, onRefresh: onStateChanged,
    );
  }

  void onViewerReady(PdfDocument doc, PdfViewerController ctrl) {
    pdfDocument = doc;
    textSearcher = PdfTextSearcher(viewerController);
    _loading = false;
    _totalPages = doc.pages.length;
  }

  @override
  Future<String?> getTextForPage(int page) async {
    final pageNumber = page + 1;
    // Try text layer
    if (highlightManager.highlightTextCache.get(pageNumber) == null &&
        pdfDocument != null && pageNumber <= pdfDocument!.pages.length) {
      try {
        final text = await pdfDocument!.pages[pageNumber - 1]
            .loadStructuredText();
        highlightManager.highlightTextCache.put(pageNumber, text);
      } catch (_) {}
    }
    final cached = highlightManager.highlightTextCache.get(pageNumber);
    var text = cached?.fullText;
    if (text != null && text.trim().isNotEmpty) return text;

    // OCR fallback
    if (bookId != null && pdfDocument != null &&
        pageNumber <= pdfDocument!.pages.length) {
      final page = pdfDocument!.pages[pageNumber - 1];
      final pngBytes = await renderPageToPngBytes(page);
      if (pngBytes != null) return null; // OCR handled externally
    }
    return text;
  }

  Highlight? findTappedHighlight(PdfPageHitTestResult hit) {
    final highlights = highlightManager
        .getHighlightsForCurrentPage(hit.page.pageNumber - 1);
    if (highlights.isEmpty) return null;
    final text = highlightManager.highlightTextCache
        .get(hit.page.pageNumber);
    if (text == null) return null;
    for (final h in highlights) {
      if (h.startIndex < 0 || h.endIndex > text.charRects.length) continue;
      for (var i = h.startIndex; i < h.endIndex; i++) {
        if (text.charRects[i].containsPoint(hit.offset)) return h;
      }
    }
    return null;
  }

  @override
  Widget buildContent(BuildContext context, {
    required int currentPage,
    required ValueChanged<int> onPageChanged,
    required VoidCallback onReady,
    bool horizontalScroll = false,
    int readingMode = 0,
    int cropMargins = 0,
    bool isSearching = false,
    int initialPage = 0,
    VoidCallback? onSnapToPage,
    VoidCallback? onCenterTap,
  }) {
    highlightsUi = PdfViewHighlightsUi(
      highlightManager: highlightManager,
      viewerController: viewerController,
      currentPage: currentPage, onRefresh: onReady,
    );

    final body = PdfViewerBody(
      filePath: filePath,
      viewerController: viewerController,
      horizontalScroll: horizontalScroll,
      readingMode: readingMode,
      currentPage: currentPage,
      highlightManager: highlightManager,
      textSelectionManager: textSelectionManager,
      highlightsUi: highlightsUi,
      textSearcher: textSearcher,
      isSearching: isSearching,
      pdfError: _error,
      initialPage: initialPage,
      bookId: bookId,
      onPageChanged: onPageChanged,
      onViewerReady: (doc, ctrl) {
        onViewerReady(doc, ctrl);
        onReady();
      },
      onSnapToPage: onSnapToPage ?? () {},
      findTappedHighlight: findTappedHighlight,
      onCenterTap: onCenterTap,
    );

    if (cropMargins > 0) {
      return ClipRect(
        child: Transform.scale(
          scale: 1.0 + cropMargins / 100.0,
          child: body,
        ),
      );
    }
    return body;
  }

  @override
  void dispose() {
    textSearcher?.dispose();
  }
}
