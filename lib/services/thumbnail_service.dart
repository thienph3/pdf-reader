import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfrx/pdfrx.dart';

/// Generates, caches (memory + disk), and serves PDF thumbnail images.
/// Uses book ID as cache key to avoid collisions from file_picker temp paths.
class ThumbnailService {
  final Map<String, ui.Image> _memCache = {};
  String? _cacheDir;

  Future<String> _getCacheDir() async {
    if (_cacheDir != null) return _cacheDir!;
    final dir = await getApplicationCacheDirectory();
    final thumbDir = Directory('${dir.path}/thumbnails');
    if (!await thumbDir.exists()) {
      await thumbDir.create(recursive: true);
    }
    _cacheDir = thumbDir.path;
    return _cacheDir!;
  }

  /// Returns a thumbnail for the first page of the PDF.
  /// [bookId] is used as cache key (unique per book).
  /// Checks: memory cache → disk cache → render from PDF.
  Future<ui.Image?> getThumbnail({
    required String bookId,
    required String filePath,
    double width = 200,
  }) async {
    final cacheKey = '${bookId}_${width.toInt()}';

    // 1. Memory cache
    if (_memCache.containsKey(cacheKey)) return _memCache[cacheKey];

    // 2. Disk cache
    try {
      final dir = await _getCacheDir();
      final cacheFile = File('$dir/$cacheKey.png');

      if (await cacheFile.exists()) {
        final bytes = await cacheFile.readAsBytes();
        final image = await _decodeImage(bytes);
        if (image != null) {
          _memCache[cacheKey] = image;
          return image;
        }
      }

      // 3. Render from PDF using pdfrx
      if (!await File(filePath).exists()) return null;

      final doc = await PdfDocument.openFile(filePath);
      if (doc.pages.isEmpty) return null;

      final page = doc.pages[0];
      final height = width * page.height / page.width;

      final rendered = await page.render(
        fullWidth: width,
        fullHeight: height,
      );

      if (rendered == null) return null;

      final pixels = rendered.pixels;
      final pngBytes = await _encodePng(
        pixels,
        rendered.width,
        rendered.height,
      );

      if (pngBytes == null) return null;

      // Save to disk cache
      await cacheFile.writeAsBytes(pngBytes);

      // Decode to ui.Image
      final image = await _decodeImage(pngBytes);
      if (image != null) {
        _memCache[cacheKey] = image;
      }
      return image;
    } catch (e) {
      debugPrint('ThumbnailService error for $bookId: $e');
      return null;
    }
  }

  /// Encode raw RGBA pixels to PNG via ui.Image.
  Future<Uint8List?> _encodePng(
      Uint8List pixels, int width, int height) async {
    try {
      final codec = await ui.instantiateImageCodecFromBuffer(
        await ui.ImmutableBuffer.fromUint8List(pixels),
        targetWidth: width,
        targetHeight: height,
      );
      final frame = await codec.getNextFrame();
      final byteData =
          await frame.image.toByteData(format: ui.ImageByteFormat.png);
      codec.dispose();
      frame.image.dispose();
      return byteData?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  Future<ui.Image?> _decodeImage(Uint8List bytes) async {
    try {
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      codec.dispose();
      return frame.image;
    } catch (_) {
      return null;
    }
  }

  void evict(String bookId) {
    _memCache.removeWhere((key, img) {
      if (key.startsWith(bookId)) {
        img.dispose();
        return true;
      }
      return false;
    });
    _getCacheDir().then((dir) {
      for (final w in [80, 200, 300]) {
        File('$dir/${bookId}_$w.png').delete().catchError((_) => File(''));
      }
    });
  }

  void clear() {
    for (final img in _memCache.values) {
      img.dispose();
    }
    _memCache.clear();
  }
}
