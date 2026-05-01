import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';
import 'package:pdfx/pdfx.dart';

/// Rendered page data at a specific quality level.
class RenderedPage {
  final int pageIndex;
  final ui.Image image;
  final double quality;

  RenderedPage({
    required this.pageIndex,
    required this.image,
    required this.quality,
  });
}

/// LRU cache for rendered PDF pages.
class PageCache {
  final int maxEntries;
  final LinkedHashMap<String, RenderedPage> _map = LinkedHashMap();

  PageCache({this.maxEntries = 8});

  String _key(int page, double quality) => '$page@$quality';

  /// Retrieves entry and marks it as recently used (moves to end).
  RenderedPage? get(int page, double quality) {
    final key = _key(page, quality);
    final entry = _map.remove(key);
    if (entry != null) {
      _map[key] = entry;
      return entry;
    }
    return null;
  }

  /// Checks if entry exists without changing LRU order.
  bool contains(int page, double quality) {
    return _map.containsKey(_key(page, quality));
  }

  void put(RenderedPage rendered) {
    final key = _key(rendered.pageIndex, rendered.quality);
    _map.remove(key);
    _map[key] = rendered;
    while (_map.length > maxEntries) {
      final oldest = _map.keys.first;
      final removed = _map.remove(oldest);
      removed?.image.dispose();
    }
  }

  void clear() {
    for (final entry in _map.values) {
      entry.image.dispose();
    }
    _map.clear();
  }
}

/// Manages PDF document lifecycle and on-demand page rendering.
/// All render calls are serialized to avoid concurrent native plugin access.
class PdfRenderService {
  PdfDocument? _document;
  int _pageCount = 0;
  final PageCache _cache = PageCache(maxEntries: 8);
  Future<void> _lastRender = Future.value();

  int get pageCount => _pageCount;

  Future<int> open(String filePath) async {
    await close();
    _document = await PdfDocument.openFile(filePath);
    _pageCount = _document!.pagesCount;
    return _pageCount;
  }

  /// Renders a single page. Calls are queued to prevent concurrent native access.
  Future<RenderedPage?> renderPage(
    int pageIndex, {
    double quality = 2.0,
    Size? viewport,
    bool Function()? isCancelled,
  }) async {
    if (_document == null || pageIndex < 0 || pageIndex >= _pageCount) {
      return null;
    }

    final cached = _cache.get(pageIndex, quality);
    if (cached != null) return cached;

    final completer = Completer<RenderedPage?>();
    final previous = _lastRender;
    _lastRender = completer.future.then((_) {});

    await previous;

    if (isCancelled?.call() == true || _document == null) {
      completer.complete(null);
      return null;
    }

    try {
      final result = await _doRender(pageIndex, quality, viewport, isCancelled);
      completer.complete(result);
      return result;
    } catch (e) {
      completer.complete(null);
      return null;
    }
  }

  Future<RenderedPage?> _doRender(
    int pageIndex,
    double quality,
    Size? viewport,
    bool Function()? isCancelled,
  ) async {
    final cached = _cache.get(pageIndex, quality);
    if (cached != null) return cached;

    final page = await _document!.getPage(pageIndex + 1);

    final double scale = quality;
    final double renderWidth;
    final double renderHeight;

    if (viewport != null) {
      renderWidth = viewport.width * scale;
      renderHeight = (viewport.width * page.height / page.width) * scale;
    } else {
      renderWidth = page.width * scale;
      renderHeight = page.height * scale;
    }

    final pageImage = await page.render(
      width: renderWidth,
      height: renderHeight,
      format: PdfPageImageFormat.png,
      quality: 90,
    );

    await page.close();

    if (pageImage == null) return null;
    if (isCancelled?.call() == true) return null;

    final ui.Image image = await _decodeImage(pageImage.bytes);

    final rendered = RenderedPage(
      pageIndex: pageIndex,
      image: image,
      quality: quality,
    );
    _cache.put(rendered);
    return rendered;
  }

  /// Pre-renders adjacent pages (non-blocking, uses `contains` to avoid LRU churn).
  void preloadAround(int currentPage, {Size? viewport}) {
    final pagesToPreload = <int>[
      currentPage - 1,
      currentPage + 1,
      currentPage - 2,
      currentPage + 2,
    ].where((p) => p >= 0 && p < _pageCount);

    for (final p in pagesToPreload) {
      if (!_cache.contains(p, 2.0)) {
        unawaited(renderPage(p, quality: 2.0, viewport: viewport));
      }
    }
  }

  Future<ui.Image> _decodeImage(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    codec.dispose();
    return frame.image;
  }

  Future<void> close() async {
    _cache.clear();
    await _document?.close();
    _document = null;
    _pageCount = 0;
  }
}
