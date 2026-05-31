import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_reader/features/reader/controllers/text_cache.dart';

void main() {
  group('TextCache', () {
    test('get returns null for missing key', () {
      final cache = TextCache(maxSize: 3);
      expect(cache.get(1), isNull);
    });

    test('put and get roundtrip', () {
      final cache = TextCache(maxSize: 3);
      cache.put(1, null); // null is valid (page with no text)
      expect(cache.containsKey(1), true);
    });

    test('evicts LRU entry when full', () {
      final cache = TextCache(maxSize: 2);
      cache.put(1, null);
      cache.put(2, null);
      cache.put(3, null); // should evict key 1
      expect(cache.containsKey(1), false);
      expect(cache.containsKey(2), true);
      expect(cache.containsKey(3), true);
    });

    test('accessing entry updates LRU order', () {
      final cache = TextCache(maxSize: 2);
      cache.put(1, null);
      cache.put(2, null);
      cache.get(1); // access 1, so 2 becomes LRU
      cache.put(3, null); // should evict 2
      expect(cache.containsKey(1), true);
      expect(cache.containsKey(2), false);
      expect(cache.containsKey(3), true);
    });

    test('clear removes all entries', () {
      final cache = TextCache(maxSize: 5);
      cache.put(1, null);
      cache.put(2, null);
      cache.clear();
      expect(cache.containsKey(1), false);
      expect(cache.containsKey(2), false);
    });

    test('remove deletes specific entry', () {
      final cache = TextCache(maxSize: 5);
      cache.put(1, null);
      cache.put(2, null);
      cache.remove(1);
      expect(cache.containsKey(1), false);
      expect(cache.containsKey(2), true);
    });
  });
}
