import 'package:flutter_test/flutter_test.dart';

/// Tests page notes key generation and retrieval logic.
/// Mirrors PageNotesService behavior without Hive.
class TestPageNotes {
  final Map<String, String> _store = {};

  String _key(String bookId, int page) => '${bookId}_$page';

  String? getNote(String bookId, int page) => _store[_key(bookId, page)];

  void saveNote(String bookId, int page, String text) {
    if (text.trim().isEmpty) {
      deleteNote(bookId, page);
      return;
    }
    _store[_key(bookId, page)] = text;
  }

  void deleteNote(String bookId, int page) => _store.remove(_key(bookId, page));

  Map<int, String> getAllForBook(String bookId) {
    final prefix = '${bookId}_';
    final result = <int, String>{};
    for (final entry in _store.entries) {
      if (entry.key.startsWith(prefix)) {
        final page = int.tryParse(entry.key.substring(prefix.length));
        if (page != null) result[page] = entry.value;
      }
    }
    return result;
  }
}

void main() {
  group('Page notes are saved and retrieved per book per page', () {
    late TestPageNotes notes;

    setUp(() => notes = TestPageNotes());

    test('saving a note makes it retrievable', () {
      notes.saveNote('book1', 5, 'important point');
      expect(notes.getNote('book1', 5), 'important point');
    });

    test('notes are isolated per book', () {
      notes.saveNote('book1', 3, 'note A');
      notes.saveNote('book2', 3, 'note B');
      expect(notes.getNote('book1', 3), 'note A');
      expect(notes.getNote('book2', 3), 'note B');
    });

    test('notes are isolated per page', () {
      notes.saveNote('book1', 1, 'page 1');
      notes.saveNote('book1', 2, 'page 2');
      expect(notes.getNote('book1', 1), 'page 1');
      expect(notes.getNote('book1', 2), 'page 2');
    });

    test('empty note deletes the entry', () {
      notes.saveNote('book1', 5, 'hello');
      notes.saveNote('book1', 5, '');
      expect(notes.getNote('book1', 5), isNull);
    });

    test('whitespace-only note deletes the entry', () {
      notes.saveNote('book1', 5, 'hello');
      notes.saveNote('book1', 5, '   ');
      expect(notes.getNote('book1', 5), isNull);
    });

    test('getAllForBook returns only notes for that book', () {
      notes.saveNote('book1', 1, 'a');
      notes.saveNote('book1', 5, 'b');
      notes.saveNote('book2', 3, 'c');
      final result = notes.getAllForBook('book1');
      expect(result, {1: 'a', 5: 'b'});
    });

    test('non-existent note returns null', () {
      expect(notes.getNote('book1', 99), isNull);
    });
  });
}
