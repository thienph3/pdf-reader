/// A daily reading log entry.
class ReadingLog {
  final String date; // yyyy-MM-dd
  final int seconds;
  final int pagesRead;

  const ReadingLog({
    required this.date,
    this.seconds = 0,
    this.pagesRead = 0,
  });

  ReadingLog add({int addSeconds = 0, int addPages = 0}) => ReadingLog(
        date: date,
        seconds: seconds + addSeconds,
        pagesRead: pagesRead + addPages,
      );

  Map<String, dynamic> toMap() => {
        'date': date,
        'seconds': seconds,
        'pagesRead': pagesRead,
      };

  factory ReadingLog.fromMap(Map<dynamic, dynamic> map) => ReadingLog(
        date: map['date'] as String,
        seconds: map['seconds'] as int? ?? 0,
        pagesRead: map['pagesRead'] as int? ?? 0,
      );
}
