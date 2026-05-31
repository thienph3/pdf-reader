import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/reader_ui_builder.dart';
import '../controllers/reader_dialogs.dart';
import '../widgets/search_results_bar.dart';
import '../widgets/ocr_overlay.dart';
import '../widgets/page_thumbnails.dart';
import 'reader_screen.dart';

class ReaderScreenBody extends StatelessWidget {
  final ReaderScreenState state;
  const ReaderScreenBody({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final searchCtrl = TextEditingController();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          if (state.isSearching) {
            state.setSearching(false);
            state.pdfProvider?.textSearcher?.resetTextSearch();
          } else {
            state.closeAndPop();
          }
        }
      },
      child: Focus(
        autofocus: true,
        onKeyEvent: (node, event) => _handleKeyEvent(event),
        child: Scaffold(
          appBar: state.fullscreen ? null : _buildAppBar(context, searchCtrl),
          floatingActionButton: _buildFAB(context),
          body: Stack(children: [
            _buildContent(context),
            ..._buildOverlays(context),
          ]),
        ),
      ),
    );
  }

  KeyEventResult _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent || state.isEpub) return KeyEventResult.ignored;
    final pdf = state.pdfProvider!;
    if (pdf.textViewController.textViewMode || state.isSearching) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.audioVolumeUp) {
      if (state.currentPage + 1 < state.totalPages) {
        pdf.viewerController.goToPage(pageNumber: state.currentPage + 2);
      }
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.audioVolumeDown) {
      if (state.currentPage > 0) {
        pdf.viewerController.goToPage(pageNumber: state.currentPage);
      }
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  PreferredSizeWidget? _buildAppBar(BuildContext context, TextEditingController searchCtrl) {
    if (state.isEpub) return _buildEpubAppBar(context);
    final pdf = state.pdfProvider!;
    final uiBuilder = PdfViewUiBuilder(
      bookmarkManager: pdf.bookmarkManager, fileName: state.widget.fileName,
      currentPage: state.currentPage, totalPages: state.totalPages,
      onClose: state.closeAndPop,
      onStartSearch: () => state.setSearching(true),
      onShowReaderActions: () => _showReaderActions(context),
      onToggleTts: () => pdf.ttsController.toggle(context, state.currentPage,
          pdf.pdfDocument, pdf.ocrController.setOcrInProgress),
      isTtsActive: pdf.ttsController.ttsActive,
      onStartOcr: state.widget.bookId != null
          ? () => pdf.ocrController.startOcrBatch(context, pdf.pdfDocument) : null,
      isOcrRunning: pdf.ocrController.ocrBatchRunning,
      onToggleTextView: state.widget.bookId != null ? () {
        pdf.textViewController.toggle(state.currentPage, state.totalPages);
        pdf.textViewController.loadPage(context, state.currentPage, pdf.pdfDocument);
      } : null,
      isTextViewMode: pdf.textViewController.textViewMode,
      isTextViewLoading: pdf.textViewController.textViewMode &&
          !pdf.textViewController.pages.containsKey(state.currentPage),
      onToggleBookmark: (p) => pdf.bookmarkManager.toggleBookmark(p),
      onShowThumbnails: state.totalPages > 0 && pdf.pdfDocument != null
          ? () => showPageThumbnails(context, pdfDocument: pdf.pdfDocument!,
              totalPages: state.totalPages, currentPage: state.currentPage,
              viewerController: pdf.viewerController) : null,
      onGoToPage: state.showGoToPageDialog,
      onCycleReadingMode: () => state.setReadingMode((state.readingMode + 1) % 3),
      readingMode: state.readingMode,
      onToggleTimer: state.toggleTimer,
      showTimer: state.showTimer,
      onShowPageNote: state.widget.bookId != null ? state.showPageNoteSheet : null,
    );
    if (state.isSearching) {
      return uiBuilder.buildSearchBar(context: context,
          searchController: searchCtrl, textSearcher: pdf.textSearcher,
          onBackPressed: () { state.setSearching(false); pdf.textSearcher?.resetTextSearch(); },
          onSearchSubmitted: (q) { if (q.isNotEmpty) pdf.textSearcher?.startTextSearch(q); });
    }
    return uiBuilder.buildAppBar(context);
  }

  PreferredSizeWidget _buildEpubAppBar(BuildContext context) {
    final title = state.epubProvider?.getChapterTitle(state.currentPage)
        ?? state.widget.fileName;
    final bookmarked = state.isPageBookmarked(state.currentPage);
    return AppBar(
      leading: IconButton(icon: const Icon(Icons.arrow_back),
          onPressed: state.closeAndPop),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      actions: [
        IconButton(
          icon: Icon(state.showTimer ? Icons.timer : Icons.timer_outlined,
              color: state.showTimer ? Theme.of(context).colorScheme.primary : null),
          onPressed: state.toggleTimer,
        ),
        if (state.widget.bookId != null)
          IconButton(icon: const Icon(Icons.note_add_outlined), onPressed: state.showPageNoteSheet),
        if (state.widget.bookId != null)
          IconButton(
            icon: Icon(bookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: bookmarked ? Theme.of(context).colorScheme.primary : null),
            onPressed: () => state.toggleBookmark(state.currentPage),
          ),
        Center(child: Padding(padding: const EdgeInsets.only(right: 16),
          child: Text('${state.currentPage + 1}/${state.totalPages}'))),
      ],
    );
  }

  Widget? _buildFAB(BuildContext context) {
    if (state.fullscreen || state.isEpub) return null;
    final pdf = state.pdfProvider!;
    final highlights = pdf.highlightManager.getHighlightsForCurrentPage(state.currentPage);
    if (highlights.isEmpty) return null;
    return FloatingActionButton(
      onPressed: () => pdf.highlightsUi.showCurrentPageHighlights(
          context: context, currentPage: state.currentPage),
      tooltip: 'Page Highlights (${highlights.length})',
      child: Badge(label: Text(highlights.length.toString()),
          child: const Icon(Icons.highlight)),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (state.isEpub) {
      return state.provider.buildContent(context,
        currentPage: state.currentPage,
        onPageChanged: state.onPageChanged,
        onReady: state.onContentReady,
        pageController: state.epubPageController,
      );
    }
    final pdf = state.pdfProvider!;
    if (pdf.textViewController.textViewMode) {
      return pdf.textViewController.buildTextView(context,
        horizontalScroll: state.horizontalScroll,
        totalPages: state.totalPages, currentPage: state.currentPage,
        onPageChanged: state.onPageChanged,
      );
    }
    return pdf.buildContent(context,
      currentPage: state.currentPage,
      onPageChanged: state.onPageChanged,
      onReady: state.onContentReady,
      horizontalScroll: state.horizontalScroll,
      readingMode: state.readingMode,
      cropMargins: state.cropMargins,
      isSearching: state.isSearching,
      initialPage: state.widget.initialPage,
      onSnapToPage: state.snapToCurrentPage,
      onCenterTap: state.toggleFullscreen,
    );
  }

  List<Widget> _buildOverlays(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return [
      // Tap zones for horizontal PDF
      if (!state.isEpub && state.horizontalScroll &&
          !(state.pdfProvider?.textViewController.textViewMode ?? false)) ...[
        Positioned(left: 0, top: 0, bottom: 0, width: size.width * 0.25,
          child: GestureDetector(behavior: HitTestBehavior.translucent,
            onTap: () { if (state.currentPage > 0) state.pdfProvider!.viewerController.goToPage(pageNumber: state.currentPage, duration: const Duration(milliseconds: 300)); })),
        Positioned(right: 0, top: 0, bottom: 0, width: size.width * 0.25,
          child: GestureDetector(behavior: HitTestBehavior.translucent,
            onTap: () { if (state.currentPage + 1 < state.totalPages) state.pdfProvider!.viewerController.goToPage(pageNumber: state.currentPage + 2, duration: const Duration(milliseconds: 300)); })),
        Positioned(left: size.width * 0.25, top: 0, bottom: 0, width: size.width * 0.5,
          child: GestureDetector(behavior: HitTestBehavior.translucent, onTap: state.toggleFullscreen)),
      ],
      // Loading indicator
      if (state.pdfLoading && state.provider.error == null &&
          !(state.pdfProvider?.textViewController.textViewMode ?? false))
        const Center(child: CircularProgressIndicator()),
      // Brightness gesture
      Positioned(left: 0, top: 0, bottom: 0, width: 40,
        child: GestureDetector(behavior: HitTestBehavior.translucent,
          onVerticalDragUpdate: (d) {
            final delta = -d.delta.dy / size.height;
            state.setBrightness((state.brightness + delta).clamp(0.0, 1.0));
          },
          onVerticalDragEnd: (_) => state.hideBrightnessIndicator(),
        )),
      if (state.showBrightnessIndicator) Positioned(left: 16, top: size.height * 0.3,
        child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.brightness_6, color: Colors.white, size: 20),
            const SizedBox(height: 4),
            Text('${(state.brightness * 100).round()}%', style: const TextStyle(color: Colors.white, fontSize: 12)),
          ]))),
      // Search results bar
      if (!state.isEpub && state.isSearching && state.pdfProvider?.textSearcher != null)
        Positioned(bottom: 0, left: 0, right: 0,
          child: SearchResultsBar(textSearcher: state.pdfProvider!.textSearcher!)),
      // Page slider
      if (!state.fullscreen && state.totalPages > 1 && !state.isSearching)
        Positioned(bottom: 0, left: 16, right: 16,
          child: SliderTheme(data: SliderTheme.of(context).copyWith(showValueIndicator: ShowValueIndicator.onDrag),
            child: Slider(value: state.currentPage.toDouble(), min: 0,
              max: (state.totalPages - 1).toDouble(),
              divisions: state.totalPages - 1,
              label: 'Page ${state.currentPage + 1}',
              onChanged: (v) {
                final p = v.round();
                if (state.isEpub) {
                  state.epubPageController?.jumpToPage(p);
                } else {
                  state.pdfProvider!.viewerController.goToPage(pageNumber: p + 1);
                }
              }))),
      // OCR overlay (PDF only)
      if (!state.isEpub) PdfOcrOverlay(
        ocrInProgress: state.pdfProvider!.ocrController.ocrInProgress,
        ocrBatchRunning: state.pdfProvider!.ocrController.ocrBatchRunning,
        ocrBatchDone: state.pdfProvider!.ocrController.ocrBatchDone,
        ocrBatchTotal: state.pdfProvider!.ocrController.ocrBatchTotal,
        onCancelBatch: state.pdfProvider!.ocrController.cancelBatch),
      // Fullscreen progress bar
      if (state.totalPages > 0 && state.fullscreen)
        Positioned(bottom: 0, left: 0, right: 0,
          child: LinearProgressIndicator(
            value: (state.currentPage + 1) / state.totalPages,
            minHeight: 2, backgroundColor: Colors.transparent)),
      // Focus timer chip
      if (state.showTimer)
        Positioned(top: 8, left: 0, right: 0,
          child: Center(child: Chip(
            avatar: const Icon(Icons.timer, size: 16),
            label: Text(_formatTimer(state.sessionSeconds)),
          ))),
    ];
  }

  static String _formatTimer(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _showReaderActions(BuildContext context) {
    if (state.isEpub) return;
    final pdf = state.pdfProvider!;
    final dialogsManager = PdfViewDialogsManager(
      highlightManager: pdf.highlightManager,
      bookmarkManager: pdf.bookmarkManager,
      viewerController: pdf.viewerController,
      ttsService: state.ttsService,
      currentPage: state.currentPage,
      pdfDocument: pdf.pdfDocument,
      onShowToc: () {},
      onShowHighlightsList: () => pdf.highlightsUi.showHighlightsList(
        context: context,
        onPageSelected: (p) => pdf.viewerController.goToPage(pageNumber: p + 1),
      ),
      onPageSelected: (p) => pdf.viewerController.goToPage(pageNumber: p + 1),
      onTtsSpeedChanged: () {
        if (pdf.ttsController.ttsActive) {
          pdf.ttsController.speakCurrentPage(context, state.currentPage,
              pdf.pdfDocument, pdf.ocrController.setOcrInProgress);
        }
      },
      onCycleReadingMode: () => state.setReadingMode((state.readingMode + 1) % 3),
      readingMode: state.readingMode,
      brightness: state.brightness,
      onBrightnessChanged: (v) {
        state.setBrightness(v);
      },
      cropMargins: state.cropMargins,
      onCycleCrop: () {
        state.setCropMargins(switch (state.cropMargins) {
          0 => 10, 10 => 15, 15 => 20, 20 => 25, _ => 0,
        });
      },
    );
    dialogsManager.showReaderActions(context);
  }
}
