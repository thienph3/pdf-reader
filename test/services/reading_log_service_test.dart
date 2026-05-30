import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_reader/models/reading_log.dart';

void main() {
  group('ReadingLog model', () {
    test('fromMap/toMap roundtrip', () {
      final log = ReadingLog(date: '2024-06-01', seconds: 3600, pagesRead: 20);
      final restored = ReadingLog.fromMap(log.toMap());
      expect(restored.date, '2024-06-01');
      expect(restored.seconds, 3600);
      expect(restored.pagesRead, 20);
    });

    test('add accumulates seconds and pages', () {
      final log = ReadingLog(date: '2024-06-01', seconds: 100, pagesRead: 5);
      final updated = log.add(addSeconds: 50, addPages: 3);
      expect(updated.seconds, 150);
      expect(updated.pagesRead, 8);
      expect(updated.date, '2024-06-01');
    });

    test('default values are zero', () {
      final log = ReadingLog(date: '2024-06-01');
      expect(log.seconds, 0);
      expect(log.pagesRead, 0);
    });

    test('fromMap handles missing fields', () {
      final log = ReadingLog.fromMap({'date': '2024-01-01'});
      expect(log.seconds, 0);
      expect(log.pagesRead, 0);
    });
  });
}
