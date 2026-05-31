import 'package:hive_flutter/hive_flutter.dart';

class ReadingQueueService {
  late Box<List> _box;
  static const _key = 'queue';

  Future<void> init() async {
    _box = await Hive.openBox<List>('reading_queue');
  }

  List<String> getQueue() =>
      (_box.get(_key) ?? []).cast<String>();

  Future<void> addToQueue(String bookId) async {
    final q = getQueue();
    if (!q.contains(bookId)) {
      q.add(bookId);
      await _box.put(_key, q);
    }
  }

  Future<void> removeFromQueue(String bookId) async {
    final q = getQueue();
    q.remove(bookId);
    await _box.put(_key, q);
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final q = getQueue();
    if (oldIndex < 0 || oldIndex >= q.length) return;
    if (newIndex < 0 || newIndex > q.length) return;
    if (newIndex > oldIndex) newIndex--;
    final item = q.removeAt(oldIndex);
    q.insert(newIndex, item);
    await _box.put(_key, q);
  }
}
