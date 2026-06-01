import 'package:flutter/material.dart';
import '../../../models/book.dart';
import './book_card_ui_builder.dart';
import './book_card_logic.dart';

class BookCard extends StatefulWidget {
  final Book book;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onExportAnnotations;
  final VoidCallback? onLongPress;
  final bool selected;
  final bool selectionMode;

  const BookCard({
    super.key,
    required this.book,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.onExportAnnotations,
    this.onLongPress,
    this.selected = false,
    this.selectionMode = false,
  });

  @override
  State<BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
  late final BookCardLogic _logic;

  @override
  void initState() {
    super.initState();
    _logic = BookCardLogic(
      bookId: widget.book.id,
      filePath: widget.book.filePath,
    );
    _logic.resetForNewBook(widget.book.id, widget.book.filePath);
  }

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
    _logic.resetForNewBook(widget.book.id, widget.book.filePath);
    _loadThumbnail();
  }

  Future<void> _loadThumbnail() async {
    if (!widget.book.canRead || widget.book.filePath == null) return;
    await _logic.loadThumbnail(
      context: context,
      bookId: widget.book.id,
      filePath: widget.book.filePath,
    );
    if (mounted && widget.book.id == _logic.loadedBookId) {
      setState(() {});
    }
  }

  void _showMenu(BuildContext context) {
    BookCardUiBuilder.showMenu(
      context: context,
      book: widget.book,
      onRead: widget.onTap,
      onEdit: widget.onEdit,
      onDelete: widget.onDelete,
      onExportAnnotations: widget.onExportAnnotations,
    );
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    final colorScheme = Theme.of(context).colorScheme;
    final categoryColor = _logic.getCategoryColor(
      context: context,
      categoryId: book.categoryId,
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress ?? () => _showMenu(context),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Cover area
                Expanded(
                  child: BookCardUiBuilder.buildCover(
                    book: book,
                    thumbnail: _logic.thumbnail,
                    isLoading: _logic.isLoading,
                    colorScheme: colorScheme,
                    categoryColor: categoryColor,
                  ),
                ),
            // Progress bar with percentage
            if (book.canRead && book.totalPages > 0)
              BookCardUiBuilder.buildProgressBar(
                book: book,
                colorScheme: colorScheme,
              ),
            // Info section
            BookCardUiBuilder.buildInfo(
              context: context,
              book: book,
              colorScheme: colorScheme,
            ),
          ],
        ),
        if (widget.selected)
          Positioned(
            top: 4, right: 4,
            child: Icon(Icons.check_circle, color: colorScheme.primary),
          ),
        if (widget.selectionMode && !widget.selected)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }
}
