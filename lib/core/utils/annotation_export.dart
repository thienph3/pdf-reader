import '../../models/book.dart';

/// Exports a book's annotations (highlights + bookmarks) as Markdown.
String exportAnnotationsAsMarkdown(Book book) {
  final buf = StringBuffer('# ${book.title}\n');

  if (book.highlights.isNotEmpty) {
    buf.writeln('\n## Highlights');
    for (final h in book.highlights..sort((a, b) => a.page.compareTo(b.page))) {
      final note = h.note.isNotEmpty ? ' — ${h.note}' : '';
      buf.writeln('- Page ${h.page + 1}: "${h.text}"$note');
    }
  }

  if (book.bookmarks.isNotEmpty) {
    buf.writeln('\n## Bookmarks');
    for (final b in book.bookmarks..sort((a, b) => a.page.compareTo(b.page))) {
      final note = b.note.isNotEmpty ? ': ${b.note}' : '';
      buf.writeln('- Page ${b.page + 1}$note');
    }
  }

  return buf.toString();
}
