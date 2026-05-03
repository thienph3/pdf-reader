import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:uuid/uuid.dart';
import '../services/book_service.dart';
import '../models/highlight.dart';

const _uuid = Uuid();

/// Manages highlight-related functionality for PDF viewer.
class PdfHighlightManager {
  final BookService? bookService;
  final String? bookId;
  final PdfViewerController viewerController;
  final VoidCallback? onHighlightsUpdated;

  /// LRU cache for PDF page text to improve highlight drawing performance.
  final TextCache highlightTextCache = TextCache(maxSize: 10);

  static const _highlightColors = [
    0x80FFEB3B, // yellow
    0x8066BB6A, // green
    0x8042A5F5, // blue
    0x80EF5350, // red
    0x80AB47BC, // purple
    0x80FF7043, // orange
  ];

  int currentHighlightColor = 0x80FFEB3B; // Default yellow

  PdfHighlightManager({
    required this.bookService,
    required this.bookId,
    required this.viewerController,
    this.onHighlightsUpdated,
  });

  /// Paints highlights on a PDF page.
  void paintHighlights(ui.Canvas canvas, Rect pageRect, PdfPage page, PdfDocument? pdfDocument) {
    if (bookId == null || bookService == null) return;
    
    final pageIndex = page.pageNumber - 1;
    final highlights = bookService!.getHighlightsForPage(bookId!, pageIndex);
    if (highlights.isEmpty) return;

    // Cache for text per page to avoid loading multiple times
    if (highlightTextCache.get(page.pageNumber) == null && pdfDocument != null) {
      _loadTextForHighlight(page.pageNumber, pdfDocument);
    }

    // Draw highlights (either approximate or precise)
    for (final h in highlights) {
      final paint = ui.Paint()..color = Color(h.colorValue);
      
      // Try to get precise highlight position if text is loaded
      final text = highlightTextCache.get(page.pageNumber);
      if (text != null && h.startIndex >= 0 && h.endIndex <= text.charRects.length && h.startIndex < h.endIndex) {
        // Draw precise highlight using text character rectangles
        for (var i = h.startIndex; i < h.endIndex; i++) {
          final charRect = text.charRects[i];
          final rect = charRect.toRectInDocument(page: page, pageRect: pageRect);
          canvas.drawRect(rect, paint);
        }
      } else {
        // Draw approximate highlight rectangle
        final rect = Rect.fromLTRB(
          pageRect.left,
          pageRect.top + pageRect.height * 0.3,
          pageRect.right,
          pageRect.top + pageRect.height * 0.4,
        );
        canvas.drawRect(rect, paint);
      }
    }
  }

