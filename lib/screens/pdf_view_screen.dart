import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:uuid/uuid.dart';
import '../models/book.dart';
import '../models/highlight.dart';
import '../services/book_service.dart';
import '../services/reading_log_service.dart';
import '../main.dart';
import '../l10n/app_strings.dart';

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
        builder: (_, scrollCtrl) => _BookmarkSheet(
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

  void _highlightSelection() {
    if (_pendingSelection == null || _pendingSelection!.isEmpty) return;
    final sel = _pendingSelection!.first;
    final text = sel.text;
    final page = sel.pageNumber - 1; // 0-indexed
    final startIndex = sel.ranges.isNotEmpty ? sel.ranges.first.start : 0;
    final endIndex = sel.ranges.isNotEmpty ? sel.ranges.last.end : 0;
    _addHighlightFromSelection(text, page, startIndex, endIndex);
    _pendingSelection = null;
    setState(() {});
  }

  void _addHighlightFromSelection(String text, int page, int startIndex, int endIndex) {
    if (widget.bookId == null || _bookService == null) return;
    final highlight = Highlight(
      id: _uuid.v4(),
      page: page,
      startIndex: startIndex,
      endIndex: endIndex,
      text: text,
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
        builder: (_, scrollCtrl) => _HighlightSheet(
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
        body: PdfViewer.file(
          widget.filePath,
          controller: _viewerController,
          params: PdfViewerParams(
            enableTextSelection: true,
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
        IconButton(
          icon: const Icon(Icons.navigate_before),
          onPressed: () => _textSearcher?.goToPrevMatch(),
        ),
        IconButton(
          icon: const Icon(Icons.navigate_next),
          onPressed: () => _textSearcher?.goToNextMatch(),
        ),
      ],
    );
  }
}

/// Bookmark list with notes, edit, delete.
class _BookmarkSheet extends StatelessWidget {
  final List<Bookmark> bookmarks;
  final int currentPage;
  final ScrollController scrollController;
  final void Function(int page) onTap;
  final void Function(int page) onDelete;
  final void Function(int page) onEditNote;

  const _BookmarkSheet({
    required this.bookmarks,
    required this.currentPage,
    required this.scrollController,
    required this.onTap,
    required this.onDelete,
    required this.onEditNote,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final sorted = List.of(bookmarks)
      ..sort((a, b) => a.page.compareTo(b.page));
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(s.bookmarkList,
              style: Theme.of(context).textTheme.titleMedium),
        ),
        Expanded(
          child: ListView.builder(
            controller: scrollController,
            itemCount: sorted.length,
            itemBuilder: (_, i) {
              final bm = sorted[i];
              final isCurrent = bm.page == currentPage;
              return ListTile(
                leading: Icon(
                  Icons.bookmark,
                  color: isCurrent
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                title: Text(s.page(bm.page + 1)),
                subtitle: bm.note.isNotEmpty
                    ? Text(bm.note,
                        maxLines: 2, overflow: TextOverflow.ellipsis)
                    : null,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_note, size: 20),
                      onPressed: () => onEditNote(bm.page),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed: () => onDelete(bm.page),
                    ),
                  ],
                ),
                onTap: () => onTap(bm.page),
              );
            },
          ),
        ),
      ],
    );
  }
}


/// Highlights list bottom sheet.
class _HighlightSheet extends StatelessWidget {
  final List<Highlight> highlights;
  final int currentPage;
  final ScrollController scrollController;
  final void Function(Highlight) onTap;
  final void Function(Highlight) onDelete;
  final void Function(Highlight) onEditNote;

  const _HighlightSheet({
    required this.highlights,
    required this.currentPage,
    required this.scrollController,
    required this.onTap,
    required this.onDelete,
    required this.onEditNote,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final sorted = List.of(highlights)
      ..sort((a, b) => a.page != b.page
          ? a.page.compareTo(b.page)
          : a.startIndex.compareTo(b.startIndex));
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(s.highlights,
              style: Theme.of(context).textTheme.titleMedium),
        ),
        Expanded(
          child: ListView.builder(
            controller: scrollController,
            itemCount: sorted.length,
            itemBuilder: (_, i) {
              final h = sorted[i];
              return ListTile(
                leading: Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(h.colorValue),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                title: Text(
                  '"${h.text}"',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                subtitle: Text(
                  '${s.page(h.page + 1)}${h.note.isNotEmpty ? ' · ${h.note}' : ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_note, size: 20),
                      onPressed: () => onEditNote(h),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed: () => onDelete(h),
                    ),
                  ],
                ),
                onTap: () => onTap(h),
              );
            },
          ),
        ),
      ],
    );
  }
}
