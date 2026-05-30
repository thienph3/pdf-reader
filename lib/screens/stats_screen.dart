import 'package:flutter/material.dart';
import '../main.dart';
import '../l10n/app_strings.dart';
import 'stats_widgets.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final bookService = BookServiceScope.of(context);
    final settings = SettingsScope.of(context);
    final logService = ReadingLogServiceScope.of(context);
    final streakService = StreakServiceScope.of(context);
    final books = bookService.getAll();
    final colorScheme = Theme.of(context).colorScheme;

    final totalSeconds = books.fold<int>(0, (sum, b) => sum + b.readingSeconds);
    final totalHours = totalSeconds ~/ 3600;
    final totalMinutes = (totalSeconds % 3600) ~/ 60;
    final booksCompleted = books.where((b) => b.totalPages > 0 && b.progressPercent >= 1.0).length;
    final dailyGoal = settings.dailyGoalMinutes;
    final monthlyGoal = settings.monthlyGoalBooks;
    final today = logService.getToday();
    final todayMinutes = today.seconds ~/ 60;
    final thisMonth = logService.getThisMonth();
    final weekLogs = logService.getRecent(days: 7);
    final isVi = Localizations.localeOf(context).languageCode == 'vi';

    return Scaffold(
      appBar: AppBar(title: Text(s.statistics)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(s.todayReading, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          StatsProgressCard(label: s.dailyGoal, current: todayMinutes, goal: dailyGoal, unit: 'min', color: colorScheme.primary),
          const SizedBox(height: 16),
          Text(s.thisMonth, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          StatsProgressCard(label: s.monthlyGoal, current: booksCompleted, goal: monthlyGoal, unit: isVi ? 'sách' : 'books', color: colorScheme.tertiary),
          const SizedBox(height: 16),
          Text(isVi ? 'Tuần này' : 'This week', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SizedBox(height: 120, child: StatsWeekChart(logs: weekLogs, goalMinutes: dailyGoal)),
          const SizedBox(height: 16),
          Text(s.statistics, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          StatsStatTile(icon: Icons.schedule, label: s.totalReadingTime, value: totalHours > 0 ? '${totalHours}h ${totalMinutes}m' : '${totalMinutes}m'),
          StatsStatTile(icon: Icons.check_circle_outline, label: s.booksRead, value: '$booksCompleted / ${books.length}'),
          StatsStatTile(icon: Icons.menu_book, label: isVi ? 'Trang đã đọc tháng này' : 'Pages this month', value: '${thisMonth.pagesRead}'),
          const SizedBox(height: 16),
          Text(isVi ? 'Chuỗi đọc' : 'Reading Streaks', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          StatsStatTile(icon: Icons.local_fire_department, label: isVi ? 'Chuỗi hiện tại' : 'Current streak', value: '${streakService.currentStreak} ${isVi ? 'ngày' : 'days'}'),
          StatsStatTile(icon: Icons.emoji_events, label: isVi ? 'Chuỗi dài nhất' : 'Longest streak', value: '${streakService.longestStreak} ${isVi ? 'ngày' : 'days'}'),
          const SizedBox(height: 16),
          Text(isVi ? 'Thành tựu' : 'Achievements', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          StatsAchievementsWrap(achievements: streakService.unlockedAchievements, isVi: isVi),
        ],
      ),
    );
  }
}
