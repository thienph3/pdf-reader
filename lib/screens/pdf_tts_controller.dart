import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import '../main.dart';
import '../services/tts_service.dart';
import '../utils/pdf_render_utils.dart';
import 'pdf_highlight_manager.dart';

class PdfTtsController {
  final TtsService ttsService;
  final PdfHighlightManager highlightManager;
  final PdfViewerController viewerController;
  final String? bookId;
  final VoidCallback onStateChanged;

  bool ttsActive = false;
  bool _ttsPageAdvancing = false;

  PdfTtsController({
    required this.ttsService,
    required this.highlightManager,
    required this.viewerController,
    required this.bookId,
    required this.onStateChanged,
  });

  void onTtsStateChanged(int currentPage, int totalPages) {
    if (!ttsActive) return;
    if (ttsService.isStopped && ttsService.currentText == null) {
      if (currentPage + 1 < totalPages) {
        _ttsPageAdvancing = true;
        final targetPage = currentPage + 1;
        viewerController.goToPage(pageNumber: targetPage + 1);
        Future.delayed(const Duration(milliseconds: 500), () {
          _ttsPageAdvancing = false;
        });
      } else {
        ttsActive = false;
      }
    }
    onStateChanged();
  }

  bool get isPageAdvancing => _ttsPageAdvancing;

  Future<void> speakCurrentPage(
    BuildContext context,
    int currentPage,
    PdfDocument? pdfDocument,
    void Function(bool) setOcrInProgress,
  ) async {
    final pageNumber = currentPage + 1;
    if (highlightManager.highlightTextCache.get(pageNumber) == null && pdfDocument != null) {
      if (pageNumber >= 1 && pageNumber <= pdfDocument.pages.length) {
        try {
          final text = await pdfDocument.pages[pageNumber - 1].loadStructuredText();
          highlightManager.highlightTextCache.put(pageNumber, text);
        } catch (_) {}
      }
    }
    final cached = highlightManager.highlightTextCache.get(pageNumber);
    var text = cached?.fullText;

    if ((text == null || text.trim().isEmpty) && bookId != null) {
      final ocrService = OcrServiceScope.of(context);
      text = ocrService.getCachedText(bookId!, pageNumber);
      if (text == null || text.trim().isEmpty) {
        if (pdfDocument != null && pageNumber <= pdfDocument.pages.length) {
          setOcrInProgress(true);
          try {
            final page = pdfDocument.pages[pageNumber - 1];
            final pngBytes = await renderPageToPngBytes(page);
            if (pngBytes != null) {
              text = await ocrService.ocrFromPngBytes(
                bookId: bookId!,
                pageNumber: pageNumber,
                pngBytes: pngBytes,
              );
            }
          } catch (e) {
            debugPrint('OCR for TTS failed: $e');
          } finally {
            setOcrInProgress(false);
          }
        }
      }
    }

    if (text != null && text.trim().isNotEmpty) {
      ttsService.speak(text);
    }
  }

  void toggle(BuildContext context, int currentPage, PdfDocument? pdfDocument,
      void Function(bool) setOcrInProgress) {
    if (ttsActive) {
      ttsService.stop();
      ttsActive = false;
    } else {
      ttsActive = true;
      speakCurrentPage(context, currentPage, pdfDocument, setOcrInProgress);
    }
    onStateChanged();
  }

  void onPageChangedWhileTts(BuildContext context, int currentPage,
      PdfDocument? pdfDocument, void Function(bool) setOcrInProgress) {
    if (ttsActive && ttsService.isPlaying && !_ttsPageAdvancing) {
      ttsService.stop();
      Future.delayed(const Duration(milliseconds: 300), () {
        if (ttsActive) {
          speakCurrentPage(context, currentPage, pdfDocument, setOcrInProgress);
        }
      });
    }
  }
}
