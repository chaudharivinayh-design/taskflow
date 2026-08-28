import 'task.dart';

/// A reminder fires a local notification at [dateTime]. Reminders can
/// repeat and can be snoozed from the notification itself.
class Reminder {
  final String id;
  final String title;
  final String? notes;
  final DateTime dateTime;
  final RepeatRule repeat;
  final bool isActive;
  final int snoozeMinutes;
  final DateTime createdAt;

  const Reminder({
    required this.id,
    required this.title,
    this.notes,
    required this.dateTime,
    this.repeat = RepeatRule.none,
    this.isActive = true,
    this.snoozeMinutes = 10,
    required this.createdAt,
  });

  Reminder copyWith({
    String? title,
    String? notes,
    DateTime? dateTime,
    RepeatRule? repeat,
    bool? isActive,
    int? snoozeMinutes,
  }) {
    return Reminder(
      id: id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      dateTime: dateTime ?? this.dateTime,
      repeat: repeat ?? this.repeat,
      isActive: isActive ?? this.isActive,
      snoozeMinutes: snoozeMinutes ?? this.snoozeMinutes,
      createdAt: createdAt,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'notes': notes,
      'dateTime': dateTime.millisecondsSinceEpoch,
      'repeat': repeat.name,
      'isActive': isActive ? 1 : 0,
      'snoozeMinutes': snoozeMinutes,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Reminder.fromMap(Map<String, Object?> map) {
    return Reminder(
      id: map['id'] as String,
      title: map['title'] as String,
      notes: map['notes'] as String?,
      dateTime: DateTime.fromMillisecondsSinceEpoch(map['dateTime'] as int),
      repeat: repeatRuleFromString(map['repeat'] as String? ?? 'none'),
      isActive: (map['isActive'] as int? ?? 1) == 1,
      snoozeMinutes: map['snoozeMinutes'] as int? ?? 10,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    );
  }

  /// A stable integer id derived from the string id, used to schedule
  /// platform notifications (which require an int id).
  int get notificationId => id.hashCode & 0x7fffffff;
}
