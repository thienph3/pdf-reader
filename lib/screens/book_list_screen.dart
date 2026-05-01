import 'dart:io' as io;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../main.dart';
import '../models/book.dart';
import '../services/book_service.dart';
import 'book_form_screen.dart';
import 'pdf_view_screen.dart';

Route<T> buildPageRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 400),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, animation, __) => page,
    transitionsBuilder: (_, animation, __, child) {
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.05),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        ),
      );
    },
  );
}

enum SortMode { updatedDesc, titleAsc, createdDesc }

class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  List<Book> _books = [];
  bool _isSearching = false;
  bool _initialized = false;
  SortMode _sortMode = SortMode.updatedDesc;

  final TextEditingController _searchCtrl = TextEditingController();

  BookService get _bookService => BookServiceScope.of(context);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _refresh();
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _refresh() => setState(() => _books = _bookService.getAll());

  List<Book> get _filteredAndSorted {
    var result = _books;
    final q = _searchCtrl.text.toLowerCase();
    if (q.isNotEmpty) {
      result = result
          .where((b) =>
              b.title.toLowerCase().contains(q) ||
              b.author.toLowerCase().contains(q))
          .toList();
    }
    switch (_sortMode) {
      case SortMode.updatedDesc:
        break;
      case SortMode.titleAsc:
        result = List.of(result)
          ..sort(
              (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      case SortMode.createdDesc:
        result = List.of(result)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return result;
  }

  Future<void> _addBook() async {
    final created = await Navigator.push<bool>(
        context, buildPageRoute(const BookFormScreen()));
    if (created == true) _refresh();
  }

  Future<void> _editBook(Book book) async {
    final updated = await Navigator.push<bool>(
        context, buildPageRoute(BookFormScreen(book: book)));
    if (updated == true) _refresh();
  }

  Future<void> _deleteBook(Book book) async {
    await _bookService.delete(book.id);
    _refresh();
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${book.title}" đã xoá'),
        action: SnackBarAction(
          label: 'Hoàn tác',
          onPressed: () async {
            await _bookService.restore(book);
            _refresh();
          },
        ),
      ),
    );
  }

  Future<void> _confirmDeleteBook(Book book) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xoá sách'),
        content: Text('Bạn muốn xoá "${book.title}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Huỷ')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Xoá')),
        ],
      ),
    );
    if (confirm == true) _deleteBook(book);
  }

  Future<void> _openBook(Book book) async {
    if (!book.canRead) return;
    final file = await _validatePath(book);
    if (file == null || !mounted) return;
    await Navigator.push(
      context,
      buildPageRoute(PdfViewScreen(
        filePath: file,
        fileName: book.title,
        bookId: book.id,
        initialPage: book.lastPage,
      )),
    );
    _refresh();
  }

  Future<String?> _validatePath(Book book) async {
    final path = book.filePath;
    if (path != null && path.isNotEmpty) {
      if (await io.File(path).exists()) return path;
    }
    if (!mounted) return null;
    final shouldRepick = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('File không tồn tại'),
        content: const Text('Đường dẫn ebook không hợp lệ. Chọn lại file?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Huỷ')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Chọn lại')),
        ],
      ),
    );
    if (shouldRepick != true || !mounted) return null;
    final result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null && result.files.single.path != null) {
      final newPath = result.files.single.path!;
      await _bookService.update(book.copyWith(filePath: () => newPath));
      _refresh();
      return newPath;
    }
    return null;
  }

  // --- Export / Import ---

  Future<void> _exportBooks() async {
    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Xuất thư viện',
      fileName: 'books_backup.json',
    );
    if (path == null) return;
    await _bookService.exportToFile(path);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã xuất thư viện thành công')),
    );
  }

  Future<void> _importBooks() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null || result.files.single.path == null) return;
    final count = await _bookService.importFromFile(result.files.single.path!);
    _refresh();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã nhập $count sách mới')),
    );
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) _searchCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredAndSorted;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Tìm theo tên hoặc tác giả...',
                  border: InputBorder.none,
                ),
                onChanged: (_) => setState(() {}),
              )
            : const Text('Thư viện sách'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
          if (!_isSearching) ...[
            PopupMenuButton<SortMode>(
              icon: const Icon(Icons.sort),
              tooltip: 'Sắp xếp',
              onSelected: (mode) => setState(() => _sortMode = mode),
              itemBuilder: (_) => [
                _sortMenuItem(SortMode.updatedDesc, 'Mới cập nhật'),
                _sortMenuItem(SortMode.titleAsc, 'Tên A-Z'),
                _sortMenuItem(SortMode.createdDesc, 'Mới thêm'),
              ],
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (v) {
                if (v == 'export') _exportBooks();
                if (v == 'import') _importBooks();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'export', child: Text('Xuất thư viện')),
                PopupMenuItem(value: 'import', child: Text('Nhập thư viện')),
              ],
            ),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addBook,
        child: const Icon(Icons.add),
      ),
      body: filtered.isEmpty ? _buildEmptyState() : _buildList(filtered),
    );
  }

  PopupMenuItem<SortMode> _sortMenuItem(SortMode mode, String label) {
    return PopupMenuItem(
      value: mode,
      child: Row(
        children: [
          if (_sortMode == mode)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.check, size: 18),
            ),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;
    final hasQuery = _searchCtrl.text.isNotEmpty;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasQuery ? Icons.search_off : Icons.library_books,
            size: 64,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            hasQuery ? 'Không tìm thấy sách.' : 'Chưa có sách nào.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (!hasQuery) ...[
            const SizedBox(height: 8),
            Text(
              'Bấm + để thêm sách mới',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildList(List<Book> books) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return Dismissible(
          key: ValueKey(book.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            color: Theme.of(context).colorScheme.error,
            child: Icon(Icons.delete,
                color: Theme.of(context).colorScheme.onError),
          ),
          confirmDismiss: (_) async {
            _deleteBook(book);
            return false;
          },
          child: _BookTile(
            book: book,
            onTap: () => book.canRead ? _openBook(book) : _editBook(book),
            onEdit: () => _editBook(book),
            onDelete: () => _confirmDeleteBook(book),
          ),
        );
      },
    );
  }
}

