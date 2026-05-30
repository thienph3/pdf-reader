import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../models/book.dart';

class BookCardCover {
  static Widget build({
    required Book book, required ui.Image? thumbnail,
    required bool isLoading, required ColorScheme colorScheme, required Color? categoryColor,
  }) {
    return Stack(fit: StackFit.expand, children: [
      if (thumbnail != null)
        RawImage(image: thumbnail, fit: BoxFit.cover, filterQuality: FilterQuality.medium)
      else if (isLoading)
        Container(color: colorScheme.surfaceContainerHighest, child: const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))))
      else
        _buildPlaceholder(book, colorScheme, categoryColor),
      if (categoryColor != null)
        Positioned(top: -2, right: 8, child: SizedBox(width: 16, height: 28, child: CustomPaint(painter: BookmarkBadgePainter(color: categoryColor)))),
    ]);
  }

  static Widget _buildPlaceholder(Book book, ColorScheme colorScheme, Color? categoryColor) {
    final baseColor = categoryColor ?? colorScheme.primary;
    return Container(
      decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [baseColor.withValues(alpha: 0.7), baseColor.withValues(alpha: 0.3)])),
      padding: const EdgeInsets.all(12),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(_formatIcon(book.format), size: 36, color: Colors.white.withValues(alpha: 0.8)),
        const SizedBox(height: 8),
        Text(book.title, style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 11, fontWeight: FontWeight.w600), maxLines: 3, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
      ]),
    );
  }

  static IconData _formatIcon(BookFormat format) {
    switch (format) { case BookFormat.paper: return Icons.menu_book; case BookFormat.ebook: return Icons.tablet_android; case BookFormat.both: return Icons.library_books; }
  }
}

class BookmarkBadgePainter extends CustomPainter {
  final Color color;
  const BookmarkBadgePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final shadow = Paint()..color = Colors.black.withValues(alpha: 0.25)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
    final path = Path()..moveTo(0, 0)..lineTo(size.width, 0)..lineTo(size.width, size.height)..lineTo(size.width / 2, size.height * 0.7)..lineTo(0, size.height)..close();
    canvas.drawPath(path.shift(const Offset(0.5, 0.5)), shadow);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(BookmarkBadgePainter oldDelegate) => color != oldDelegate.color;
}
