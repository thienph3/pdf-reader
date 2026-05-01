class ReadingGoal {
  final int dailyMinutes; // target minutes per day
  final int monthlyBooks; // target books per month

  const ReadingGoal({this.dailyMinutes = 30, this.monthlyBooks = 2});

  Map<String, dynamic> toMap() => {
        'dailyMinutes': dailyMinutes,
        'monthlyBooks': monthlyBooks,
      };

  factory ReadingGoal.fromMap(Map<dynamic, dynamic> map) => ReadingGoal(
        dailyMinutes: map['dailyMinutes'] as int? ?? 30,
        monthlyBooks: map['monthlyBooks'] as int? ?? 2,
      );
}
