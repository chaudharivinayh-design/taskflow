import '../../data/models/task.dart';

enum SmartIntentType { task, reminder, alarm, event }

class SmartParseResult {
  final SmartIntentType type;
  final String title;
  final DateTime? dateTime;
  final bool isTimeOnly; // e.g. "wake me up at 6 AM" -> alarm, no date needed

  const SmartParseResult({
    required this.type,
    required this.title,
    this.dateTime,
    this.isTimeOnly = false,
  });
}

/// A lightweight, fully-offline natural-language parser tailored to the
/// kinds of short commands TaskFlow expects, e.g.:
///   "Pay electricity bill tomorrow 7 PM"
///   "Call Rahul Friday 5 PM"
///   "Wake me up at 6 AM"
/// It never calls any network/AI service — everything is resolved with
/// regex + date arithmetic so it works fully offline.
class SmartParser {
  static const _weekdays = {
    'monday': DateTime.monday,
    'mon': DateTime.monday,
    'tuesday': DateTime.tuesday,
    'tue': DateTime.tuesday,
    'tues': DateTime.tuesday,
    'wednesday': DateTime.wednesday,
    'wed': DateTime.wednesday,
    'thursday': DateTime.thursday,
    'thu': DateTime.thursday,
    'thurs': DateTime.thursday,
    'friday': DateTime.friday,
    'fri': DateTime.friday,
    'saturday': DateTime.saturday,
    'sat': DateTime.saturday,
    'sunday': DateTime.sunday,
    'sun': DateTime.sunday,
  };

  static final _timeRegex = RegExp(
    r'\b(at\s+)?(\d{1,2})(:(\d{2}))?\s*(am|pm)\b',
    caseSensitive: false,
  );

  static SmartParseResult parse(String rawInput) {
    final input = rawInput.trim();
    final lower = input.toLowerCase();

    // 1. Decide intent type from keywords.
    SmartIntentType type = SmartIntentType.task;
    if (RegExp(r'\bwake me up\b|\balarm\b').hasMatch(lower)) {
      type = SmartIntentType.alarm;
    } else if (RegExp(r'\bremind me\b|\breminder\b').hasMatch(lower)) {
      type = SmartIntentType.reminder;
    } else if (RegExp(r'\bmeeting\b|\bevent\b|\bappointment\b|\bcall\b')
        .hasMatch(lower)) {
      type = SmartIntentType.event;
    }

    // 2. Extract time (e.g. "7 PM", "6:30 am").
    DateTime now = DateTime.now();
    int? hour;
    int minute = 0;
    final timeMatch = _timeRegex.firstMatch(lower);
    if (timeMatch != null) {
      var h = int.parse(timeMatch.group(2)!);
      minute = timeMatch.group(4) != null ? int.parse(timeMatch.group(4)!) : 0;
      final period = timeMatch.group(5)!.toLowerCase();
      if (period == 'pm' && h != 12) h += 12;
      if (period == 'am' && h == 12) h = 0;
      hour = h;
    }

    // 3. Extract date: today / tomorrow / weekday name / explicit "in N days".
    DateTime baseDate = DateTime(now.year, now.month, now.day);
    bool dateFound = false;

    if (lower.contains('tomorrow')) {
      baseDate = baseDate.add(const Duration(days: 1));
      dateFound = true;
    } else if (lower.contains('today') || lower.contains('tonight')) {
      dateFound = true;
    } else {
      for (final entry in _weekdays.entries) {
        if (RegExp('\\b${entry.key}\\b').hasMatch(lower)) {
          var d = baseDate;
          while (d.weekday != entry.value) {
            d = d.add(const Duration(days: 1));
          }
          // If it's today's weekday but time already passed, roll to next week.
          if (d == baseDate && hour != null) {
            final candidate = DateTime(d.year, d.month, d.day, hour, minute);
            if (candidate.isBefore(now)) {
              d = d.add(const Duration(days: 7));
            }
          }
          baseDate = d;
          dateFound = true;
          break;
        }
      }
    }

    final inDaysMatch =
        RegExp(r'in\s+(\d+)\s+day(s)?').firstMatch(lower);
    if (inDaysMatch != null) {
      final n = int.parse(inDaysMatch.group(1)!);
      baseDate = baseDate.add(Duration(days: n));
      dateFound = true;
    }

    DateTime? finalDateTime;
    bool isTimeOnly = false;

    if (hour != null && dateFound) {
      finalDateTime = DateTime(baseDate.year, baseDate.month, baseDate.day, hour, minute);
    } else if (hour != null && !dateFound) {
      // Only a time was given (typical alarm phrasing) -> next occurrence.
      var candidate = DateTime(now.year, now.month, now.day, hour, minute);
      if (candidate.isBefore(now)) {
        candidate = candidate.add(const Duration(days: 1));
      }
      finalDateTime = candidate;
      isTimeOnly = type == SmartIntentType.alarm;
    } else if (dateFound) {
      // Date but no time -> default to 9:00 AM.
      finalDateTime = DateTime(baseDate.year, baseDate.month, baseDate.day, 9, 0);
    }

    // 4. Clean the title: strip recognized date/time phrases and filler words.
    String title = input;
    title = title.replaceAll(_timeRegex, '');
    title = title.replaceAll(RegExp(r'\btomorrow\b', caseSensitive: false), '');
    title = title.replaceAll(RegExp(r'\btoday\b|\btonight\b', caseSensitive: false), '');
    title = title.replaceAll(RegExp(r'\bwake me up\b', caseSensitive: false), '');
    title = title.replaceAll(RegExp(r'\bremind me( to)?\b', caseSensitive: false), '');
    title = title.replaceAll(RegExp(r'\bin\s+\d+\s+day(s)?\b', caseSensitive: false), '');
    for (final key in _weekdays.keys) {
      title = title.replaceAll(RegExp('\\b$key\\b', caseSensitive: false), '');
    }
    title = title.replaceAll(RegExp(r'\bat\b', caseSensitive: false), '');
    title = title.replaceAll(RegExp(r'\s{2,}'), ' ').trim();
    if (title.isEmpty) {
      title = type == SmartIntentType.alarm ? 'Alarm' : 'New item';
    } else {
      title = title[0].toUpperCase() + title.substring(1);
    }

    return SmartParseResult(
      type: type,
      title: title,
      dateTime: finalDateTime,
      isTimeOnly: isTimeOnly,
    );
  }
}

// Re-export so callers only need to import this file for repeat rules too.
typedef SmartRepeatRule = RepeatRule;
