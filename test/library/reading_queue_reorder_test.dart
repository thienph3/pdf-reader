import 'package:flutter_test/flutter_test.dart';

/// Mirrors ReadingQueueService.reorder with bounds checking.
class TestQueue {
  final List<String> items = [];

  void add(String id) { if (!items.contains(id)) items.add(id); }

  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= items.length) return;
    if (newIndex < 0 || newIndex > items.length) return;
    if (newIndex > oldIndex) newIndex--;
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);
  }
}

void main() {
  group('Queue reorder bounds checking', () {
    late TestQueue queue;

    setUp(() {
      queue = TestQueue();
      queue.add('a');
      queue.add('b');
      queue.add('c');
    });

    test('negative oldIndex does nothing', () {
      queue.reorder(-1, 1);
      expect(queue.items, ['a', 'b', 'c']);
    });

    test('oldIndex >= length does nothing', () {
      queue.reorder(3, 0);
      expect(queue.items, ['a', 'b', 'c']);
    });

    test('negative newIndex does nothing', () {
      queue.reorder(0, -1);
      expect(queue.items, ['a', 'b', 'c']);
    });

    test('newIndex > length does nothing', () {
      queue.reorder(0, 4);
      expect(queue.items, ['a', 'b', 'c']);
    });

    test('valid reorder still works', () {
      queue.reorder(2, 0);
      expect(queue.items, ['c', 'a', 'b']);
    });
  });
}
