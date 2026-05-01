import 'dart:ui' as ui;
import 'package:pdfx/pdfx.dart';

/// Generates and caches PDF thumbnail images.
class ThumbnailService {
  final Map<String, ui.Image> _cache = {};

  /// Returns a thumbnail for the first page of the PDF at [filePath].
  /// Cached by file path.
  Future<ui.Image?> getThumbnail(String filePath, {double width = 80}) async {
    if (_cache.containsKey(filePath)) return _cache[filePath];

    try {
      final doc = await PdfDocument.openFile(filePath);
      final page = await doc.getPage(1);
      final height = width * page.height / page.width;

      final img = await page.render(
        width: width,
        height: height,
        format: PdfPageImageFormat.png,
        quality: 80,
      );
      await page.close();
      await doc.close();

      if (img == null) return null;

      final codec = await ui.instantiateImageCodec(img.bytes);
      final frame = await codec.getNextFrame();
      codec.dispose();

      _cache[filePath] = frame.image;
      return frame.image;
    } catch (_) {
      return null;
    }
  }

  void evict(String filePath) {
    _cache.remove(filePath)?.dispose();
  }

  void clear() {
    for (final img in _cache.values) {
      img.dispose();
    }
    _cache.clear();
  }
}
