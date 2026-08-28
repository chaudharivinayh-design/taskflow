enum TaskPriority { low, medium, high }

enum RepeatRule { none, daily, weekly, monthly, weekdays }

RepeatRule repeatRuleFromString(String value) {
  return RepeatRule.values.firstWhere(
    (e) => e.name == value,
    orElse: () => RepeatRule.none,
  );
}

TaskPriority priorityFromString(String value) {
  return TaskPriority.values.firstWhere(
    (e) => e.name == value,
    orElse: () => TaskPriority.medium,
  );
}

/// A single to-do task. Tasks can optionally carry a due date/time,
/// a repeat rule and a priority, and can be marked complete.
class Task {
  final String id;
  final String title;
  final String? notes;
  final DateTime? dueDate;
  final TaskPriority priority;
  final RepeatRule repeat;
  final bool isCompleted;
  final DateTime createdAt;

  const Task({
    required this.id,
    required this.title,
    this.notes,
    this.dueDate,
    this.priority = TaskPriority.medium,
    this.repeat = RepeatRule.none,
    this.isCompleted = false,
    required this.createdAt,
  });

  Task copyWith({
    String? title,
    String? notes,
    DateTime? dueDate,
    bool clearDueDate = false,
    TaskPriority? priority,
    RepeatRule? repeat,
    bool? isCompleted,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      priority: priority ?? this.priority,
      repeat: repeat ?? this.repeat,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'notes': notes,
      'dueDate': dueDate?.millisecondsSinceEpoch,
      'priority': priority.name,
      'repeat': repeat.name,
      'isCompleted': isCompleted ? 1 : 0,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Task.fromMap(Map<String, Object?> map) {
    return Task(
      id: map['id'] as String,
      title: map['title'] as String,
      notes: map['notes'] as String?,
      dueDate: map['dueDate'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(map['dueDate'] as int),
      priority: priorityFromString(map['priority'] as String? ?? 'medium'),
      repeat: repeatRuleFromString(map['repeat'] as String? ?? 'none'),
      isCompleted: (map['isCompleted'] as int? ?? 0) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    );
  }
}
