import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:pdfrx/pdfrx.dart';
import '../l10n/app_strings.dart';
import '../main.dart';

/// Full-screen OCR text view (reflow mode) for scanned PDFs.
class PdfOcrTextView extends StatefulWidget {
  final PdfDocument pdfDocument;
  final String bookId;
  final int initialPage;

  const PdfOcrTextView({
    super.key,
    required this.pdfDocument,
    required this.bookId,
    required this.initialPage,
  });

  @override
  State<PdfOcrTextView> createState() => _PdfOcrTextViewState();
}

class _PdfOcrTextViewState extends State<PdfOcrTextView> {
  late PageController _pageController;
  int _currentPage = 0;
  bool _isLoading = false;
  final Map<int, String> _markdownCache = {};

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _pageController = PageController(initialPage: _currentPage);
  }

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _loadPage(_currentPage);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadPage(int page) async {
    if (_markdownCache.containsKey(page)) return;

    final ocrService = OcrServiceScope.of(context);

    // Check if already cached
    var md = ocrService.getCachedMarkdown(widget.bookId, page + 1);
    if (md != null) {
      setState(() => _markdownCache[page] = md!);
      return;
    }

    // Need to OCR
    setState(() => _isLoading = true);
    try {
      final pdfPage = widget.pdfDocument.pages[page];
      final image = await pdfPage.render(fullWidth: 1000, fullHeight: 1400);
      if (image != null) {
        final uiImage = await image.createImage();
        final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);
        uiImage.dispose();
        if (byteData != null) {
          await ocrService.ocrFromPngBytes(
            bookId: widget.bookId,
            pageNumber: page + 1,
            pngBytes: byteData.buffer.asUint8List(),
          );
          md = ocrService.getCachedMarkdown(widget.bookId, page + 1);
        }
      }
    } catch (e) {
      debugPrint('OCR text view error: $e');
    }

    if (mounted) {
      setState(() {
        _markdownCache[page] = md ?? '';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final totalPages = widget.pdfDocument.pages.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('${s.page(_currentPage + 1)} / $totalPages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: s.switchToPdfView,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: totalPages,
        onPageChanged: (page) {
          setState(() => _currentPage = page);
          _loadPage(page);
          // Preload adjacent
          if (page + 1 < totalPages) _loadPage(page + 1);
          if (page - 1 >= 0) _loadPage(page - 1);
        },
        itemBuilder: (context, index) {
          final md = _markdownCache[index];
          if (md == null || (_isLoading && index == _currentPage)) {
            return const Center(child: CircularProgressIndicator());
          }
          if (md.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.text_snippet_outlined, size: 48),
                  const SizedBox(height: 8),
                  Text(s.noTextOnPage),
                ],
              ),
            );
          }
          return Markdown(
            data: md,
            selectable: true,
            padding: const EdgeInsets.all(16),
            styleSheet: MarkdownStyleSheet(
              p: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
              h2: Theme.of(context).textTheme.titleLarge,
              listBullet: Theme.of(context).textTheme.bodyLarge,
            ),
          );
        },
      ),
    );
  }
}
