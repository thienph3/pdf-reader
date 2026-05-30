import 'dart:async';
import '../../../services/book_service.dart';
import '../../../services/reading_log_service.dart';
import '../../../services/book_settings_service.dart';

class ReadingSession {
  final String? bookId;
  final BookService? bookService;
  final ReadingLogService? readingLogService;
  final BookSettingsService? bookSettingsService;

  int sessionSeconds = 0;
  int sessionStartPage = 0;
  Timer? readingTimer;

  ReadingSession({this.bookId, this.bookService, this.readingLogService, this.bookSettingsService});

  void start() {
    readingTimer = Timer.periodic(const Duration(seconds: 1), (_) => sessionSeconds++);
  }

  void saveProgress(int currentPage, int totalPages, {bool isEpub = false}) {
    if (bookId == null || bookService == null) return;
    final s = sessionSeconds;
    sessionSeconds = 0;
    if (s == 0 && currentPage == sessionStartPage) return;

    if (isEpub) {
      final book = bookService!.getById(bookId!);
      if (book != null) {
        bookService!.update(book.copyWith(
          lastPage: currentPage, totalPages: totalPages,
          lastOpenedAt: () => DateTime.now(),
        ));
      }
    } else {
      bookService!.saveProgress(bookId!, currentPage,
          totalPages: totalPages, addSeconds: s > 0 ? s : null);
    }

    final p = (currentPage > sessionStartPage) ? currentPage - sessionStartPage : 0;
    sessionStartPage = currentPage;
    if (s > 0 || p > 0) readingLogService?.logReading(seconds: s, pages: p);
  }

  BookSettings loadSettings() {
    if (bookId == null || bookSettingsService == null) return const BookSettings();
    return bookSettingsService!.getSettings(bookId!);
  }

  void saveSettings({required int readingMode, required bool horizontalScroll,
      required int cropMargins, required double brightness, required double lastZoom}) {
    if (bookId == null || bookSettingsService == null) return;
    bookSettingsService!.saveSettings(bookId!, BookSettings(
      readingMode: readingMode, horizontalScroll: horizontalScroll,
      cropMargins: cropMargins, brightness: brightness, lastZoom: lastZoom,
    ));
  }

  void dispose() => readingTimer?.cancel();
}
