import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import '../main.dart';
import '../l10n/app_strings.dart';
import '../utils/dialogs.dart';
import '../utils/pdf_render_utils.dart';
import 'pdf_highlight_manager.dart';

class PdfOcrController {
  final String? bookId;
  final PdfHighlightManager highlightManager;
  final VoidCallback onStateChanged;

  bool ocrInProgress = false;
  bool ocrBatchRunning = false;
  int ocrBatchTotal = 0;
  int ocrBatchDone = 0;

  PdfOcrController({
    required this.bookId,
    required this.highlightManager,
    required this.onStateChanged,
  });

  void setOcrInProgress(bool value) {
    ocrInProgress = value;
    onStateChanged();
  }

  Future<void> startOcrBatch(
    BuildContext context,
    PdfDocument? pdfDocument,
  ) async {
    if (pdfDocument == null || bookId == null || ocrBatchRunning) return;
    final ocrService = OcrServiceScope.of(context);
    final total = pdfDocument.pages.length;

    final pagesToOcr = <int>[];
    for (var i = 0; i < total; i++) {
      final pageNum = i + 1;
      if (!ocrService.hasOcrText(bookId!, pageNum)) {
        final cached = highlightManager.highlightTextCache.get(pageNum);
        if (cached == null || cached.fullText.trim().isEmpty) {
          pagesToOcr.add(i);
        }
      }
    }

    if (pagesToOcr.isEmpty) {
      showAppSnackBar(context, AppStrings.of(context).ocrAlreadyDone);
      return;
    }

    ocrBatchRunning = true;
    ocrBatchTotal = pagesToOcr.length;
    ocrBatchDone = 0;
    onStateChanged();

    for (final pageIndex in pagesToOcr) {
      if (!ocrBatchRunning) break;
      final pageNum = pageIndex + 1;

      try {
        final page = pdfDocument.pages[pageIndex];
        final pngBytes = await renderPageToPngBytes(page);
        if (pngBytes != null) {
          await ocrService.ocrFromPngBytes(
            bookId: bookId!,
            pageNumber: pageNum,
            pngBytes: pngBytes,
          );
        }
      } catch (e) {
        debugPrint('OCR batch error page $pageNum: $e');
      }

      ocrBatchDone++;
      onStateChanged();
      await Future.delayed(const Duration(milliseconds: 50));
    }

    ocrBatchRunning = false;
    onStateChanged();
    if (context.mounted) {
      showAppSnackBar(context, AppStrings.of(context).ocrComplete);
    }
  }

  void cancelBatch() {
    ocrBatchRunning = false;
    onStateChanged();
  }
}
