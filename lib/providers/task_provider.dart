import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/models/task.dart';
import '../data/repositories/task_repository.dart';
import '../services/notification_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskRepository _repo = TaskRepository();
  final _uuid = const Uuid();
  List<Task> _tasks = [];
  bool _loading = true;

  List<Task> get tasks => List.unmodifiable(_tasks);
  bool get loading => _loading;

  List<Task> get pending => _tasks.where((t) => !t.isCompleted).toList()
    ..sort((a, b) {
      if (a.dueDate == null && b.dueDate == null) return 0;
      if (a.dueDate == null) return 1;
      if (b.dueDate == null) return -1;
      return a.dueDate!.compareTo(b.dueDate!);
    });

  List<Task> get completed => _tasks.where((t) => t.isCompleted).toList();

  List<Task> tasksOn(DateTime day) {
    return _tasks.where((t) {
      final d = t.dueDate;
      if (d == null) return false;
      return d.year == day.year && d.month == day.month && d.day == day.day;
    }).toList();
  }

  List<Task> get todayFocus {
    final now = DateTime.now();
    return pending.where((t) {
      if (t.dueDate == null) return false;
      final d = t.dueDate!;
      return d.year == now.year && d.month == now.month && d.day == now.day;
    }).toList();
  }

  Task? get nextUpcoming {
    final future = pending.where((t) =>
        t.dueDate != null && t.dueDate!.isAfter(DateTime.now()));
    if (future.isEmpty) return null;
    return future.first;
  }

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _tasks = await _repo.getAll();
    _loading = false;
    notifyListeners();
  }

  Future<void> addTask({
    required String title,
    String? notes,
    DateTime? dueDate,
    TaskPriority priority = TaskPriority.medium,
    RepeatRule repeat = RepeatRule.none,
  }) async {
    final task = Task(
      id: _uuid.v4(),
      title: title,
      notes: notes,
      dueDate: dueDate,
      priority: priority,
      repeat: repeat,
      createdAt: DateTime.now(),
    );
    _tasks.insert(0, task);
    notifyListeners();
    await _repo.insert(task);
    await NotificationService.instance.scheduleTaskDueNotification(task);
  }

  Future<void> updateTask(Task task) async {
    final idx = _tasks.indexWhere((t) => t.id == task.id);
    if (idx != -1) {
      _tasks[idx] = task;
      notifyListeners();
    }
    await _repo.update(task);
    await NotificationService.instance.cancelTaskNotification(task);
    if (!task.isCompleted) {
      await NotificationService.instance.scheduleTaskDueNotification(task);
    }
  }

  Future<void> toggleComplete(Task task) async {
    await updateTask(task.copyWith(isCompleted: !task.isCompleted));
  }

  Future<void> deleteTask(String id) async {
    final task = _tasks.firstWhere((t) => t.id == id);
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
    await _repo.delete(id);
    await NotificationService.instance.cancelTaskNotification(task);
  }
}
