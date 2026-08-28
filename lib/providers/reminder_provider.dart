import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/models/reminder.dart';
import '../data/models/task.dart';
import '../data/repositories/reminder_repository.dart';
import '../services/notification_service.dart';

class ReminderProvider extends ChangeNotifier {
  final ReminderRepository _repo = ReminderRepository();
  final _uuid = const Uuid();
  List<Reminder> _reminders = [];
  bool _loading = true;

  List<Reminder> get reminders => List.unmodifiable(_reminders);
  bool get loading => _loading;

  List<Reminder> get active =>
      _reminders.where((r) => r.isActive).toList()
        ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

  Reminder? get next {
    final upcoming =
        active.where((r) => r.dateTime.isAfter(DateTime.now())).toList();
    if (upcoming.isEmpty) return null;
    return upcoming.first;
  }

  List<Reminder> remindersOn(DateTime day) {
    return _reminders.where((r) {
      final d = r.dateTime;
      return d.year == day.year && d.month == day.month && d.day == day.day;
    }).toList();
  }

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _reminders = await _repo.getAll();
    _loading = false;
    notifyListeners();
  }

  Future<void> addReminder({
    required String title,
    String? notes,
    required DateTime dateTime,
    RepeatRule repeat = RepeatRule.none,
    int snoozeMinutes = 10,
  }) async {
    final reminder = Reminder(
      id: _uuid.v4(),
      title: title,
      notes: notes,
      dateTime: dateTime,
      repeat: repeat,
      snoozeMinutes: snoozeMinutes,
      createdAt: DateTime.now(),
    );
    _reminders.add(reminder);
    notifyListeners();
    await _repo.insert(reminder);
    await NotificationService.instance.scheduleReminder(reminder);
  }

  Future<void> updateReminder(Reminder reminder) async {
    final idx = _reminders.indexWhere((r) => r.id == reminder.id);
    if (idx != -1) {
      _reminders[idx] = reminder;
      notifyListeners();
    }
    await _repo.update(reminder);
    await NotificationService.instance.cancelReminder(reminder);
    if (reminder.isActive) {
      await NotificationService.instance.scheduleReminder(reminder);
    }
  }

  Future<void> snooze(Reminder reminder) async {
    await NotificationService.instance.snoozeReminder(reminder);
  }

  Future<void> deleteReminder(String id) async {
    final reminder = _reminders.firstWhere((r) => r.id == id);
    _reminders.removeWhere((r) => r.id == id);
    notifyListeners();
    await _repo.delete(id);
    await NotificationService.instance.cancelReminder(reminder);
  }
}
