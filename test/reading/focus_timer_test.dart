import 'package:flutter_test/flutter_test.dart';

String formatTimer(int seconds) {
  final h = seconds ~/ 3600;
  final m = (seconds % 3600) ~/ 60;
  final s = seconds % 60;
  return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}

void main() {
  group('Focus timer formatting', () {
    test('zero seconds formats as 00:00:00', () {
      expect(formatTimer(0), '00:00:00');
    });

    test('3661 seconds formats as 01:01:01', () {
      expect(formatTimer(3661), '01:01:01');
    });

    test('59 seconds formats correctly', () {
      expect(formatTimer(59), '00:00:59');
    });

    test('3600 seconds formats as 01:00:00', () {
      expect(formatTimer(3600), '01:00:00');
    });
  });
}
