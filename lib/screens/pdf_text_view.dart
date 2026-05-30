import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:pdfrx/pdfrx.dart';
import '../main.dart';
import '../l10n/app_strings.dart';
import '../utils/pdf_render_utils.dart';
import 'pdf_highlight_manager.dart';

class PdfTextViewController {
  final String? bookId;
  final PdfHighlightManager highlightManager;
  final VoidCallback onStateChanged;

  bool textViewMode = false;
  late PageController pageController;
  final Map<int, String?> pages = {};

  PdfTextViewController({
    required this.bookId,
    required this.highlightManager,
    required this.onStateChanged,
  });

  void toggle(int currentPage, int totalPages) {
    if (textViewMode) {
      textViewMode = false;
    } else {
      pages.clear();
      pageController = PageController(initialPage: currentPage);
      textViewMode = true;
    }
    onStateChanged();
  }

  Future<void> loadPage(
    BuildContext context,
    int page,
    PdfDocument? pdfDocument,
  ) async {
    if (pages.containsKey(page)) return;
    if (pdfDocument == null || bookId == null) return;

    final pageNumber = page + 1;
    final ocrService = OcrServiceScope.of(context);

    var md = ocrService.getCachedMarkdown(bookId!, pageNumber);
    if (md != null) {
      pages[page] = md;
      onStateChanged();
      return;
    }

    final cached = highlightManager.highlightTextCache.get(pageNumber);
    if (cached != null && cached.fullText.trim().isNotEmpty) {
      pages[page] = cached.fullText;
      onStateChanged();
      return;
    }

    try {
      final pdfPage = pdfDocument.pages[page];
      final pngBytes = await renderPageToPngBytes(pdfPage);
      if (pngBytes != null) {
        await ocrService.ocrFromPngBytes(
          bookId: bookId!,
          pageNumber: pageNumber,
          pngBytes: pngBytes,
        );
        md = ocrService.getCachedMarkdown(bookId!, pageNumber);
      }
    } catch (e) {
      debugPrint('Text view OCR error: $e');
    }
    pages[page] = md ?? '';
    onStateChanged();
  }

  Widget buildTextView(
    BuildContext context, {
    required bool horizontalScroll,
    required int totalPages,
    required int currentPage,
    required void Function(int) onPageChanged,
  }) {
    return PageView.builder(
      controller: pageController,
      scrollDirection: horizontalScroll ? Axis.horizontal : Axis.vertical,
      itemCount: totalPages,
      onPageChanged: onPageChanged,
      itemBuilder: (context, index) {
        final content = pages[index];
        if (content == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (content.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.text_snippet_outlined, size: 48),
                const SizedBox(height: 8),
                Text(AppStrings.of(context).noTextOnPage),
              ],
            ),
          );
        }
        return Markdown(
          data: content,
          selectable: true,
          padding: const EdgeInsets.all(16),
          styleSheet: MarkdownStyleSheet(
            p: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
            h2: Theme.of(context).textTheme.titleLarge,
            listBullet: Theme.of(context).textTheme.bodyLarge,
          ),
        );
      },
    );
  }
}
