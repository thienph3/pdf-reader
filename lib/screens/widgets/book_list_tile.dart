import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../main.dart';
import '../../models/book.dart';
import '../../l10n/app_strings.dart';

/// Book list tile widget for list view.
class BookListTile extends StatefulWidget {
  final Book book;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BookListTile({
    super.key,
    required this.book,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<BookListTile> createState() => _BookListTileState();
}

class _BookListTileState extends State<BookListTile> {
  ui.Image? _thumbnail;
  String? _loadedBookId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadThumbnailIfNeeded();
  }

  @override
  void didUpdateWidget(BookListTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.book.id != widget.book.id ||
        oldWidget.book.filePath != widget.book.filePath) {
      _loadThumbnailIfNeeded();
    }
  }

  void _loadThumbnailIfNeeded() {
    if (_loadedBookId == widget.book.id) return;
    _loadedBookId = widget.book.id;
    _thumbnail = null;
    _loadThumbnail();
  }

  Future<void> _loadThumbnail() async {
    if (!widget.book.canRead || widget.book.filePath == null) return;
    final svc = ThumbnailServiceScope.of(context);
    final img = await svc.getThumbnail(
      bookId: widget.book.id,
      filePath: widget.book.filePath!,
      width: 80,
    );
    if (mounted && widget.book.id == _loadedBookId && img != null) {
      setState(() => _thumbnail = img);
    }
  }

  String get _formatLabel {
    final s = AppStrings.of(context);
    switch (widget.book.format) {
      case BookFormat.paper:
        return s.paperBook;
      case BookFormat.ebook:
        return s.ebookLabel;
      case BookFormat.both:
        return s.paperAndEbook;
    }
  }

  String? get _categoryName {
    if (widget.book.categoryId == null) return null;
    final catService = CategoryServiceScope.of(context);
    return catService.getById(widget.book.categoryId!)?.name;
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

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
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
              _categoryName,
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
              tooltip: s.readBook,
              onPressed: widget.onTap,
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') widget.onEdit();
              if (value == 'delete') widget.onDelete();
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'edit', child: Text(s.edit)),
              PopupMenuItem(value: 'delete', child: Text(s.delete)),
            ],
          ),
        ],
      ),
      onTap: widget.onTap,
    );
  }
}