  /// Loads text for a specific page for highlight drawing.
  Future<void> _loadTextForHighlight(int pageNumber, PdfDocument pdfDocument) async {
    if (pageNumber < 1 || pageNumber > pdfDocument.pages.length) return;
    
    // Check if text is already in cache
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

  /// Preloads text for pages around the current page to improve performance.
  void preloadTextAroundCurrentPage(int currentPage, PdfDocument? pdfDocument) {
    if (pdfDocument == null || currentPage < 0) return;
    
    final currentPageNumber = currentPage + 1; // Convert to 1-based
    final totalPages = pdfDocument.pages.length;
    
    // Preload current page and surrounding pages
    final pagesToPreload = <int>[
      currentPageNumber,
      currentPageNumber - 1,
      currentPageNumber + 1,
      currentPageNumber - 2,
      currentPageNumber + 2,
    ];
    
    for (final pageNumber in pagesToPreload) {
      if (pageNumber >= 1 && pageNumber <= totalPages) {
        if (highlightTextCache.get(pageNumber) == null) {
          _loadTextForHighlight(pageNumber, pdfDocument);
        }
      }
    }
  }

  /// Creates a highlight from text selection.
  Future<void> createHighlightFromSelection(
    BuildContext context,
    PdfPageTextRange range,
    String selectedText,
    VoidCallback? onSuccess,
  ) async {
    if (bookId == null || bookService == null) return;
    
    // Create a new highlight
    final highlight = Highlight(
      id: _uuid.v4(),
      page: range.pageNumber - 1, // Convert to 0-based index
      startIndex: range.start,
      endIndex: range.end,
      text: selectedText,
      colorValue: currentHighlightColor,
      createdAt: DateTime.now(),
    );
    
    // Add highlight to book
    try {
      await bookService!.addHighlight(bookId!, highlight);
      onSuccess?.call();
    } catch (error) {
      rethrow;
    }
  }

  /// Edits the note of a highlight.
  Future<void> editHighlightNote(
    BuildContext context,
    Highlight highlight,
    String newNote,
  ) async {
    if (bookId == null || bookService == null) return;
    
    await bookService!.updateHighlightNote(
      bookId!,
      highlight.id,
      newNote,
    );
  }

  /// Changes the color of a highlight.
  Future<void> changeHighlightColor(
    BuildContext context,
    Highlight highlight,
    int newColor,
  ) async {
    if (bookId == null || bookService == null) return;
    
    // Create updated highlight with new color
    final updatedHighlight = highlight.copyWith(colorValue: newColor);
    
    // Remove old highlight and add new one
    await bookService!.removeHighlight(bookId!, highlight.id);
    await bookService!.addHighlight(bookId!, updatedHighlight);
  }

  /// Deletes a highlight.
  Future<void> deleteHighlight(
    BuildContext context,
    Highlight highlight,
  ) async {
    if (bookId == null || bookService == null) return;
    
    await bookService!.removeHighlight(bookId!, highlight.id);
  }

  /// Gets highlights for the current page.
  List<Highlight> getHighlightsForCurrentPage(int currentPage) {
    if (bookId == null || bookService == null) return [];
    
    final book = bookService!.getById(bookId!);
    if (book == null) return [];
    
    return book.highlights
        .where((h) => h.page == currentPage)
        .toList();
  }

  /// Gets all highlights for the book.
  List<Highlight> getAllHighlights() {
    if (bookId == null || bookService == null) return [];
    
    final book = bookService!.getById(bookId!);
    if (book == null) return [];
    
    return book.highlights;
  }

  /// Shows a color picker dialog for highlight colors.
  void showColorPicker(BuildContext context, {required ValueChanged<int> onColorSelected}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Highlight Color'),
        content: SizedBox(
          width: 300,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _highlightColors.map((color) {
              return GestureDetector(
                onTap: () {
                  onColorSelected(color);
                  Navigator.pop(ctx);
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(color),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: currentHighlightColor == color 
                        ? Theme.of(context).colorScheme.primary 
                        : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

/// Simple LRU (Least Recently Used) cache for PDF page text.
class TextCache {
  final int maxSize;
  final Map<int, PdfPageText?> _cache = {};
  final List<int> _accessOrder = [];

  TextCache({this.maxSize = 20});

  PdfPageText? get(int pageNumber) {
    if (_cache.containsKey(pageNumber)) {
      // Update access order
      _accessOrder.remove(pageNumber);
      _accessOrder.add(pageNumber);
      return _cache[pageNumber];
    }
    return null;
  }

  void put(int pageNumber, PdfPageText? text) {
    if (_cache.containsKey(pageNumber)) {
      // Update existing entry
      _cache[pageNumber] = text;
      _accessOrder.remove(pageNumber);
      _accessOrder.add(pageNumber);
    } else {
      // Add new entry
      if (_cache.length >= maxSize) {
        // Remove least recently used item
        final lruKey = _accessOrder.first;
        _cache.remove(lruKey);
        _accessOrder.remove(lruKey);
      }
      _cache[pageNumber] = text;
      _accessOrder.add(pageNumber);
    }
  }

  void clear() {
    _cache.clear();
    _accessOrder.clear();
  }

  bool containsKey(int pageNumber) => _cache.containsKey(pageNumber);

  void remove(int pageNumber) {
    _cache.remove(pageNumber);
    _accessOrder.remove(pageNumber);
  }
}