import 'package:lru/lru.dart';
import 'package:pdfrx/pdfrx.dart';

/// LRU cache for PDF page text, backed by `lru` package.
class TextCache {
  final LruCache<int, PdfPageText> _cache;
  TextCache({int maxSize = 20}) : _cache = LruCache(maxSize);

  PdfPageText? get(int pageNumber) => _cache[pageNumber];
  void put(int pageNumber, PdfPageText? text) { if (text != null) _cache[pageNumber] = text; }
  void clear() => _cache.clear();
  bool containsKey(int pageNumber) => _cache.containsKey(pageNumber);
  void remove(int pageNumber) => _cache.remove(pageNumber);
}
