// ignore_for_file: invalid_use_of_protected_member
part of 'reader_screen.dart';
/// Persistence, page/TTS callbacks, UI toggles, and dialogs for ReaderScreenState.
extension ReaderLogic on ReaderScreenState {
  void loadBookSettings() {
    try {
      _horizontalScroll = SettingsScope.of(context).isHorizontalScroll;
      _readingMode = SettingsScope.of(context).readingMode;
    } catch (_) {}
    if (_bookSettingsService == null && widget.bookId != null) {
      _bookSettingsService = BookSettingsServiceScope.of(context);
      final bs = _bookSettingsService!.getSettings(widget.bookId!);
      _readingMode = bs.readingMode;
      _horizontalScroll = bs.horizontalScroll;
      _cropMargins = bs.cropMargins;
      if (bs.brightness >= 0) {
        _brightness = bs.brightness;
        try { ScreenBrightness().setApplicationScreenBrightness(bs.brightness); } catch (_) {}
      }
    }
  }

  void handleTtsStateChanged() {
    if (_isEpub) return;
    _pdfProvider!.ttsController.onTtsStateChanged(_currentPage, _totalPages);
    if (_pdfProvider!.ttsController.ttsActive && ttsService.isStopped &&
        ttsService.currentText == null && _currentPage + 1 < _totalPages) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && _pdfProvider!.ttsController.ttsActive) {
          _pdfProvider!.ttsController.speakCurrentPage(context, _currentPage,
              _pdfProvider!.pdfDocument, _pdfProvider!.ocrController.setOcrInProgress);
        }
      });
    }
    if (mounted) setState(() {});
  }

  void onPageChanged(int page) {
    setState(() { _currentPage = page; _totalPages = _provider.totalPages; });
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 500), saveProgress);
    if (!_isEpub) {
      _pdfProvider!.highlightManager.preloadTextAroundCurrentPage(_currentPage, _pdfProvider!.pdfDocument);
      _pdfProvider!.ttsController.onPageChangedWhileTts(
          context, _currentPage, _pdfProvider!.pdfDocument, _pdfProvider!.ocrController.setOcrInProgress);
      if (_pdfProvider!.textViewController.textViewMode) {
        _pdfProvider!.textViewController.loadPage(context, _currentPage, _pdfProvider!.pdfDocument);
      }
    }
  }

  void onContentReady() {
    setState(() {
      _pdfLoading = false;
      _totalPages = _provider.totalPages;
      if (_currentPage >= _totalPages) _currentPage = 0;
    });
    if (!_isEpub && widget.bookId != null && _bookService != null) {
      _bookService!.saveProgress(widget.bookId!, _currentPage, totalPages: _totalPages);
    }
    if (!_isEpub) {
      _pdfProvider!.highlightManager.preloadTextAroundCurrentPage(_currentPage, _pdfProvider!.pdfDocument);
      _restoreZoom();
    }
  }

  void _restoreZoom() {
    if (widget.bookId == null || _bookSettingsService == null || _isEpub) return;
    final z = _bookSettingsService!.getSettings(widget.bookId!).lastZoom;
    if (z > 1.0) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _pdfProvider!.viewerController.setZoom(_pdfProvider!.viewerController.centerPosition, z);
      });
    }
  }

  void saveProgress() {
    if (widget.bookId == null || _bookService == null) return;
    final s = _sessionSeconds; _sessionSeconds = 0;
    if (s == 0 && _currentPage == _sessionStartPage) return;
    if (_isEpub) {
      final book = _bookService!.getById(widget.bookId!);
      if (book != null) {
        _bookService!.update(book.copyWith(lastPage: _currentPage, totalPages: _totalPages, lastOpenedAt: () => DateTime.now()));
      }
    } else {
      _bookService!.saveProgress(widget.bookId!, _currentPage, totalPages: _totalPages, addSeconds: s > 0 ? s : null);
    }
    final p = (_currentPage > _sessionStartPage) ? _currentPage - _sessionStartPage : 0;
    _sessionStartPage = _currentPage;
    if (s > 0 || p > 0) _readingLogService?.logReading(seconds: s, pages: p);
    saveBookSettings();
  }

  void saveBookSettings() {
    if (widget.bookId == null || _bookSettingsService == null || _isEpub) return;
    _bookSettingsService!.saveSettings(widget.bookId!, BookSettings(
      readingMode: _readingMode, horizontalScroll: _horizontalScroll,
      cropMargins: _cropMargins, brightness: _brightness,
      lastZoom: _pdfProvider!.viewerController.currentZoom,
    ));
  }

  void toggleFullscreen() {
    setState(() => _fullscreen = !_fullscreen);
    SystemChrome.setEnabledSystemUIMode(_fullscreen ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge);
  }

  void setSearching(bool v) => setState(() => _isSearching = v);
  void setReadingMode(int m) => setState(() => _readingMode = m);
  void toggleTimer() => setState(() => _showTimer = !_showTimer);
  void setCropMargins(int c) { setState(() => _cropMargins = c); saveBookSettings(); }
  void setBrightness(double v) {
    setState(() { _brightness = v; _showBrightnessIndicator = true; });
    try { ScreenBrightness().setApplicationScreenBrightness(v); } catch (_) {}
  }
  void hideBrightnessIndicator() => setState(() => _showBrightnessIndicator = false);

  void closeAndPop() {
    if (_closed) return;
    _closed = true;
    _saveDebounce?.cancel();
    _readingTimer?.cancel();
    saveProgress();
    if (mounted) Navigator.pop(context);
  }

  bool isPageBookmarked(int page) {
    if (widget.bookId == null || _bookService == null) return false;
    return _bookService!.isBookmarked(widget.bookId!, page);
  }

  void toggleBookmark(int page) {
    if (widget.bookId == null || _bookService == null) return;
    HapticFeedback.lightImpact();
    if (isPageBookmarked(page)) { _bookService!.removeBookmark(widget.bookId!, page); }
    else { _bookService!.addBookmark(widget.bookId!, page); }
    setState(() {});
  }

  void snapToCurrentPage() {
    if (_isEpub) return;
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted || !_horizontalScroll) return;
      final p = _pdfProvider!.viewerController.pageNumber;
      if (p != null && p > 0) {
        _pdfProvider!.viewerController.goToPage(pageNumber: p, duration: const Duration(milliseconds: 200));
      }
    });
  }

  void showGoToPageDialog() {
    final s = AppStrings.of(context);
    final ctrl = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text(s.goToPage),
      content: TextField(controller: ctrl, keyboardType: TextInputType.number,
          autofocus: true, decoration: InputDecoration(hintText: '1 - $_totalPages')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(s.cancel)),
        TextButton(onPressed: () {
          final p = int.tryParse(ctrl.text);
          if (p != null && p >= 1 && p <= _totalPages) {
            Navigator.pop(ctx);
            if (_isEpub) { _epubPageController?.jumpToPage(p - 1); }
            else { _pdfProvider!.viewerController.goToPage(pageNumber: p); }
          }
        }, child: Text(s.go)),
      ],
    ));
  }

  void showPageNoteSheet() {
    if (widget.bookId == null) return;
    final notesService = PageNotesServiceScope.of(context);
    final s = AppStrings.of(context);
    final existing = notesService.getNote(widget.bookId!, _currentPage);
    final ctrl = TextEditingController(text: existing ?? '');
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16, right: 16, top: 16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: ctrl, autofocus: true, maxLines: 4,
            decoration: InputDecoration(hintText: s.noteHint, border: const OutlineInputBorder())),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            if (existing != null)
              TextButton(onPressed: () { notesService.deleteNote(widget.bookId!, _currentPage); Navigator.pop(ctx); }, child: Text(s.delete)),
            const Spacer(),
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(s.cancel)),
            TextButton(onPressed: () { notesService.saveNote(widget.bookId!, _currentPage, ctrl.text); Navigator.pop(ctx); }, child: Text(s.save)),
          ]),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }
}
