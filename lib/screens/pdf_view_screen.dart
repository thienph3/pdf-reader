import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import '../models/book.dart';
import '../services/book_service.dart';
import '../main.dart';
import '../l10n/app_strings.dart';

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
  PdfControllerPinch? _pdfController;
  BookService? _bookService;

  int _totalPages = 0;
  int _currentPage = 0;
  bool _isLoading = true;
  String? _error;
  bool _isBookmarked = false;

  Timer? _saveDebounce;
  bool _closed = false;

  // Reading time tracking
  int _sessionSeconds = 0;
  Timer? _readingTimer;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _readingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _sessionSeconds++;
    });
    _openDocument();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.bookId != null) {
      _bookService = BookServiceScope.of(context);
      _updateBookmarkState();
    }
  }

  void _updateBookmarkState() {
    if (widget.bookId == null || _bookService == null) return;
    setState(() {
      _isBookmarked = _bookService!.isBookmarked(widget.bookId!, _currentPage);
    });
  }

  Future<void> _openDocument() async {
    try {
      final document = await PdfDocument.openFile(widget.filePath);
      if (!mounted) return;

      final count = document.pagesCount;
      final initialPage = widget.initialPage.clamp(0, count - 1);

      _pdfController = PdfControllerPinch(
        document: Future.value(document),
        initialPage: initialPage + 1, // pdfx is 1-indexed
      );

      setState(() {
        _totalPages = count;
        _currentPage = initialPage;
        _isLoading = false;
      });

      if (widget.bookId != null && _bookService != null) {
        _bookService!.saveProgress(widget.bookId!, _currentPage,
            totalPages: count);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onPageChanged(int page) {
    // pdfx reports 1-indexed pages
    final zeroIndexed = page - 1;
    setState(() => _currentPage = zeroIndexed);
    _updateBookmarkState();
    _debouncedSaveProgress();
  }

  void _debouncedSaveProgress() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 500), _saveProgress);
  }

  void _saveProgress() {
    if (widget.bookId == null || _bookService == null) return;
    _bookService!.saveProgress(widget.bookId!, _currentPage,
        totalPages: _totalPages, addSeconds: _flushSessionSeconds());
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
      builder: (ctx) => _BookmarkSheet(
        bookmarks: book.bookmarks,
        currentPage: _currentPage,
        onTap: (page) {
          Navigator.pop(ctx);
          _pdfController?.jumpToPage(page + 1); // 1-indexed
        },
        onDelete: (page) {
          _bookService!.removeBookmark(widget.bookId!, page);
          Navigator.pop(ctx);
          _updateBookmarkState();
        },
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
    if (!_closed) _saveProgress();
    _pdfController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _closeAndPop();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _closeAndPop,
          ),
          title: Text(widget.fileName),
          actions: [
            if (_totalPages > 0 && widget.bookId != null) ...[
              IconButton(
                icon: Icon(
                  _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                ),
                tooltip: _isBookmarked ? s.removeBookmark : s.addBookmark,
                onPressed: _toggleBookmark,
              ),
              IconButton(
                icon: const Icon(Icons.bookmarks_outlined),
                tooltip: s.bookmarkList,
                onPressed: _showBookmarksList,
              ),
            ],
            if (_totalPages > 0)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      '${_currentPage + 1} / $_totalPages',
                      key: ValueKey(_currentPage),
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    final s = AppStrings.of(context);
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(s.openingPdf),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(s.error(_error!), textAlign: TextAlign.center),
        ),
      );
    }

    return PdfViewPinch(
      controller: _pdfController!,
      onPageChanged: _onPageChanged,
    );
  }
}

/// Bookmark list bottom sheet.
class _BookmarkSheet extends StatelessWidget {
  final List<Bookmark> bookmarks;
  final int currentPage;
  final void Function(int page) onTap;
  final void Function(int page) onDelete;

  const _BookmarkSheet({
    required this.bookmarks,
    required this.currentPage,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final sorted = List.of(bookmarks)
      ..sort((a, b) => a.page.compareTo(b.page));
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(s.bookmarkList,
              style: Theme.of(context).textTheme.titleMedium),
        ),
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
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
                subtitle: bm.note.isNotEmpty ? Text(bm.note) : null,
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: () => onDelete(bm.page),
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
