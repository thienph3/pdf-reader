import 'reading_log_service.dart';
import 'book_service.dart';

class Achievement {
  final String id;
  final String titleEn;
  final String titleVi;
  final String icon;
  const Achievement(this.id, this.titleEn, this.titleVi, this.icon);
}

const _achievements = [
  Achievement('first_book', 'First Book', 'Sách đầu tiên', '📖'),
  Achievement('7_day_streak', '7-Day Streak', 'Chuỗi 7 ngày', '🔥'),
  Achievement('30_day_streak', '30-Day Streak', 'Chuỗi 30 ngày', '💪'),
  Achievement('100_pages', '100 Pages', '100 trang', '📄'),
  Achievement('bookworm', 'Bookworm', 'Mọt sách', '🐛'),
];

class StreakService {
  final ReadingLogService _logService;
  final BookService _bookService;

  StreakService(this._logService, this._bookService);

  int get currentStreak {
    final logs = _logService.getRecent(days: 365);
    // logs is oldest-first, reverse to check from today backwards
    int streak = 0;
    for (final log in logs.reversed) {
      if (log.seconds > 0) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  int get longestStreak {
    final logs = _logService.getRecent(days: 365);
    int longest = 0, current = 0;
    for (final log in logs) {
      if (log.seconds > 0) {
        current++;
        if (current > longest) longest = current;
      } else {
        current = 0;
      }
    }
    return longest;
  }

  List<Achievement> get unlockedAchievements {
    final result = <Achievement>[];
    final books = _bookService.getAll();
    final booksCompleted = books.where((b) => b.totalPages > 0 && b.progressPercent >= 1.0).length;
    final totalSeconds = books.fold<int>(0, (sum, b) => sum + b.readingSeconds);
    final totalPages = _logService.getRecent(days: 365).fold<int>(0, (sum, l) => sum + l.pagesRead);

    if (booksCompleted >= 1) result.add(_achievements[0]);
    if (longestStreak >= 7) result.add(_achievements[1]);
    if (longestStreak >= 30) result.add(_achievements[2]);
    if (totalPages >= 100) result.add(_achievements[3]);
    if (totalSeconds >= 36000) result.add(_achievements[4]);
    return result;
  }
}
