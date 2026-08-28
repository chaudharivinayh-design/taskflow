/// A calendar event with a start and optional end time.
class Event {
  final String id;
  final String title;
  final String? location;
  final DateTime start;
  final DateTime? end;
  final bool allDay;
  final DateTime createdAt;

  const Event({
    required this.id,
    required this.title,
    this.location,
    required this.start,
    this.end,
    this.allDay = false,
    required this.createdAt,
  });

  Event copyWith({
    String? title,
    String? location,
    DateTime? start,
    DateTime? end,
    bool? allDay,
  }) {
    return Event(
      id: id,
      title: title ?? this.title,
      location: location ?? this.location,
      start: start ?? this.start,
      end: end ?? this.end,
      allDay: allDay ?? this.allDay,
      createdAt: createdAt,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'location': location,
      'start': start.millisecondsSinceEpoch,
      'end': end?.millisecondsSinceEpoch,
      'allDay': allDay ? 1 : 0,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Event.fromMap(Map<String, Object?> map) {
    return Event(
      id: map['id'] as String,
      title: map['title'] as String,
      location: map['location'] as String?,
      start: DateTime.fromMillisecondsSinceEpoch(map['start'] as int),
      end: map['end'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(map['end'] as int),
      allDay: (map['allDay'] as int? ?? 0) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    );
  }
}
