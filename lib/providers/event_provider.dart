import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/models/event.dart';
import '../data/repositories/event_repository.dart';

class EventProvider extends ChangeNotifier {
  final EventRepository _repo = EventRepository();
  final _uuid = const Uuid();
  List<Event> _events = [];
  bool _loading = true;

  List<Event> get events => List.unmodifiable(_events);
  bool get loading => _loading;

  List<Event> eventsOn(DateTime day) {
    return _events.where((e) {
      return e.start.year == day.year &&
          e.start.month == day.month &&
          e.start.day == day.day;
    }).toList();
  }

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _events = await _repo.getAll();
    _loading = false;
    notifyListeners();
  }

  Future<void> addEvent({
    required String title,
    String? location,
    required DateTime start,
    DateTime? end,
    bool allDay = false,
  }) async {
    final event = Event(
      id: _uuid.v4(),
      title: title,
      location: location,
      start: start,
      end: end,
      allDay: allDay,
      createdAt: DateTime.now(),
    );
    _events.add(event);
    notifyListeners();
    await _repo.insert(event);
  }

  Future<void> updateEvent(Event event) async {
    final idx = _events.indexWhere((e) => e.id == event.id);
    if (idx != -1) {
      _events[idx] = event;
      notifyListeners();
    }
    await _repo.update(event);
  }

  Future<void> deleteEvent(String id) async {
    _events.removeWhere((e) => e.id == id);
    notifyListeners();
    await _repo.delete(id);
  }
}
