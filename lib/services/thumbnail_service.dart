import 'dart:ui' as ui;
import 'package:pdfx/pdfx.dart';

/// Generates and caches PDF thumbnail images.
class ThumbnailService {
  final Map<String, ui.Image> _cache = {};

  /// Returns a thumbnail for the first page of the PDF at [filePath].
  /// [width] controls render resolution. Cached by filePath + width.
  Future<ui.Image?> getThumbnail(String filePath, {double width = 200}) async {
    final key = '$filePath@$width';
    if (_cache.containsKey(key)) return _cache[key];

    try {
      final doc = await PdfDocument.openFile(filePath);
      final page = await doc.getPage(1);
      final height = width * page.height / page.width;

      final img = await page.render(
        width: width,
        height: height,
        format: PdfPageImageFormat.png,
        quality: 85,
      );
      await page.close();
      await doc.close();

      if (img == null) return null;

      final codec = await ui.instantiateImageCodec(img.bytes);
      final frame = await codec.getNextFrame();
      codec.dispose();

      _cache[key] = frame.image;
      return frame.image;
    } catch (_) {
      return null;
    }
  }

  void evict(String filePath) {
    _cache.removeWhere((key, img) {
      if (key.startsWith(filePath)) {
        img.dispose();
        return true;
      }
      return false;
    });
  }

  void clear() {
    for (final img in _cache.values) {
      img.dispose();
    }
    _cache.clear();
  }
}
