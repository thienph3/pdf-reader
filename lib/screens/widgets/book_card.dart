import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../main.dart';
import '../../models/book.dart';
import '../../l10n/app_strings.dart';

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
  bool _isLoading = false;

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
    _isLoading = widget.book.canRead;
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
    if (mounted && widget.book.id == _loadedBookId) {
      setState(() {
        _thumbnail = img;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: widget.onTap,
        onLongPress: () => _showMenu(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cover area
            Expanded(child: _buildCover(book, colorScheme)),
            // Progress bar with percentage
            if (book.canRead && book.totalPages > 0)
              _buildProgressBar(book, colorScheme),
            // Info section
            _buildInfo(book, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildCover(Book book, ColorScheme colorScheme) {
    final categoryColor = _getCategoryColor(book);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Thumbnail / placeholder
        if (_thumbnail != null)
          RawImage(image: _thumbnail, fit: BoxFit.cover)
        else if (_isLoading)
          Container(
            color: colorScheme.surfaceContainerHighest,
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        else
          _buildPlaceholder(book, colorScheme),

        // Category color dot (top-right)
        if (categoryColor != null)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: categoryColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  /// Gradient placeholder with book icon + title for books without thumbnail.
  Widget _buildPlaceholder(Book book, ColorScheme colorScheme) {
    final baseColor = _getCategoryColor(book) ?? colorScheme.primary;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            baseColor.withValues(alpha: 0.7),
            baseColor.withValues(alpha: 0.3),
          ],
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _formatIcon(book.format),
            size: 36,
            color: Colors.white.withValues(alpha: 0.8),
          ),
          const SizedBox(height: 8),
          Text(
            book.title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(Book book, ColorScheme colorScheme) {
    final percent = (book.progressPercent * 100).toInt();
    return Container(
      height: 16,
      color: colorScheme.surfaceContainerHighest,
      child: Stack(
        children: [
          FractionallySizedBox(
            widthFactor: book.progressPercent,
            child: Container(color: colorScheme.primary.withValues(alpha: 0.3)),
          ),
          Center(
            child: Text(
              '$percent%',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfo(Book book, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          if (book.readingSeconds > 0) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.schedule,
                    size: 12, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  book.readingTimeFormatted,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showMenu(BuildContext context) {
    final s = AppStrings.of(context);
    final book = widget.book;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (book.canRead)
              ListTile(
                leading: const Icon(Icons.chrome_reader_mode_outlined),
                title: Text(s.readBook),
                onTap: () {
                  Navigator.pop(ctx);
                  widget.onTap();
                },
              ),
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

  Color? _getCategoryColor(Book book) {
    if (book.categoryId == null) return null;
    final catService = CategoryServiceScope.of(context);
    final cat = catService.getById(book.categoryId!);
    return cat != null ? Color(cat.colorValue) : null;
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
}
