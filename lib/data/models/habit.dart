/// A habit tracked daily. [completedDates] stores day-normalized
/// (yyyy-mm-dd) millisecondsSinceEpoch keys for quick streak math.
class Habit {
  final String id;
  final String title;
  final String emoji;
  final Set<int> targetWeekdays; // 1=Mon..7=Sun, empty = every day
  final Set<int> completedDates; // day-start epoch millis
  final DateTime createdAt;

  const Habit({
    required this.id,
    required this.title,
    this.emoji = '🔥',
    this.targetWeekdays = const {},
    this.completedDates = const {},
    required this.createdAt,
  });

  bool get isDueToday {
    if (targetWeekdays.isEmpty) return true;
    return targetWeekdays.contains(DateTime.now().weekday);
  }

  static int dayKey(DateTime d) =>
      DateTime(d.year, d.month, d.day).millisecondsSinceEpoch;

  bool isCompletedOn(DateTime d) => completedDates.contains(dayKey(d));

  int get currentStreak {
    int streak = 0;
    DateTime cursor = DateTime.now();
    while (isCompletedOn(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  Habit copyWith({
    String? title,
    String? emoji,
    Set<int>? targetWeekdays,
    Set<int>? completedDates,
  }) {
    return Habit(
      id: id,
      title: title ?? this.title,
      emoji: emoji ?? this.emoji,
      targetWeekdays: targetWeekdays ?? this.targetWeekdays,
      completedDates: completedDates ?? this.completedDates,
      createdAt: createdAt,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'emoji': emoji,
      'targetWeekdays': targetWeekdays.join(','),
      'completedDates': completedDates.join(','),
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Habit.fromMap(Map<String, Object?> map) {
    Set<int> parseSet(String? raw) {
      final s = (raw ?? '').trim();
      if (s.isEmpty) return <int>{};
      return s.split(',').map((e) => int.parse(e)).toSet();
    }

    return Habit(
      id: map['id'] as String,
      title: map['title'] as String,
      emoji: map['emoji'] as String? ?? '🔥',
      targetWeekdays: parseSet(map['targetWeekdays'] as String?),
      completedDates: parseSet(map['completedDates'] as String?),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    );
  }
}
