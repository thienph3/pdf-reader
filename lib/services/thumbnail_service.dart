import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfrx/pdfrx.dart';

/// Generates, caches (memory + disk), and serves PDF thumbnail images.
class ThumbnailService {
  static const _maxMemCacheSize = 25;
  final Map<String, ui.Image> _memCache = {};
  final List<String> _accessOrder = [];
  final Map<String, Future<ui.Image?>> _inFlight = {};
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

  Future<ui.Image?> getThumbnail({
    required String bookId,
    required String filePath,
    double width = 200,
  }) async {
    final cacheKey = '${bookId}_${width.toInt()}';

    // 1. Memory cache
    if (_memCache.containsKey(cacheKey)) {
      _accessOrder.remove(cacheKey);
      _accessOrder.add(cacheKey);
      return _memCache[cacheKey];
    }

    // 2. Deduplicate in-flight requests
    if (_inFlight.containsKey(cacheKey)) {
      return _inFlight[cacheKey];
    }

    final future = _loadThumbnail(cacheKey, bookId, filePath, width);
    _inFlight[cacheKey] = future;
    try {
      return await future;
    } finally {
      _inFlight.remove(cacheKey);
    }
  }

  Future<ui.Image?> _loadThumbnail(String cacheKey, String bookId, String filePath, double width) async {

    try {
      // 2. Disk cache
      final dir = await _getCacheDir();
      final cacheFile = File('$dir/$cacheKey.png');

      if (await cacheFile.exists()) {
        final bytes = await cacheFile.readAsBytes();
        final image = await _decodeImage(bytes);
        if (image != null) {
          _memCache[cacheKey] = image;
          _accessOrder.add(cacheKey);
          _evictIfNeeded();
          return image;
        }
      }

      // 3. Render from PDF
      if (!await File(filePath).exists()) {
        debugPrint('ThumbnailService: File not found: $filePath');
        return null;
      }

      final doc = await PdfDocument.openFile(filePath);
      if (doc.pages.isEmpty) {
        debugPrint('ThumbnailService: PDF has no pages: $filePath');
        return null;
      }

      final page = doc.pages[0];
      final height = width * page.height / page.width;

      debugPrint('ThumbnailService: Rendering thumbnail for $bookId, size: ${width}x$height');
      
      final rendered = await page.render(
        fullWidth: width,
        fullHeight: height,
      );

      if (rendered == null) {
        debugPrint('ThumbnailService: Render returned null for $bookId');
        return null;
      }

      // Use the PdfImage.createImage() extension method from pdfrx_flutter.dart
      ui.Image? image;
      try {
        image = await rendered.createImage();
        debugPrint('ThumbnailService: Successfully created thumbnail for $bookId');
      } catch (e) {
        debugPrint('ThumbnailService: Failed to create image for $bookId: $e');
        return null;
      }

      // Save PNG to disk cache for next launch
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        await cacheFile.writeAsBytes(byteData.buffer.asUint8List());
        debugPrint('ThumbnailService: Saved thumbnail to disk cache: $cacheKey');
      }

      _memCache[cacheKey] = image;
      _accessOrder.add(cacheKey);
      _evictIfNeeded();
      return image;
    } catch (e) {
      debugPrint('ThumbnailService error for $bookId: $e');
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

  void _evictIfNeeded() {
    while (_memCache.length > _maxMemCacheSize && _accessOrder.isNotEmpty) {
      final lruKey = _accessOrder.removeAt(0);
      _memCache.remove(lruKey)?.dispose();
    }
  }

  void evict(String bookId) {
    _memCache.removeWhere((key, img) {
      if (key.startsWith(bookId)) {
        img.dispose();
        _accessOrder.remove(key);
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
    _accessOrder.clear();
  }
}
