import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/book_service.dart';
import '../services/pdf_render_service.dart';
import '../main.dart';

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

class _PdfViewScreenState extends State<PdfViewScreen>
    with SingleTickerProviderStateMixin {
  final PdfRenderService _renderService = PdfRenderService();
  late final PageController _pageController;

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

  late final AnimationController _loadingDoneController;
  late final Animation<double> _bodyFade;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _pageController = PageController(initialPage: widget.initialPage);
    _loadingDoneController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _bodyFade = CurvedAnimation(
      parent: _loadingDoneController,
      curve: Curves.easeIn,
    );
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
      final count = await _renderService.open(widget.filePath);
      if (!mounted) return;
      setState(() {
        _totalPages = count;
        _isLoading = false;
        if (_currentPage >= count) _currentPage = 0;
      });
      // Save totalPages on first open
      if (widget.bookId != null && _bookService != null) {
        _bookService!.saveProgress(widget.bookId!, _currentPage,
            totalPages: count);
      }
      _loadingDoneController.forward();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      _loadingDoneController.forward();
    }
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
    _updateBookmarkState();
    _debouncedSaveProgress();
    final viewport = MediaQuery.of(context).size;
    _renderService.preloadAround(page, viewport: viewport);
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chưa có bookmark nào')),
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
          _pageController.jumpToPage(page);
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
    _renderService.close();
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    _readingTimer?.cancel();
    _loadingDoneController.dispose();
    if (!_closed) _renderService.close();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                tooltip: _isBookmarked ? 'Bỏ bookmark' : 'Thêm bookmark',
                onPressed: _toggleBookmark,
              ),
              IconButton(
                icon: const Icon(Icons.bookmarks_outlined),
                tooltip: 'Danh sách bookmark',
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
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Đang mở file PDF...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return FadeTransition(
        opacity: _bodyFade,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Lỗi: $_error', textAlign: TextAlign.center),
          ),
        ),
      );
    }

    return FadeTransition(
      opacity: _bodyFade,
      child: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: _totalPages,
        onPageChanged: _onPageChanged,
        itemBuilder: (context, index) => _PdfPageWidget(
          key: ValueKey(index),
          renderService: _renderService,
          pageIndex: index,
        ),
      ),
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
    final sorted = List.of(bookmarks)..sort((a, b) => a.page.compareTo(b.page));
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Bookmarks',
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
                title: Text('Trang ${bm.page + 1}'),
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

/// Renders a single PDF page with progressive loading.
class _PdfPageWidget extends StatefulWidget {
  final PdfRenderService renderService;
  final int pageIndex;

  const _PdfPageWidget({
    super.key,
    required this.renderService,
    required this.pageIndex,
  });

  @override
  State<_PdfPageWidget> createState() => _PdfPageWidgetState();
}

class _PdfPageWidgetState extends State<_PdfPageWidget>
    with SingleTickerProviderStateMixin {
  ui.Image? _previewImage;
  ui.Image? _fullImage;
  bool _cancelled = false;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeIn = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _renderProgressive();
  }

  @override
  void dispose() {
    _cancelled = true;
    _fadeController.dispose();
    super.dispose();
  }

  bool _isCancelled() => _cancelled;

  Future<void> _renderProgressive() async {
    final preview = await widget.renderService.renderPage(
      widget.pageIndex,
      quality: 1.0,
      viewport: _viewportSize,
      isCancelled: _isCancelled,
    );
    if (_cancelled) return;
    if (preview != null) {
      setState(() => _previewImage = preview.image);
      _fadeController.forward();
    }

    final full = await widget.renderService.renderPage(
      widget.pageIndex,
      quality: 2.0,
      viewport: _viewportSize,
      isCancelled: _isCancelled,
    );
    if (_cancelled) return;
    setState(() => _fullImage = full?.image);
  }

  Size? get _viewportSize {
    final mq = MediaQuery.maybeOf(context);
    return mq?.size;
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeIn,
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_previewImage == null && _fullImage == null) {
      return _buildShimmer();
    }

    final displayImage = _fullImage ?? _previewImage;
    final quality =
        _fullImage != null ? FilterQuality.high : FilterQuality.low;

    return InteractiveViewer(
      minScale: 1.0,
      maxScale: 4.0,
      child: Center(
        child: RawImage(
          image: displayImage,
          fit: BoxFit.contain,
          filterQuality: quality,
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Center(
      child: _PulseAnimation(
        child: Container(
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Icon(Icons.description_outlined, size: 48),
          ),
        ),
      ),
    );
  }
}

class _PulseAnimation extends StatefulWidget {
  final Widget child;
  const _PulseAnimation({required this.child});

  @override
  State<_PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<_PulseAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: widget.child,
    );
  }
}
