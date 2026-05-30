import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../models/book.dart';
import '../../l10n/app_strings.dart';
import 'book_card_cover.dart';

class BookCardUiBuilder {
  static Widget buildCover({
    required Book book, required ui.Image? thumbnail,
    required bool isLoading, required ColorScheme colorScheme, required Color? categoryColor,
  }) => BookCardCover.build(book: book, thumbnail: thumbnail, isLoading: isLoading, colorScheme: colorScheme, categoryColor: categoryColor);

  static Widget buildProgressBar({required Book book, required ColorScheme colorScheme}) {
    final percent = (book.progressPercent * 100).toInt();
    return Container(
      height: 16, color: colorScheme.surfaceContainerHighest,
      child: Stack(children: [
        FractionallySizedBox(widthFactor: book.progressPercent, child: Container(color: colorScheme.primary.withValues(alpha: 0.3))),
        Center(child: Text('$percent%', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: colorScheme.onSurfaceVariant))),
      ]),
    );
  }

  static Widget buildInfo({required BuildContext context, required Book book, required ColorScheme colorScheme}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(book.title, style: Theme.of(context).textTheme.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
        if (book.author.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(book.author, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
        if (book.readingSeconds > 0) ...[
          const SizedBox(height: 4),
          Row(children: [
            Icon(Icons.schedule, size: 12, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(book.readingTimeFormatted, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
          ]),
        ],
      ]),
    );
  }

  static void showMenu({
    required BuildContext context, required Book book,
    required VoidCallback onRead, required VoidCallback onEdit,
    required VoidCallback onDelete, VoidCallback? onExportAnnotations,
  }) {
    final s = AppStrings.of(context);
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          if (book.canRead) ListTile(leading: const Icon(Icons.chrome_reader_mode_outlined), title: Text(s.readBook), onTap: () { Navigator.pop(ctx); onRead(); }),
          ListTile(leading: const Icon(Icons.edit), title: Text(s.edit), onTap: () { Navigator.pop(ctx); onEdit(); }),
          if (onExportAnnotations != null && (book.highlights.isNotEmpty || book.bookmarks.isNotEmpty))
            ListTile(leading: const Icon(Icons.file_download_outlined), title: Text(s.exportAnnotations), onTap: () { Navigator.pop(ctx); onExportAnnotations(); }),
          ListTile(leading: const Icon(Icons.delete), title: Text(s.delete), onTap: () { Navigator.pop(ctx); onDelete(); }),
        ]),
      ),
    );
  }
}
