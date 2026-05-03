import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

/// Search-related UI functionality for PDF viewer.
class PdfViewSearchUi {
  /// Paints search matches on PDF pages.
  static void paintSearchMatches(
    ui.Canvas canvas,
    Rect pageRect,
    PdfPage page,
    PdfTextSearcher? textSearcher,
    bool isSearching,
  ) {
    if (textSearcher == null || !isSearching) return;
    final matches = textSearcher.matches;
    if (matches.isEmpty) return;

    final currentIdx = textSearcher.currentIndex;

    for (int mi = 0; mi < matches.length; mi++) {
      final match = matches[mi];
      if (match.pageNumber != page.pageNumber) continue;

      final isCurrent = mi == currentIdx;
      final paint = ui.Paint()
        ..color = isCurrent
            ? const Color(0xAAFF9800) // orange for current match
            : const Color(0x55FFEB3B); // light yellow for others

      // Use bounds from the match directly
      final b = match.bounds;
      final rect = Rect.fromLTRB(
        pageRect.left + b.left / page.width * pageRect.width,
        pageRect.top + (1 - b.top / page.height) * pageRect.height,
        pageRect.left + b.right / page.width * pageRect.width,
        pageRect.top + (1 - b.bottom / page.height) * pageRect.height,
      );
      canvas.drawRect(rect, paint);
    }
  }
}