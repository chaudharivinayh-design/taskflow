import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../providers/task_provider.dart';
import '../../providers/reminder_provider.dart';
import '../../providers/event_provider.dart';
import '../../widgets/empty_state.dart';
import '../tasks/task_edit_screen.dart';
import '../tasks/reminder_edit_screen.dart';
import 'event_edit_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _format = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    final taskP = context.watch<TaskProvider>();
    final reminderP = context.watch<ReminderProvider>();
    final eventP = context.watch<EventProvider>();

    bool hasItems(DateTime day) {
      return taskP.tasksOn(day).isNotEmpty ||
          reminderP.remindersOn(day).isNotEmpty ||
          eventP.eventsOn(day).isNotEmpty;
    }

    final dayTasks = taskP.tasksOn(_selectedDay);
    final dayReminders = reminderP.remindersOn(_selectedDay);
    final dayEvents = eventP.eventsOn(_selectedDay);
    final isEmpty = dayTasks.isEmpty && dayReminders.isEmpty && dayEvents.isEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => EventEditScreen(initialDate: _selectedDay)),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Event'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2035, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            calendarFormat: _format,
            onFormatChanged: (f) => setState(() => _format = f),
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });
            },
            eventLoader: (day) => hasItems(day) ? [true] : [],
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: isEmpty
                ? const EmptyState(
                    emoji: '📅',
                    title: 'Nothing scheduled',
                    subtitle: 'Tap the button below to add an event.',
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    children: [
                      if (dayEvents.isNotEmpty) ...[
                        _SectionLabel('Events'),
                        ...dayEvents.map((e) => _ListRow(
                              icon: Icons.event_rounded,
                              title: e.title,
                              subtitle: e.allDay
                                  ? 'All day'
                                  : DateFormat('h:mm a').format(e.start),
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => EventEditScreen(existing: e))),
                            )),
                      ],
                      if (dayTasks.isNotEmpty) ...[
                        _SectionLabel('Tasks'),
                        ...dayTasks.map((t) => _ListRow(
                              icon: Icons.check_circle_outline_rounded,
                              title: t.title,
                              subtitle: t.dueDate != null
                                  ? DateFormat('h:mm a').format(t.dueDate!)
                                  : '',
                              strikethrough: t.isCompleted,
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => TaskEditScreen(existing: t))),
                            )),
                      ],
                      if (dayReminders.isNotEmpty) ...[
                        _SectionLabel('Reminders'),
                        ...dayReminders.map((r) => _ListRow(
                              icon: Icons.notifications_active_outlined,
                              title: r.title,
                              subtitle: DateFormat('h:mm a').format(r.dateTime),
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => ReminderEditScreen(existing: r))),
                            )),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(text, style: Theme.of(context).textTheme.labelLarge),
    );
  }
}

class _ListRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool strikethrough;
  final VoidCallback onTap;
  const _ListRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.strikethrough = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(
          title,
          style: TextStyle(
            decoration: strikethrough ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: subtitle.isEmpty ? null : Text(subtitle),
        onTap: onTap,
      ),
    );
  }
}
