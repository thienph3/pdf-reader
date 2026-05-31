import 'package:flutter_test/flutter_test.dart';

/// Tests reading queue ordering logic (pure list operations).
/// Mirrors ReadingQueueService behavior without Hive.
class TestQueue {
  final List<String> _items = [];

  List<String> get items => List.unmodifiable(_items);

  void add(String id) {
    if (!_items.contains(id)) _items.add(id);
  }

  void remove(String id) => _items.remove(id);

  void reorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final item = _items.removeAt(oldIndex);
    _items.insert(newIndex, item);
  }
}

void main() {
  group('Reading queue maintains correct order', () {
    late TestQueue queue;

    setUp(() => queue = TestQueue());

    test('adding books preserves insertion order', () {
      queue.add('book-1');
      queue.add('book-2');
      queue.add('book-3');
      expect(queue.items, ['book-1', 'book-2', 'book-3']);
    });

    test('duplicate books are not added twice', () {
      queue.add('book-1');
      queue.add('book-1');
      expect(queue.items, ['book-1']);
    });

    test('removing a book from middle preserves order of others', () {
      queue.add('a');
      queue.add('b');
      queue.add('c');
      queue.remove('b');
      expect(queue.items, ['a', 'c']);
    });

    test('reorder moves item forward', () {
      queue.add('a');
      queue.add('b');
      queue.add('c');
      queue.reorder(2, 0); // move 'c' to front
      expect(queue.items, ['c', 'a', 'b']);
    });

    test('reorder moves item backward', () {
      queue.add('a');
      queue.add('b');
      queue.add('c');
      queue.reorder(0, 3); // move 'a' to end
      expect(queue.items, ['b', 'c', 'a']);
    });

    test('removing non-existent book does nothing', () {
      queue.add('a');
      queue.remove('z');
      expect(queue.items, ['a']);
    });

    test('empty queue returns empty list', () {
      expect(queue.items, isEmpty);
    });
  });
}
