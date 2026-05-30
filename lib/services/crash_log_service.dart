import 'dart:io';
import 'package:path_provider/path_provider.dart';

class CrashLogService {
  static String appVersion = '1.0.0';
  static const _maxSize = 100 * 1024; // 100KB

  static Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/crash_log.txt');
  }

  static Future<void> logCrash(Object error, StackTrace stack) async {
    try {
      final f = await _file();
      final entry = '[${DateTime.now().toIso8601String()}] v$appVersion\n$error\n$stack\n\n';
      await f.writeAsString(entry, mode: FileMode.append);
      // Truncate if over max size
      if (await f.length() > _maxSize) {
        final content = await f.readAsString();
        await f.writeAsString(content.substring(content.length - _maxSize ~/ 2));
      }
    } catch (_) {}
  }

  static Future<String?> getCrashLog() async {
    final f = await _file();
    if (!await f.exists()) return null;
    return f.readAsString();
  }

  static Future<void> clearCrashLog() async {
    final f = await _file();
    if (await f.exists()) await f.delete();
  }

  static Future<String?> getFilePath() async {
    final f = await _file();
    if (!await f.exists()) return null;
    return f.path;
  }
}
