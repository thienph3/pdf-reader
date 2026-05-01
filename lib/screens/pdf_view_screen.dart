import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:uuid/uuid.dart';
import '../models/highlight.dart';
import '../services/book_service.dart';
import '../services/reading_log_service.dart';
import '../main.dart';
import '../l10n/app_strings.dart';
import 'widgets/bookmark_sheet.dart';
import 'widgets/highlight_sheet.dart';
import 'widgets/highlight_info_sheet.dart';
import 'widgets/search_results_bar.dart';

const _uuid = Uuid();

class PdfViewScreen extends StatefulWidget {
  final String filePath;
  final String fileName;
  final String? bookId;
  final int initialPage;

  const PdfViewScreen({
    super.key,
    required this.filePath,
    required this.fileName,
    this.bookId,
    this.initialPage = 0,
  });

  @override
  State<PdfViewScreen> createState() => _PdfViewScreenState();
}

class _PdfViewScreenState extends State<PdfViewScreen> {
  final PdfViewerController _viewerController = PdfViewerController();
  BookService? _bookService;
  ReadingLogService? _readingLogService;

  PdfDocument? _pdfDocument;

  int _totalPages = 0;
  int _currentPage = 0;
  bool _isBookmarked = false;
  bool _closed = false;
  bool _isSearching = false;

  Timer? _saveDebounce;
  int _sessionSeconds = 0;
  int _sessionStartPage = 0;
  Timer? _readingTimer;

  final TextEditingController _searchCtrl = TextEditingController();
  PdfTextSearcher? _textSearcher;

  // Store screen-space rects of highlights for tap detection
  final Map<String, Rect> _highlightScreenRects = {};

