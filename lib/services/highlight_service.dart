import '../models/highlight.dart';
import 'book_service.dart';

/// Wrapper around BookService highlight methods for cleaner API.
/// Data stays in Book objects; this is a facade for future migration.
class HighlightService {
  final BookService _bookService;
  HighlightService(this._bookService);

  List<Highlight> getForBook(String bookId) =>
      _bookService.getById(bookId)?.highlights ?? [];

  List<Highlight> getForPage(String bookId, int page) =>
      _bookService.getHighlightsForPage(bookId, page);

  Future<void> add(String bookId, Highlight highlight) =>
      _bookService.addHighlight(bookId, highlight);

  Future<void> remove(String bookId, String highlightId) =>
      _bookService.removeHighlight(bookId, highlightId);

  Future<void> updateColor(String bookId, String highlightId, int color) =>
      _bookService.updateHighlightColor(bookId, highlightId, color);

  Future<void> updateNote(String bookId, String highlightId, String note) =>
      _bookService.updateHighlightNote(bookId, highlightId, note);
}
