import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/models/alarm.dart';
import '../data/repositories/alarm_repository.dart';
import '../services/notification_service.dart';

class AlarmProvider extends ChangeNotifier {
  final AlarmRepository _repo = AlarmRepository();
  final _uuid = const Uuid();
  List<Alarm> _alarms = [];
  bool _loading = true;

  List<Alarm> get alarms => List.unmodifiable(_alarms)
    ..sort((a, b) {
      final aMin = a.hour * 60 + a.minute;
      final bMin = b.hour * 60 + b.minute;
      return aMin.compareTo(bMin);
    });
  bool get loading => _loading;

  Alarm? get nextAlarm {
    final enabled = _alarms.where((a) => a.isEnabled).toList();
    if (enabled.isEmpty) return null;
    DateTime bestTime = DateTime.now().add(const Duration(days: 8));
    Alarm? best;
    final now = DateTime.now();
    for (final a in enabled) {
      if (!a.isRepeating) {
        var candidate =
            DateTime(now.year, now.month, now.day, a.hour, a.minute);
        if (candidate.isBefore(now)) {
          candidate = candidate.add(const Duration(days: 1));
        }
        if (candidate.isBefore(bestTime)) {
          bestTime = candidate;
          best = a;
        }
      } else {
        for (final weekday in a.repeatDays) {
          var candidate =
              DateTime(now.year, now.month, now.day, a.hour, a.minute);
          while (candidate.weekday != weekday || candidate.isBefore(now)) {
            candidate = candidate.add(const Duration(days: 1));
          }
          if (candidate.isBefore(bestTime)) {
            bestTime = candidate;
            best = a;
          }
        }
      }
    }
    return best;
  }

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _alarms = await _repo.getAll();
    _loading = false;
    notifyListeners();
  }

  Future<void> addAlarm({
    required int hour,
    required int minute,
    String label = '',
    Set<int> repeatDays = const {},
    bool vibrate = true,
    String soundAsset = 'default',
    int snoozeMinutes = 10,
  }) async {
    final alarm = Alarm(
      id: _uuid.v4(),
      label: label,
      hour: hour,
      minute: minute,
      repeatDays: repeatDays,
      vibrate: vibrate,
      soundAsset: soundAsset,
      snoozeMinutes: snoozeMinutes,
      createdAt: DateTime.now(),
    );
    _alarms.add(alarm);
    notifyListeners();
    await _repo.insert(alarm);
    await NotificationService.instance.scheduleAlarm(alarm);
  }

  Future<void> updateAlarm(Alarm alarm) async {
    final idx = _alarms.indexWhere((a) => a.id == alarm.id);
    if (idx != -1) {
      _alarms[idx] = alarm;
      notifyListeners();
    }
    await _repo.update(alarm);
    await NotificationService.instance.cancelAlarm(alarm);
    if (alarm.isEnabled) {
      await NotificationService.instance.scheduleAlarm(alarm);
    }
  }

  Future<void> toggleEnabled(Alarm alarm) async {
    await updateAlarm(alarm.copyWith(isEnabled: !alarm.isEnabled));
  }

  Future<void> deleteAlarm(String id) async {
    final alarm = _alarms.firstWhere((a) => a.id == id);
    _alarms.removeWhere((a) => a.id == id);
    notifyListeners();
    await _repo.delete(id);
    await NotificationService.instance.cancelAlarm(alarm);
  }
}
