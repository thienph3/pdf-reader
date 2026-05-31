import 'package:hive_flutter/hive_flutter.dart';

class PageNotesService {
  late Box<String> _box;

  Future<void> init() async {
    _box = await Hive.openBox<String>('page_notes');
  }

  String? getNote(String bookId, int page) => _box.get('${bookId}_$page');

  Future<void> saveNote(String bookId, int page, String text) async {
    if (text.trim().isEmpty) {
      await deleteNote(bookId, page);
      return;
    }
    await _box.put('${bookId}_$page', text);
  }

  Future<void> deleteNote(String bookId, int page) async {
    await _box.delete('${bookId}_$page');
  }

  Map<int, String> getAllForBook(String bookId) {
    final prefix = '${bookId}_';
    final result = <int, String>{};
    for (final key in _box.keys) {
      final k = key as String;
      if (k.startsWith(prefix)) {
        final page = int.tryParse(k.substring(prefix.length));
        if (page != null) result[page] = _box.get(k)!;
      }
    }
    return result;
  }
}
