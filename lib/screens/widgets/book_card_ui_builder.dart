import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../models/book.dart';
import '../../l10n/app_strings.dart';

class BookCardUiBuilder {
  static Widget buildCover({
    required Book book,
    required ui.Image? thumbnail,
    required bool isLoading,
    required ColorScheme colorScheme,
    required Color? categoryColor,
  }) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Thumbnail / placeholder
        if (thumbnail != null)
          RawImage(image: thumbnail, fit: BoxFit.cover)
        else if (isLoading)
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
          _buildPlaceholder(book, colorScheme, categoryColor),

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

  static Widget _buildPlaceholder(
    Book book,
    ColorScheme colorScheme,
    Color? categoryColor,
  ) {
    final baseColor = categoryColor ?? colorScheme.primary;
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

  static Widget buildProgressBar({
    required Book book,
    required ColorScheme colorScheme,
  }) {
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

  static Widget buildInfo({
    required BuildContext context,
    required Book book,
    required ColorScheme colorScheme,
  }) {
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

  static void showMenu({
    required BuildContext context,
    required Book book,
    required VoidCallback onRead,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    final s = AppStrings.of(context);
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
                  onRead();
                },
              ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text(s.edit),
              onTap: () {
                Navigator.pop(ctx);
                onEdit();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: Text(s.delete),
              onTap: () {
                Navigator.pop(ctx);
                onDelete();
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
}