/// Book list tile with thumbnail, progress bar, and reading stats.
class _BookTile extends StatefulWidget {
  final Book book;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BookTile({
    required this.book,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_BookTile> createState() => _BookTileState();
}

class _BookTileState extends State<_BookTile> {
  ui.Image? _thumbnail;

  @override
  void initState() {
    super.initState();
    _loadThumbnail();
  }

  Future<void> _loadThumbnail() async {
    if (!widget.book.canRead || widget.book.filePath == null) return;
    final svc = ThumbnailServiceScope.of(context);
    final img = await svc.getThumbnail(widget.book.filePath!);
    if (mounted && img != null) setState(() => _thumbnail = img);
  }

  String get _formatLabel {
    switch (widget.book.format) {
      case BookFormat.paper:
        return 'Sách giấy';
      case BookFormat.ebook:
        return 'Ebook';
      case BookFormat.both:
        return 'Giấy + Ebook';
    }
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: SizedBox(
        width: 40,
        height: 56,
        child: _thumbnail != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: RawImage(image: _thumbnail, fit: BoxFit.cover),
              )
            : CircleAvatar(
                backgroundColor: colorScheme.primaryContainer,
                child: Icon(_formatIcon, color: colorScheme.onPrimaryContainer),
              ),
      ),
      title: Text(book.title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            [
              if (book.author.isNotEmpty) book.author,
              _formatLabel,
              if (book.readingSeconds > 0) book.readingTimeFormatted,
            ].join(' · '),
          ),
          if (book.canRead && book.totalPages > 0) ...[
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: book.progressPercent,
              minHeight: 3,
              borderRadius: BorderRadius.circular(2),
            ),
          ],
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (book.canRead)
            IconButton(
              icon: const Icon(Icons.chrome_reader_mode_outlined),
              tooltip: 'Đọc sách',
              onPressed: widget.onTap,
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') widget.onEdit();
              if (value == 'delete') widget.onDelete();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Sửa')),
              PopupMenuItem(value: 'delete', child: Text('Xoá')),
            ],
          ),
        ],
      ),
      onTap: widget.onTap,
    );
  }

  IconData get _formatIcon {
    switch (widget.book.format) {
      case BookFormat.paper:
        return Icons.menu_book;
      case BookFormat.ebook:
        return Icons.tablet_android;
      case BookFormat.both:
        return Icons.library_books;
    }
  }
}
