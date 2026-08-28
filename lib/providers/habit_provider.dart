import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/models/habit.dart';
import '../data/repositories/habit_repository.dart';

class HabitProvider extends ChangeNotifier {
  final HabitRepository _repo = HabitRepository();
  final _uuid = const Uuid();
  List<Habit> _habits = [];
  bool _loading = true;

  List<Habit> get habits => List.unmodifiable(_habits);
  bool get loading => _loading;

  List<Habit> get dueToday => _habits.where((h) => h.isDueToday).toList();

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _habits = await _repo.getAll();
    _loading = false;
    notifyListeners();
  }

  Future<void> addHabit(String title,
      {String emoji = '🔥', Set<int> targetWeekdays = const {}}) async {
    final habit = Habit(
      id: _uuid.v4(),
      title: title,
      emoji: emoji,
      targetWeekdays: targetWeekdays,
      createdAt: DateTime.now(),
    );
    _habits.insert(0, habit);
    notifyListeners();
    await _repo.insert(habit);
  }

  Future<void> toggleToday(Habit habit) async {
    final key = Habit.dayKey(DateTime.now());
    final updated = Set<int>.from(habit.completedDates);
    if (updated.contains(key)) {
      updated.remove(key);
    } else {
      updated.add(key);
    }
    final newHabit = habit.copyWith(completedDates: updated);
    final idx = _habits.indexWhere((h) => h.id == habit.id);
    if (idx != -1) {
      _habits[idx] = newHabit;
      notifyListeners();
    }
    await _repo.update(newHabit);
  }

  Future<void> deleteHabit(String id) async {
    _habits.removeWhere((h) => h.id == id);
    notifyListeners();
    await _repo.delete(id);
  }
}
