import 'package:flutter/material.dart';
import '../main.dart';
import '../l10n/app_strings.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final bookService = BookServiceScope.of(context);
    final settings = SettingsScope.of(context);
    final logService = ReadingLogServiceScope.of(context);
    final books = bookService.getAll();
    final colorScheme = Theme.of(context).colorScheme;

    final totalSeconds = books.fold<int>(0, (sum, b) => sum + b.readingSeconds);
    final totalHours = totalSeconds ~/ 3600;
    final totalMinutes = (totalSeconds % 3600) ~/ 60;
    final booksCompleted =
        books.where((b) => b.totalPages > 0 && b.progressPercent >= 1.0).length;

    final dailyGoal = settings.dailyGoalMinutes;
    final monthlyGoal = settings.monthlyGoalBooks;

    final today = logService.getToday();
    final todayMinutes = today.seconds ~/ 60;
    final thisMonth = logService.getThisMonth();
    final weekLogs = logService.getRecent(days: 7);

    return Scaffold(
      appBar: AppBar(title: Text(s.statistics)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Today's progress
          Text(s.todayReading,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _ProgressCard(
            label: s.dailyGoal,
            current: todayMinutes,
            goal: dailyGoal,
            unit: 'min',
            color: colorScheme.primary,
          ),
          const SizedBox(height: 16),

          // This month
          Text(s.thisMonth,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _ProgressCard(
            label: s.monthlyGoal,
            current: booksCompleted,
            goal: monthlyGoal,
            unit: _isVi(context) ? 'sách' : 'books',
            color: colorScheme.tertiary,
          ),
          const SizedBox(height: 16),

          // Weekly chart
          Text(_isVi(context) ? 'Tuần này' : 'This week',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: _WeekChart(logs: weekLogs, goalMinutes: dailyGoal),
          ),
          const SizedBox(height: 16),

          // Overall stats
          Text(s.statistics,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _StatTile(
            icon: Icons.schedule,
            label: s.totalReadingTime,
            value: totalHours > 0
                ? '${totalHours}h ${totalMinutes}m'
                : '${totalMinutes}m',
          ),
          _StatTile(
            icon: Icons.check_circle_outline,
            label: s.booksRead,
            value: '$booksCompleted / ${books.length}',
          ),
          _StatTile(
            icon: Icons.menu_book,
            label: _isVi(context) ? 'Trang đã đọc tháng này' : 'Pages this month',
            value: '${thisMonth.pagesRead}',
          ),
        ],
      ),
    );
  }

  bool _isVi(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'vi';
}

class _ProgressCard extends StatelessWidget {
  final String label;
  final int current;
  final int goal;
  final String unit;
  final Color color;

  const _ProgressCard({
    required this.label,
    required this.current,
    required this.goal,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$current / $goal $unit',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                Text('${(progress * 100).toInt()}%',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                color: color,
                backgroundColor: color.withValues(alpha: 0.15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekChart extends StatelessWidget {
  final List<dynamic> logs; // ReadingLog
  final int goalMinutes;

  const _WeekChart({required this.logs, required this.goalMinutes});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final maxMinutes = logs.fold<int>(
        goalMinutes, (max, log) => log.seconds ~/ 60 > max ? log.seconds ~/ 60 : max);

    // Calculate actual day labels from log dates
    final now = DateTime.now();
    final dayLabels = List.generate(logs.length, (i) {
      final date = now.subtract(Duration(days: logs.length - 1 - i));
      return ['', 'M', 'T', 'W', 'T', 'F', 'S', 'S'][date.weekday];
    });

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(logs.length, (i) {
        final minutes = logs[i].seconds ~/ 60;
        final height = maxMinutes > 0 ? (minutes / maxMinutes) * 80 : 0.0;
        final isToday = i == logs.length - 1;
        final reachedGoal = minutes >= goalMinutes;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (minutes > 0)
                  Text('${minutes}m',
                      style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(height: 4),
                Container(
                  height: height.clamp(4.0, 80.0),
                  decoration: BoxDecoration(
                    color: reachedGoal
                        ? colorScheme.primary
                        : isToday
                            ? colorScheme.primaryContainer
                            : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dayLabels[i],
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: isToday ? FontWeight.bold : null,
                      ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: Text(value,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold)),
    );
  }
}
