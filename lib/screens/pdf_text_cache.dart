import 'package:pdfrx/pdfrx.dart';

/// Simple LRU (Least Recently Used) cache for PDF page text.
class TextCache {
  final int maxSize;
  final Map<int, PdfPageText?> _cache = {};
  final List<int> _accessOrder = [];

  TextCache({this.maxSize = 20});

  PdfPageText? get(int pageNumber) {
    if (_cache.containsKey(pageNumber)) {
      _accessOrder.remove(pageNumber);
      _accessOrder.add(pageNumber);
      return _cache[pageNumber];
    }
    return null;
  }

  void put(int pageNumber, PdfPageText? text) {
    if (_cache.containsKey(pageNumber)) {
      _cache[pageNumber] = text;
      _accessOrder.remove(pageNumber);
      _accessOrder.add(pageNumber);
    } else {
      if (_cache.length >= maxSize) {
        final lruKey = _accessOrder.first;
        _cache.remove(lruKey);
        _accessOrder.remove(lruKey);
      }
      _cache[pageNumber] = text;
      _accessOrder.add(pageNumber);
    }
  }

  void clear() { _cache.clear(); _accessOrder.clear(); }
  bool containsKey(int pageNumber) => _cache.containsKey(pageNumber);
  void remove(int pageNumber) { _cache.remove(pageNumber); _accessOrder.remove(pageNumber); }
}
