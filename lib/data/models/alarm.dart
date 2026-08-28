/// Days of week bitmask helper: Monday = 1 ... Sunday = 7 (DateTime.weekday).
class Alarm {
  final String id;
  final String label;
  final int hour;
  final int minute;
  /// Set of DateTime.weekday values (1=Mon..7=Sun). Empty = one-time alarm.
  final Set<int> repeatDays;
  final bool isEnabled;
  final bool vibrate;
  final String soundAsset; // 'default', 'gentle', 'classic', 'chimes'
  final int snoozeMinutes;
  final DateTime createdAt;

  const Alarm({
    required this.id,
    required this.label,
    required this.hour,
    required this.minute,
    this.repeatDays = const {},
    this.isEnabled = true,
    this.vibrate = true,
    this.soundAsset = 'default',
    this.snoozeMinutes = 10,
    required this.createdAt,
  });

  bool get isRepeating => repeatDays.isNotEmpty;

  Alarm copyWith({
    String? label,
    int? hour,
    int? minute,
    Set<int>? repeatDays,
    bool? isEnabled,
    bool? vibrate,
    String? soundAsset,
    int? snoozeMinutes,
  }) {
    return Alarm(
      id: id,
      label: label ?? this.label,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      repeatDays: repeatDays ?? this.repeatDays,
      isEnabled: isEnabled ?? this.isEnabled,
      vibrate: vibrate ?? this.vibrate,
      soundAsset: soundAsset ?? this.soundAsset,
      snoozeMinutes: snoozeMinutes ?? this.snoozeMinutes,
      createdAt: createdAt,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'label': label,
      'hour': hour,
      'minute': minute,
      'repeatDays': repeatDays.join(','),
      'isEnabled': isEnabled ? 1 : 0,
      'vibrate': vibrate ? 1 : 0,
      'soundAsset': soundAsset,
      'snoozeMinutes': snoozeMinutes,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Alarm.fromMap(Map<String, Object?> map) {
    final daysStr = (map['repeatDays'] as String? ?? '').trim();
    final days = daysStr.isEmpty
        ? <int>{}
        : daysStr.split(',').map((e) => int.parse(e)).toSet();
    return Alarm(
      id: map['id'] as String,
      label: map['label'] as String,
      hour: map['hour'] as int,
      minute: map['minute'] as int,
      repeatDays: days,
      isEnabled: (map['isEnabled'] as int? ?? 1) == 1,
      vibrate: (map['vibrate'] as int? ?? 1) == 1,
      soundAsset: map['soundAsset'] as String? ?? 'default',
      snoozeMinutes: map['snoozeMinutes'] as int? ?? 10,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    );
  }

  int get notificationId => id.hashCode & 0x7fffffff;

  String get timeLabel {
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final period = hour < 12 ? 'AM' : 'PM';
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m $period';
  }
}
