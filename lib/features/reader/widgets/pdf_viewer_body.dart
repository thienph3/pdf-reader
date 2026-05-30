import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/utils/velocity_aware_scroll_physics.dart';
import '../controllers/pdf_highlight_manager.dart';
import '../controllers/pdf_text_selection_manager.dart';
import '../controllers/pdf_view_highlights_ui.dart';
import './pdf_view_search_ui.dart';
import './pdf_reading_mode.dart';
import '../../../models/highlight.dart';

class PdfViewerBody extends StatelessWidget {
  final String filePath;
  final PdfViewerController viewerController;
  final bool horizontalScroll;
  final int readingMode;
  final int currentPage;
  final PdfHighlightManager highlightManager;
  final PdfTextSelectionManager textSelectionManager;
  final PdfViewHighlightsUi highlightsUi;
  final PdfTextSearcher? textSearcher;
  final bool isSearching;
  final String? pdfError;
  final int initialPage;
  final String? bookId;
  final void Function(int) onPageChanged;
  final void Function(PdfDocument, PdfViewerController) onViewerReady;
  final VoidCallback onSnapToPage;
  final Highlight? Function(PdfPageHitTestResult) findTappedHighlight;

  const PdfViewerBody({
    super.key,
    required this.filePath,
    required this.viewerController,
    required this.horizontalScroll,
    required this.readingMode,
    required this.currentPage,
    required this.highlightManager,
    required this.textSelectionManager,
    required this.highlightsUi,
    required this.textSearcher,
    required this.isSearching,
    required this.pdfError,
    required this.initialPage,
    required this.bookId,
    required this.onPageChanged,
    required this.onViewerReady,
    required this.onSnapToPage,
    required this.findTappedHighlight,
  });

  @override
  Widget build(BuildContext context) {
    if (pdfError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(AppStrings.of(context).pdfLoadError, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(AppStrings.of(context).pdfCorruptMessage, textAlign: TextAlign.center),
          ]),
        ),
      );
    }
    return ColorFiltered(
      colorFilter: getReadingModeFilter(readingMode),
      child: PdfViewer.file(
        filePath,
        controller: viewerController,
        params: PdfViewerParams(
          layoutPages: horizontalScroll ? horizontalLayout : null,
          panAxis: horizontalScroll ? PanAxis.horizontal : PanAxis.free,
          pageAnchor: horizontalScroll ? PdfPageAnchor.all : PdfPageAnchor.top,
          scrollByMouseWheel: horizontalScroll ? 1.0 : 0.2,
          onPageChanged: (page) {
            if (page == null) return;
            final z = page - 1;
            if (z != currentPage) onPageChanged(z);
          },
          pagePaintCallbacks: [
            (c, r, p) => highlightManager.paintHighlights(c, r, p, null),
            (c, r, p) => PdfViewSearchUi.paintSearchMatches(c, r, p, textSearcher, isSearching),
          ],
          textSelectionParams: const PdfTextSelectionParams(
            enabled: true,
            magnifier: PdfViewerSelectionMagnifierParams(enabled: true),
          ),
          customizeContextMenuItems: (params, items) {
            if (params.contextMenuFor == PdfViewerPart.selectedText &&
                params.textSelectionDelegate.hasSelectedText) {
              items.add(textSelectionManager.buildHighlightButton(context, params));
            }
          },
          onGeneralTap: (ctx, controller, details) {
            if (details.type != PdfViewerGeneralTapType.tap) return false;
            final hit = controller.getPdfPageHitTestResult(
              details.documentPosition, useDocumentLayoutCoordinates: true);
            if (hit == null) return false;
            final tapped = findTappedHighlight(hit);
            if (tapped == null) return false;
            highlightsUi.showEditMenuForHighlight(context: context, highlight: tapped);
            return true;
          },
          onViewerReady: onViewerReady,
          scrollPhysics: VelocityAwareScrollPhysics(
            velocityMultiplier: horizontalScroll ? 1.8 : 1.5,
            flingMultiplier: horizontalScroll ? 2.5 : 2.0,
          ),
          onInteractionEnd: horizontalScroll ? (_) => onSnapToPage() : null,
        ),
      ),
    );
  }
}