  /// Hit test: returns the Highlight if tap position hits one.
  Highlight? _hitTestHighlight(Offset tapPosition) {
    if (widget.bookId == null || _bookService == null) return null;
    final book = _bookService!.getById(widget.bookId!);
    if (book == null) return null;

    for (final h in book.highlights) {
      final rect = _highlightScreenRects[h.id];
      if (rect != null && rect.inflate(8).contains(tapPosition)) {
        return h;
      }
    }
    return null;
  }
  List<PdfTextRanges>? _pendingSelection;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _sessionStartPage = widget.initialPage;
    _readingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _sessionSeconds++;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.bookId != null) {
      _bookService = BookServiceScope.of(context);
      _readingLogService = ReadingLogServiceScope.of(context);
      _updateBookmarkState();
    }
  }

  void _updateBookmarkState() {
    if (widget.bookId == null || _bookService == null) return;
    setState(() {
      _isBookmarked = _bookService!.isBookmarked(widget.bookId!, _currentPage);
    });
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
    _updateBookmarkState();
    _debouncedSaveProgress();
  }

  void _debouncedSaveProgress() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 500), _saveProgress);
  }

  void _saveProgress() {
    if (widget.bookId == null || _bookService == null) return;
    final flushSec = _flushSessionSeconds();
    _bookService!.saveProgress(widget.bookId!, _currentPage,
        totalPages: _totalPages, addSeconds: flushSec);
    // Log daily reading
    final pagesRead = (_currentPage - _sessionStartPage).abs();
    _sessionStartPage = _currentPage;
    _readingLogService?.logReading(seconds: flushSec, pages: pagesRead);
  }

  int _flushSessionSeconds() {
    final s = _sessionSeconds;
    _sessionSeconds = 0;
    return s;
  }

  void _toggleBookmark() {
    if (widget.bookId == null || _bookService == null) return;
    if (_isBookmarked) {
      _bookService!.removeBookmark(widget.bookId!, _currentPage);
    } else {
      _bookService!.addBookmark(widget.bookId!, _currentPage);
    }
    _updateBookmarkState();
  }

  void _addNoteToBookmark() {
    if (widget.bookId == null || _bookService == null) return;
    if (!_isBookmarked) {
      _bookService!.addBookmark(widget.bookId!, _currentPage);
      _updateBookmarkState();
    }
    final book = _bookService!.getById(widget.bookId!);
    final bm =
        book?.bookmarks.where((b) => b.page == _currentPage).firstOrNull;
    final s = AppStrings.of(context);
    final ctrl = TextEditingController(text: bm?.note ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.editNote),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: s.noteHint,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: Text(s.cancel)),
          FilledButton(
            onPressed: () {
              _bookService!.updateBookmarkNote(
                  widget.bookId!, _currentPage, ctrl.text.trim());
              Navigator.pop(ctx);
            },
            child: Text(s.save),
          ),
        ],
      ),
    );
  }

  void _showBookmarksList() {
    if (widget.bookId == null || _bookService == null) return;
    final book = _bookService!.getById(widget.bookId!);
    if (book == null || book.bookmarks.isEmpty) {
      final s = AppStrings.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.noBookmarks)),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.8,
        minChildSize: 0.3,
        expand: false,
        builder: (_, scrollCtrl) => BookmarkSheet(
          bookmarks: book.bookmarks,
          currentPage: _currentPage,
          scrollController: scrollCtrl,
          onTap: (page) {
            Navigator.pop(ctx);
            _viewerController.goToPage(pageNumber: page + 1);
          },
          onDelete: (page) {
            _bookService!.removeBookmark(widget.bookId!, page);
            Navigator.pop(ctx);
            _updateBookmarkState();
          },
          onEditNote: (page) {
            Navigator.pop(ctx);
            _viewerController.goToPage(pageNumber: page + 1);
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) _addNoteToBookmark();
            });
          },
        ),
      ),
    );
  }

  void _showToc() async {
    final s = AppStrings.of(context);
    if (_pdfDocument == null) return;
    final outline = await _pdfDocument!.loadOutline();
    if (!mounted) return;
    if (outline.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.noToc)),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.8,
        minChildSize: 0.3,
        expand: false,
        builder: (_, scrollCtrl) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(s.tableOfContents,
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollCtrl,
                itemCount: outline.length,
                itemBuilder: (_, i) {
                  final item = outline[i];
                  return ListTile(
                    contentPadding: EdgeInsets.only(
                        left: 16.0 + (item.children.isNotEmpty ? 0 : 16)),
                    title: Text(item.title),
                    onTap: () {
                      Navigator.pop(ctx);
                      if (item.dest != null) {
                        _viewerController.goToDest(item.dest);
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startSearch() {
    setState(() => _isSearching = true);
  }

  void _doSearch(String query) {
    if (query.isEmpty) return;
    _textSearcher?.startTextSearch(query);
  }

  void _showReaderActions() {
    final s = AppStrings.of(context);
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                  _isBookmarked ? Icons.bookmark : Icons.bookmark_border),
              title:
                  Text(_isBookmarked ? s.removeBookmark : s.addBookmark),
              onTap: () {
                Navigator.pop(ctx);
                _toggleBookmark();
              },
            ),
            ListTile(
              leading: const Icon(Icons.note_add_outlined),
              title: Text(s.addNote),
              onTap: () {
                Navigator.pop(ctx);
                _addNoteToBookmark();
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmarks_outlined),
              title: Text(s.bookmarkList),
              onTap: () {
                Navigator.pop(ctx);
                _showBookmarksList();
              },
            ),
            ListTile(
              leading: const Icon(Icons.toc),
              title: Text(s.tableOfContents),
              onTap: () {
                Navigator.pop(ctx);
                _showToc();
              },
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: Text(s.searchInPdf),
              onTap: () {
                Navigator.pop(ctx);
                _startSearch();
              },
            ),
            ListTile(
              leading: const Icon(Icons.highlight),
              title: Text(s.highlights),
              onTap: () {
                Navigator.pop(ctx);
                _showHighlightsList();
              },
            ),
          ],
        ),
      ),
    );
  }

  static const _highlightColors = [
    0x80FFEB3B, // yellow
    0x8066BB6A, // green
    0x8042A5F5, // blue
    0x80EF5350, // red
    0x80AB47BC, // purple
    0x80FF7043, // orange
  ];

  void _highlightSelection() {
    if (_pendingSelection == null || _pendingSelection!.isEmpty) return;
    final s = AppStrings.of(context);
    final noteCtrl = TextEditingController();
    int selectedColor = _highlightColors[0];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
              16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.addHighlight,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                children: _highlightColors.map((color) {
                  final isSelected = selectedColor == color;
                  return GestureDetector(
                    onTap: () => setSheetState(() => selectedColor = color),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Color(color),
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(
                                color: Theme.of(ctx).colorScheme.onSurface,
                                width: 3)
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 16)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteCtrl,
                decoration: InputDecoration(
                  hintText: s.highlightNote,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _doHighlight(selectedColor, noteCtrl.text.trim());
                  },
                  child: Text(s.save),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _doHighlight(int colorValue, String note) {
    if (_pendingSelection == null || _pendingSelection!.isEmpty) return;
    final sel = _pendingSelection!.first;
    final text = sel.text;
    final page = sel.pageNumber - 1;
    final startIndex = sel.ranges.isNotEmpty ? sel.ranges.first.start : 0;
    final endIndex = sel.ranges.isNotEmpty ? sel.ranges.last.end : 0;
    _addHighlightFromSelection(text, page, startIndex, endIndex, colorValue, note);
    _pendingSelection = null;
    setState(() {});
  }

  void _addHighlightFromSelection(
      String text, int page, int startIndex, int endIndex, int colorValue, String note) {
    if (widget.bookId == null || _bookService == null) return;
    final highlight = Highlight(
      id: _uuid.v4(),
      page: page,
      startIndex: startIndex,
      endIndex: endIndex,
      text: text,
      colorValue: colorValue,
      note: note,
      createdAt: DateTime.now(),
    );
    _bookService!.addHighlight(widget.bookId!, highlight);
    final s = AppStrings.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(s.addHighlight)),
    );
  }

  void _showHighlightsList() {
    if (widget.bookId == null || _bookService == null) return;
    final book = _bookService!.getById(widget.bookId!);
    if (book == null || book.highlights.isEmpty) {
      final s = AppStrings.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.noHighlights)),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.8,
        minChildSize: 0.3,
        expand: false,
        builder: (_, scrollCtrl) => HighlightSheet(
          highlights: book.highlights,
          currentPage: _currentPage,
          scrollController: scrollCtrl,
          onTap: (highlight) {
            Navigator.pop(ctx);
            _viewerController.goToPage(pageNumber: highlight.page + 1);
          },
          onDelete: (highlight) {
            _bookService!.removeHighlight(widget.bookId!, highlight.id);
            Navigator.pop(ctx);
          },
          onEditNote: (highlight) {
            Navigator.pop(ctx);
            _editHighlightNote(highlight);
          },
        ),
      ),
    );
  }

  void _editHighlightNote(Highlight highlight) {
    _showHighlightInfo(highlight);
  }

  void _showHighlightInfo(Highlight highlight) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => HighlightInfoSheet(
        highlight: highlight,
        onEditNote: () {
          Navigator.pop(ctx);
          _editHighlightNoteDialog(highlight);
        },
        onDelete: () {
          _bookService!.removeHighlight(widget.bookId!, highlight.id);
          Navigator.pop(ctx);
          setState(() {});
        },
      ),
    );
  }

  void _editHighlightNoteDialog(Highlight highlight) {
    final s = AppStrings.of(context);
    final ctrl = TextEditingController(text: highlight.note);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.editNote),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: s.highlightNote,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: Text(s.cancel)),
          FilledButton(
            onPressed: () {
              _bookService!.updateHighlightNote(
                  widget.bookId!, highlight.id, ctrl.text.trim());
              Navigator.pop(ctx);
            },
            child: Text(s.save),
          ),
        ],
      ),
    );
  }

  // Cache loaded page text for highlight rendering
  final Map<int, PdfPageText> _pageTextCache = {};

  Future<PdfPageText?> _getPageText(int pageNumber) async {
    if (_pageTextCache.containsKey(pageNumber)) return _pageTextCache[pageNumber];
    if (_pdfDocument == null || pageNumber < 1 || pageNumber > _totalPages) return null;
    try {
      final text = await _pdfDocument!.pages[pageNumber - 1].loadText();
      _pageTextCache[pageNumber] = text;
      return text;
    } catch (_) {
      return null;
    }
  }

  void _paintHighlights(ui.Canvas canvas, Rect pageRect, PdfPage page) {
    if (widget.bookId == null || _bookService == null) return;
    final pageIndex = page.pageNumber - 1;
    final highlights = _bookService!.getHighlightsForPage(widget.bookId!, pageIndex);

    // Clear rects for this page's highlights
    for (final h in highlights) {
      _highlightScreenRects.remove(h.id);
    }

    if (highlights.isEmpty) return;

    final pageText = _pageTextCache[page.pageNumber];
    if (pageText == null) {
      _getPageText(page.pageNumber).then((_) {
        if (mounted) setState(() {});
      });
      return;
    }

    for (final h in highlights) {
      final paint = ui.Paint()..color = Color(h.colorValue);
      Rect? combinedRect;

      for (final fragment in pageText.fragments) {
        final fragStart = fragment.index;
        final fragEnd = fragment.index + fragment.length;

        if (fragEnd <= h.startIndex || fragStart >= h.endIndex) continue;

        final overlapStart = (h.startIndex - fragStart).clamp(0, fragment.length);
        final overlapEnd = (h.endIndex - fragStart).clamp(0, fragment.length);

        if (overlapStart >= overlapEnd) continue;

        for (int ci = overlapStart; ci < overlapEnd && ci < fragment.charRects.length; ci++) {
          final charRect = fragment.charRects[ci];
          final rect = Rect.fromLTRB(
            pageRect.left + charRect.left / page.width * pageRect.width,
            pageRect.top + (1 - charRect.top / page.height) * pageRect.height,
            pageRect.left + charRect.right / page.width * pageRect.width,
            pageRect.top + (1 - charRect.bottom / page.height) * pageRect.height,
          );
          canvas.drawRect(rect, paint);
          combinedRect = combinedRect?.expandToInclude(rect) ?? rect;
        }
      }

      // Store screen rect for tap detection
      if (combinedRect != null) {
        _highlightScreenRects[h.id] = combinedRect;
      }
    }
  }

  void _paintSearchMatches(ui.Canvas canvas, Rect pageRect, PdfPage page) {
    if (_textSearcher == null || !_isSearching) return;
    final matches = _textSearcher!.matches;
    if (matches.isEmpty) return;

    final currentIdx = _textSearcher!.currentIndex;

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

  void _closeAndPop() {
    if (_closed) return;
    _closed = true;
    _saveDebounce?.cancel();
    _readingTimer?.cancel();
    _saveProgress();
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    _readingTimer?.cancel();
    _searchCtrl.dispose();
    _textSearcher?.dispose();
    if (!_closed) _saveProgress();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          if (_isSearching) {
            setState(() => _isSearching = false);
            _searchCtrl.clear();
            _textSearcher?.resetTextSearch();
          } else {
            _closeAndPop();
          }
        }
      },
      child: Scaffold(
        appBar: _isSearching ? _buildSearchBar() : _buildAppBar(),
        floatingActionButton: _pendingSelection != null && widget.bookId != null
            ? FloatingActionButton.small(
                onPressed: _highlightSelection,
                child: const Icon(Icons.highlight),
              )
            : null,
        body: Stack(
          children: [
            PdfViewer.file(
              widget.filePath,
              controller: _viewerController,
              params: PdfViewerParams(
                enableTextSelection: true,
                pagePaintCallbacks: [_paintHighlights, _paintSearchMatches],
                viewerOverlayBuilder: (context, size, handleLinkTap) => [
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTapUp: (details) {
                      final hit = _hitTestHighlight(details.localPosition);
                      if (hit != null) {
                        _showHighlightInfo(hit);
                      } else {
                        handleLinkTap(details.localPosition);
                      }
                    },
                    child: SizedBox(width: size.width, height: size.height),
                  ),
                ],
                onTextSelectionChange: (selections) {
                  if (selections.isNotEmpty) {
                    _pendingSelection = selections;
                  } else {
                    _pendingSelection = null;
                  }
                  setState(() {});
                },
                onViewerReady: (document, controller) {
                  _pdfDocument = document;
                  _textSearcher = PdfTextSearcher(_viewerController);
              _textSearcher!.addListener(() {
                if (mounted) setState(() {}); // repaint search highlights
              });
                  setState(() {
                    _totalPages = document.pages.length;
                    if (_currentPage >= _totalPages) _currentPage = 0;
                  });
                  if (widget.bookId != null && _bookService != null) {
                    _bookService!.saveProgress(widget.bookId!, _currentPage,
                        totalPages: _totalPages);
                  }
                  if (widget.initialPage > 0 &&
                      widget.initialPage < _totalPages) {
                    controller.goToPage(pageNumber: widget.initialPage + 1);
                  }
                },
                onPageChanged: (page) {
                  if (page != null) _onPageChanged(page - 1);
                },
              ),
            ),
            // Search results overlay
            if (_isSearching && _textSearcher != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SearchResultsBar(textSearcher: _textSearcher!),
              ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: _closeAndPop,
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.fileName,
            style: Theme.of(context).textTheme.titleSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (_totalPages > 0)
            Text(
              '${_currentPage + 1} / $_totalPages',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
        ],
      ),
      actions: [
        if (_totalPages > 0 && widget.bookId != null) ...[
          // Bookmark toggle always visible
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: _isBookmarked
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
            onPressed: _toggleBookmark,
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _startSearch,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showReaderActions,
          ),
        ],
      ],
    );
  }

  PreferredSizeWidget _buildSearchBar() {
    final s = AppStrings.of(context);
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          setState(() => _isSearching = false);
          _searchCtrl.clear();
          _textSearcher?.resetTextSearch();
        },
      ),
      title: TextField(
        controller: _searchCtrl,
        autofocus: true,
        decoration: InputDecoration(
          hintText: s.searchHintPdf,
          border: InputBorder.none,
        ),
        onSubmitted: _doSearch,
      ),
      actions: [
        if (_textSearcher != null)
          ListenableBuilder(
            listenable: _textSearcher!,
            builder: (_, __) {
              final matches = _textSearcher!.matches;
              final currentIdx = _textSearcher!.currentIndex;
              final hasMatches = matches.isNotEmpty && currentIdx != null;
              final isFirst = !hasMatches || currentIdx <= 0;
              final isLast = !hasMatches || currentIdx >= matches.length - 1;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasMatches)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Text(
                        '${currentIdx + 1}/${matches.length}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.navigate_before),
                    onPressed:
                        hasMatches && !isFirst ? () => _textSearcher!.goToPrevMatch() : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.navigate_next),
                    onPressed:
                        hasMatches && !isLast ? () => _textSearcher!.goToNextMatch() : null,
                  ),
                ],
              );
            },
          ),
      ],
    );
  }
}
