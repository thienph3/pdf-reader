import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_reader/models/reading_goal.dart';

void main() {
  group('ReadingGoal', () {
    test('default values', () {
      const goal = ReadingGoal();
      expect(goal.dailyMinutes, 30);
      expect(goal.monthlyBooks, 2);
    });

    test('toMap/fromMap roundtrip', () {
      const goal = ReadingGoal(dailyMinutes: 60, monthlyBooks: 5);
      final restored = ReadingGoal.fromMap(goal.toMap());
      expect(restored.dailyMinutes, 60);
      expect(restored.monthlyBooks, 5);
    });

    test('fromMap uses defaults for missing fields', () {
      final goal = ReadingGoal.fromMap({});
      expect(goal.dailyMinutes, 30);
      expect(goal.monthlyBooks, 2);
    });
  });
}
