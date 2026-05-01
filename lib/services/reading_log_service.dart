import 'package:hive_flutter/hive_flutter.dart';
import '../models/reading_log.dart';

const _boxName = 'reading_logs';

class ReadingLogService {
  late Box<Map> _box;

  Future<void> init() async {
    _box = await Hive.openBox<Map>(_boxName);
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Log reading time for today.
  Future<void> logReading({int seconds = 0, int pages = 0}) async {
    final key = _todayKey();
    final existing = _box.get(key);
    final log = existing != null
        ? ReadingLog.fromMap(existing).add(addSeconds: seconds, addPages: pages)
        : ReadingLog(date: key, seconds: seconds, pagesRead: pages);
    await _box.put(key, log.toMap());
  }

  /// Get today's reading log.
  ReadingLog getToday() {
    final key = _todayKey();
    final map = _box.get(key);
    if (map == null) return ReadingLog(date: key);
    return ReadingLog.fromMap(map);
  }

  /// Get logs for the last [days] days.
  List<ReadingLog> getRecent({int days = 7}) {
    final result = <ReadingLog>[];
    final now = DateTime.now();
    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      final key =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final map = _box.get(key);
      result.add(map != null
          ? ReadingLog.fromMap(map)
          : ReadingLog(date: key));
    }
    return result.reversed.toList();
  }

  /// Get total for current month.
  ReadingLog getThisMonth() {
    final now = DateTime.now();
    final prefix =
        '${now.year}-${now.month.toString().padLeft(2, '0')}';
    int totalSeconds = 0;
    int totalPages = 0;
    for (final key in _box.keys) {
      if ((key as String).startsWith(prefix)) {
        final log = ReadingLog.fromMap(_box.get(key)!);
        totalSeconds += log.seconds;
        totalPages += log.pagesRead;
      }
    }
    return ReadingLog(
        date: prefix, seconds: totalSeconds, pagesRead: totalPages);
  }
}
