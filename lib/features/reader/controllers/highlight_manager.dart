import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:uuid/uuid.dart';
import '../../../services/book_service.dart';
import '../../../models/highlight.dart';
import './text_cache.dart';
import '../widgets/highlight_color_picker.dart';

const _uuid = Uuid();

/// Manages highlight-related functionality for PDF viewer.
class PdfHighlightManager {
  BookService? bookService;
  final String? bookId;
  final PdfViewerController viewerController;
  final VoidCallback? onHighlightsUpdated;
  final TextCache highlightTextCache = TextCache(maxSize: 10);
  int currentHighlightColor = 0x80FFEB3B;

  PdfHighlightManager({
    required this.bookService, required this.bookId,
    required this.viewerController, this.onHighlightsUpdated,
  });

  void updateService(BookService? service) { bookService = service; }

  void paintHighlights(ui.Canvas canvas, Rect pageRect, PdfPage page, PdfDocument? pdfDocument) {
    if (bookId == null || bookService == null) return;
    final pageIndex = page.pageNumber - 1;
    final highlights = bookService!.getHighlightsForPage(bookId!, pageIndex);
    if (highlights.isEmpty) return;

    if (highlightTextCache.get(page.pageNumber) == null && pdfDocument != null) {
      _loadTextForHighlight(page.pageNumber, pdfDocument);
    }

    for (final h in highlights) {
      final paint = ui.Paint()..color = Color(h.colorValue);
      final text = highlightTextCache.get(page.pageNumber);
      if (text != null && h.startIndex >= 0 && h.endIndex <= text.charRects.length && h.startIndex < h.endIndex) {
        for (var i = h.startIndex; i < h.endIndex; i++) {
          final rect = text.charRects[i].toRectInDocument(page: page, pageRect: pageRect);
          switch (h.type) {
            case AnnotationType.underline:
              paint.strokeWidth = 2;
              canvas.drawLine(rect.bottomLeft, rect.bottomRight, paint);
            case AnnotationType.strikethrough:
              paint.strokeWidth = 2;
              final y = rect.top + rect.height / 2;
              canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), paint);
            case AnnotationType.highlight:
              canvas.drawRect(rect, paint);
          }
        }
      } else {
        final rect = Rect.fromLTRB(pageRect.left, pageRect.top + pageRect.height * 0.3, pageRect.right, pageRect.top + pageRect.height * 0.4);
        canvas.drawRect(rect, paint);
      }
    }
  }

  Future<void> _loadTextForHighlight(int pageNumber, PdfDocument pdfDocument) async {
    if (pageNumber < 1 || pageNumber > pdfDocument.pages.length) return;
    if (highlightTextCache.get(pageNumber) != null) return;
    final page = pdfDocument.pages[pageNumber - 1];
    if (!page.isLoaded) return;
    try {
      final text = await page.loadStructuredText();
      highlightTextCache.put(pageNumber, text);
      onHighlightsUpdated?.call();
    } catch (e) {
      highlightTextCache.put(pageNumber, null);
    }
  }

  void preloadTextAroundCurrentPage(int currentPage, PdfDocument? pdfDocument) {
    if (pdfDocument == null || currentPage < 0) return;
    final pn = currentPage + 1;
    final total = pdfDocument.pages.length;
    for (final p in [pn, pn - 1, pn + 1, pn - 2, pn + 2]) {
      if (p >= 1 && p <= total && highlightTextCache.get(p) == null) {
        _loadTextForHighlight(p, pdfDocument);
      }
    }
  }

  Future<void> createHighlightFromSelection(
    PdfPageTextRange range, String selectedText, VoidCallback? onSuccess,
    {String note = '', AnnotationType type = AnnotationType.highlight}
  ) async {
    if (bookId == null || bookService == null) return;
    final highlight = Highlight(
      id: _uuid.v4(), page: range.pageNumber - 1,
      startIndex: range.start, endIndex: range.end,
      text: selectedText, colorValue: currentHighlightColor,
      note: note, createdAt: DateTime.now(), type: type,
    );
    try {
      await bookService!.addHighlight(bookId!, highlight);
      HapticFeedback.mediumImpact();
      onSuccess?.call();
    } catch (error) {
      debugPrint('createHighlight: ERROR - $error');
      rethrow;
    }
  }

  Future<void> editHighlightNote(BuildContext context, Highlight highlight, String newNote) async {
    if (bookId == null || bookService == null) return;
    await bookService!.updateHighlightNote(bookId!, highlight.id, newNote);
  }

  Future<void> changeHighlightColor(BuildContext context, Highlight highlight, int newColor) async {
    if (bookId == null || bookService == null) return;
    await bookService!.updateHighlightColor(bookId!, highlight.id, newColor);
  }

  Future<void> deleteHighlight(BuildContext context, Highlight highlight) async {
    if (bookId == null || bookService == null) return;
    await bookService!.removeHighlight(bookId!, highlight.id);
  }

  List<Highlight> getHighlightsForCurrentPage(int currentPage) {
    if (bookId == null || bookService == null) return [];
    final book = bookService!.getById(bookId!);
    return book?.highlights.where((h) => h.page == currentPage).toList() ?? [];
  }

  List<Highlight> getAllHighlights() {
    if (bookId == null || bookService == null) return [];
    final book = bookService!.getById(bookId!);
    return book?.highlights ?? [];
  }

  void showColorPicker(BuildContext context, {required ValueChanged<int> onColorSelected}) {
    showHighlightColorPicker(context, currentColor: currentHighlightColor, onColorSelected: onColorSelected);
  }
}
