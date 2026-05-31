part of 'reader_screen_body.dart';

/// Overlay widgets for the reader screen (brightness, slider, progress, timer, OCR, tap zones).
extension _ReaderOverlays on ReaderScreenBody {
  List<Widget> buildOverlays(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return [
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
      if (state.pdfLoading && state.provider.error == null &&
          !(state.pdfProvider?.textViewController.textViewMode ?? false))
        const Center(child: CircularProgressIndicator()),
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
      if (!state.isEpub && state.isSearching && state.pdfProvider?.textSearcher != null)
        Positioned(bottom: 0, left: 0, right: 0,
          child: SearchResultsBar(textSearcher: state.pdfProvider!.textSearcher!)),
      if (!state.fullscreen && state.totalPages > 1 && !state.isSearching)
        Positioned(bottom: 0, left: 16, right: 16,
          child: SliderTheme(data: SliderTheme.of(context).copyWith(showValueIndicator: ShowValueIndicator.onDrag),
            child: Slider(value: state.currentPage.toDouble(), min: 0,
              max: (state.totalPages - 1).toDouble(),
              divisions: state.totalPages - 1,
              label: 'Page ${state.currentPage + 1}',
              onChanged: (v) {
                final p = v.round();
                if (state.isEpub) { state.epubPageController?.jumpToPage(p); }
                else { state.pdfProvider!.viewerController.goToPage(pageNumber: p + 1); }
              }))),
      if (!state.isEpub) PdfOcrOverlay(
        ocrInProgress: state.pdfProvider!.ocrController.ocrInProgress,
        ocrBatchRunning: state.pdfProvider!.ocrController.ocrBatchRunning,
        ocrBatchDone: state.pdfProvider!.ocrController.ocrBatchDone,
        ocrBatchTotal: state.pdfProvider!.ocrController.ocrBatchTotal,
        onCancelBatch: state.pdfProvider!.ocrController.cancelBatch),
      if (state.totalPages > 0 && state.fullscreen)
        Positioned(bottom: 0, left: 0, right: 0,
          child: LinearProgressIndicator(
            value: (state.currentPage + 1) / state.totalPages,
            minHeight: 2, backgroundColor: Colors.transparent)),
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
}
