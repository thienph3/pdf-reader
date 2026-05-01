import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../models/book.dart';
import '../../main.dart';

/// Compact recent book item — thumbnail only, no info section.
class RecentBookItem extends StatefulWidget {
  final Book book;
  final VoidCallback onTap;

  const RecentBookItem({super.key, required this.book, required this.onTap});

  @override
  State<RecentBookItem> createState() => _RecentBookItemState();
}

class _RecentBookItemState extends State<RecentBookItem> {
  ui.Image? _thumbnail;
  String? _loadedBookId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadIfNeeded();
  }

  @override
  void didUpdateWidget(RecentBookItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.book.id != widget.book.id) _loadIfNeeded();
  }

  void _loadIfNeeded() {
    if (_loadedBookId == widget.book.id) return;
    _loadedBookId = widget.book.id;
    _thumbnail = null;
    _load();
  }

  Future<void> _load() async {
    if (!widget.book.canRead || widget.book.filePath == null) return;
    final svc = ThumbnailServiceScope.of(context);
    final img = await svc.getThumbnail(
      bookId: widget.book.id,
      filePath: widget.book.filePath!,
      width: 200,
    );
    if (mounted && widget.book.id == _loadedBookId && img != null) {
      setState(() => _thumbnail = img);
    }
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: 90,
        child: Column(
          children: [
            // Cover
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _thumbnail != null
                    ? RawImage(image: _thumbnail, fit: BoxFit.cover)
                    : Container(
                        color: colorScheme.primaryContainer
                            .withValues(alpha: 0.3),
                        child: Icon(
                          Icons.menu_book,
                          color: colorScheme.onPrimaryContainer
                              .withValues(alpha: 0.5),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 4),
            // Title only — 1 line
            Text(
              book.title,
              style: Theme.of(context).textTheme.labelSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
