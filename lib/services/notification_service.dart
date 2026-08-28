import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';

import '../data/models/alarm.dart';
import '../data/models/reminder.dart';
import '../data/models/task.dart';

/// Wraps flutter_local_notifications to provide three kinds of
/// scheduled notifications:
///  - plain reminder notifications (dismissible, snoozable)
///  - task due-date reminders
///  - alarm-clock style notifications (full-screen intent, high priority,
///    looping sound) that behave like a real alarm even when the app
///    is closed or the device is idle, using exact-alarm scheduling.
class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _reminderChannel = AndroidNotificationChannel(
    'reminders_channel',
    'Reminders',
    description: 'Task and reminder notifications',
    importance: Importance.high,
  );

  static const _alarmChannel = AndroidNotificationChannel(
    'alarms_channel',
    'Alarms',
    description: 'Alarm clock notifications',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    try {
      final localZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localZone));
    } catch (_) {
      // Fall back to UTC offset detection if platform lookup fails.
      tz.setLocalLocation(tz.local);
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_reminderChannel);
    await androidPlugin?.createNotificationChannel(_alarmChannel);

    _initialized = true;
  }

  void _onNotificationTap(NotificationResponse response) {
    // Action buttons (Snooze/Dismiss) are handled per-callback where the
    // notification was scheduled; this hook exists for deep-linking back
    // into the app when the body of the notification is tapped.
  }

  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final notif = await Permission.notification.request();
      // Android 12+ requires this for exact alarm scheduling.
      final exactAlarm = await Permission.scheduleExactAlarm.request();
      return notif.isGranted && (exactAlarm.isGranted || exactAlarm.isLimited);
    }
    return true;
  }

  tz.TZDateTime _toTz(DateTime dt) => tz.TZDateTime.from(dt, tz.local);

  DateTimeComponents? _matchComponents(RepeatRule repeat) {
    switch (repeat) {
      case RepeatRule.daily:
      case RepeatRule.weekdays:
        return DateTimeComponents.time;
      case RepeatRule.weekly:
        return DateTimeComponents.dayOfWeekAndTime;
      case RepeatRule.monthly:
        return DateTimeComponents.dayOfMonthAndTime;
      case RepeatRule.none:
        return null;
    }
  }

  // ---------- Reminders ----------

  Future<void> scheduleReminder(Reminder reminder) async {
    if (reminder.dateTime.isBefore(DateTime.now()) &&
        reminder.repeat == RepeatRule.none) {
      return; // don't schedule reminders in the past
    }
    await _plugin.zonedSchedule(
      reminder.notificationId,
      reminder.title,
      reminder.notes?.isNotEmpty == true ? reminder.notes : 'Reminder',
      _toTz(reminder.dateTime),
      NotificationDetails(
        android: AndroidNotificationDetails(
          _reminderChannel.id,
          _reminderChannel.name,
          channelDescription: _reminderChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          category: AndroidNotificationCategory.reminder,
          actions: const [
            AndroidNotificationAction('snooze', 'Snooze'),
            AndroidNotificationAction('dismiss', 'Dismiss'),
          ],
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: _matchComponents(reminder.repeat),
    );
  }

  Future<void> snoozeReminder(Reminder reminder) async {
    final newTime =
        DateTime.now().add(Duration(minutes: reminder.snoozeMinutes));
    await scheduleReminder(reminder.copyWith(dateTime: newTime));
  }

  Future<void> cancelReminder(Reminder reminder) async {
    await _plugin.cancel(reminder.notificationId);
  }

  // ---------- Task due-date notifications ----------

  Future<void> scheduleTaskDueNotification(Task task) async {
    if (task.dueDate == null) return;
    if (task.dueDate!.isBefore(DateTime.now())) return;
    await _plugin.zonedSchedule(
      task.id.hashCode & 0x7fffffff,
      'Task due: ${task.title}',
      'Tap to open TaskFlow',
      _toTz(task.dueDate!),
      NotificationDetails(
        android: AndroidNotificationDetails(
          _reminderChannel.id,
          _reminderChannel.name,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: _matchComponents(task.repeat),
    );
  }

  Future<void> cancelTaskNotification(Task task) async {
    await _plugin.cancel(task.id.hashCode & 0x7fffffff);
  }

  // ---------- Alarms ----------

  /// Schedules a full-screen, high-priority alarm notification. If the
  /// alarm repeats on specific weekdays, one exact alarm is scheduled per
  /// upcoming weekday (each re-arms itself for +7 days once fired, via
  /// [matchDateTimeComponents] set to dayOfWeekAndTime).
  Future<void> scheduleAlarm(Alarm alarm) async {
    if (!alarm.isEnabled) {
      await cancelAlarm(alarm);
      return;
    }

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _alarmChannel.id,
        _alarmChannel.name,
        channelDescription: _alarmChannel.description,
        importance: Importance.max,
        priority: Priority.max,
        category: AndroidNotificationCategory.alarm,
        fullScreenIntent: true,
        ongoing: true,
        autoCancel: false,
        enableVibration: alarm.vibrate,
        playSound: true,
        sound: alarm.soundAsset == 'default'
            ? null
            : RawResourceAndroidNotificationSound(alarm.soundAsset),
        actions: const [
          AndroidNotificationAction('snooze', 'Snooze'),
          AndroidNotificationAction('dismiss', 'Dismiss'),
        ],
      ),
      iOS: const DarwinNotificationDetails(
        interruptionLevel: InterruptionLevel.timeSensitive,
      ),
    );

    if (!alarm.isRepeating) {
      final next = _nextOneTimeOccurrence(alarm.hour, alarm.minute);
      await _plugin.zonedSchedule(
        alarm.notificationId,
        alarm.label.isNotEmpty ? alarm.label : 'Alarm',
        alarm.timeLabel,
        next,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      return;
    }

    // One sub-id per weekday so each can independently re-fire weekly.
    for (final weekday in alarm.repeatDays) {
      final next = _nextWeekdayOccurrence(weekday, alarm.hour, alarm.minute);
      await _plugin.zonedSchedule(
        alarm.notificationId + weekday,
        alarm.label.isNotEmpty ? alarm.label : 'Alarm',
        alarm.timeLabel,
        next,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  Future<void> snoozeAlarm(Alarm alarm) async {
    final next =
        tz.TZDateTime.now(tz.local).add(Duration(minutes: alarm.snoozeMinutes));
    await _plugin.zonedSchedule(
      alarm.notificationId + 900, // offset id so it doesn't clash
      '${alarm.label.isNotEmpty ? alarm.label : 'Alarm'} (snoozed)',
      alarm.timeLabel,
      next,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _alarmChannel.id,
          _alarmChannel.name,
          importance: Importance.max,
          priority: Priority.max,
          category: AndroidNotificationCategory.alarm,
          fullScreenIntent: true,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelAlarm(Alarm alarm) async {
    await _plugin.cancel(alarm.notificationId);
    for (var weekday = 1; weekday <= 7; weekday++) {
      await _plugin.cancel(alarm.notificationId + weekday);
    }
  }

  tz.TZDateTime _nextOneTimeOccurrence(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  tz.TZDateTime _nextWeekdayOccurrence(int weekday, int hour, int minute) {
    var scheduled = _nextOneTimeOccurrence(hour, minute);
    while (scheduled.weekday != weekday) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  Future<void> cancelAll() async => _plugin.cancelAll();
}
