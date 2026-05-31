enum LogLevel { debug, info, warning, error }

class AppLogger {
  static LogLevel minLevel = LogLevel.debug;

  static void debug(String msg) => _log(LogLevel.debug, msg);
  static void info(String msg) => _log(LogLevel.info, msg);
  static void warning(String msg) => _log(LogLevel.warning, msg);
  static void error(String msg, [Object? error, StackTrace? stack]) {
    _log(LogLevel.error, '$msg${error != null ? '\n$error' : ''}');
  }

  static void _log(LogLevel level, String msg) {
    if (level.index < minLevel.index) return;
    final prefix = ['[D]', '[I]', '[W]', '[E]'][level.index];
    // ignore: avoid_print
    print('$prefix ${DateTime.now().toIso8601String().substring(11, 19)} $msg');
  }
}
