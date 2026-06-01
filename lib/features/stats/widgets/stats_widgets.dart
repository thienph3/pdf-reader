import 'package:flutter/material.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../services/streak_service.dart';

class StatsProgressCard extends StatelessWidget {
  final String label;
  final int current;
  final int goal;
  final String unit;
  final Color color;
  const StatsProgressCard({super.key, required this.label, required this.current, required this.goal, required this.unit, required this.color});

  @override
  Widget build(BuildContext context) {
    final progress = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('$current / $goal $unit', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            Text('${(progress * 100).toInt()}%', style: Theme.of(context).textTheme.bodySmall),
          ]),
          const SizedBox(height: 8),
          ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: progress, minHeight: 8, color: color, backgroundColor: color.withValues(alpha: 0.15))),
        ]),
      ),
    );
  }
}

class StatsWeekChart extends StatelessWidget {
  final List<dynamic> logs;
  final int goalMinutes;
  const StatsWeekChart({super.key, required this.logs, required this.goalMinutes});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final maxMinutes = logs.fold<int>(goalMinutes, (max, log) => log.seconds ~/ 60 > max ? log.seconds ~/ 60 : max);
    final now = DateTime.now();
    final dayLabels = List.generate(logs.length, (i) {
      final date = now.subtract(Duration(days: logs.length - 1 - i));
      return ['', ...AppStrings.of(context).weekDays][date.weekday];
    });
    final goalLineY = maxMinutes > 0 ? (1 - goalMinutes / maxMinutes) * 80 : 0.0;

    return Stack(
      children: [
        // Goal line
        if (goalMinutes > 0)
          Positioned(
            left: 0, right: 0, bottom: 24 + goalLineY.clamp(0.0, 76.0),
            child: Container(height: 1, color: colorScheme.error.withValues(alpha: 0.5)),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(logs.length, (i) {
            final minutes = logs[i].seconds ~/ 60;
            final height = maxMinutes > 0 ? (minutes / maxMinutes) * 80 : 0.0;
            final isToday = i == logs.length - 1;
            final reachedGoal = minutes >= goalMinutes;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                  if (minutes > 0) Text('${minutes}m', style: Theme.of(context).textTheme.labelSmall),
                  const SizedBox(height: 4),
                  Container(height: height.clamp(4.0, 80.0), decoration: BoxDecoration(color: reachedGoal ? colorScheme.primary : isToday ? colorScheme.primaryContainer : colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(4))),
                  const SizedBox(height: 4),
                  Text(dayLabels[i], style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: isToday ? FontWeight.bold : null)),
                ]),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class StatsStatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const StatsStatTile({super.key, required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(leading: Icon(icon), title: Text(label), trailing: Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)));
  }
}

class StatsAchievementsWrap extends StatelessWidget {
  final List<Achievement> achievements;
  final bool isVi;
  const StatsAchievementsWrap({super.key, required this.achievements, required this.isVi});

  @override
  Widget build(BuildContext context) {
    if (achievements.isEmpty) return Text(isVi ? 'Chưa có thành tựu nào' : 'No achievements yet', style: Theme.of(context).textTheme.bodyMedium);
    return Wrap(spacing: 8, runSpacing: 8, children: achievements.map((a) => Chip(avatar: Text(a.icon), label: Text(isVi ? a.titleVi : a.titleEn))).toList());
  }
}
