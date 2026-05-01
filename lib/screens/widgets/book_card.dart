import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../main.dart';
import '../../models/book.dart';
import '../../l10n/app_strings.dart';

/// Book card widget for grid view — shows cover thumbnail.
class BookCard extends StatefulWidget {
  final Book book;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BookCard({
    super.key,
    required this.book,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
  ui.Image? _thumbnail;
  String? _loadedBookId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadThumbnailIfNeeded();
  }

  @override
  void didUpdateWidget(BookCard oldWidget) {
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
      width: 300,
    );
    if (mounted && widget.book.id == _loadedBookId && img != null) {
      setState(() => _thumbnail = img);
    }
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: widget.onTap,
        onLongPress: () => _showMenu(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _thumbnail != null
                  ? RawImage(image: _thumbnail, fit: BoxFit.cover)
                  : Container(
                      color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                      child: Icon(
                        _formatIcon(book.format),
                        size: 48,
                        color: colorScheme.onPrimaryContainer
                            .withValues(alpha: 0.5),
                      ),
                    ),
            ),
            if (book.canRead && book.totalPages > 0)
              LinearProgressIndicator(
                value: book.progressPercent,
                minHeight: 3,
              ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (book.author.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      book.author,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (book.categoryId != null) ...[
                    const SizedBox(height: 4),
                    _buildCategoryChip(context, book.categoryId!),
                  ],
                  if (book.readingSeconds > 0) ...[
                    const SizedBox(height: 2),
                    Text(
                      book.readingTimeFormatted,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    final s = AppStrings.of(context);
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text(s.edit),
              onTap: () {
                Navigator.pop(ctx);
                widget.onEdit();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: Text(s.delete),
              onTap: () {
                Navigator.pop(ctx);
                widget.onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }

  static IconData _formatIcon(BookFormat format) {
    switch (format) {
      case BookFormat.paper:
        return Icons.menu_book;
      case BookFormat.ebook:
        return Icons.tablet_android;
      case BookFormat.both:
        return Icons.library_books;
    }
  }

  Widget _buildCategoryChip(BuildContext context, String categoryId) {
    final catService = CategoryServiceScope.of(context);
    final cat = catService.getById(categoryId);
    if (cat == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Color(cat.colorValue).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        cat.name,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Color(cat.colorValue),
            ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
