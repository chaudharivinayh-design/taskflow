import 'package:flutter/material.dart';
import '../tasks/task_edit_screen.dart';
import '../tasks/reminder_edit_screen.dart';
import '../alarms/alarm_edit_screen.dart';
import '../tasks/note_edit_screen.dart';
import '../tasks/habit_edit_screen.dart';
import '../calendar/event_edit_screen.dart';

class AddBottomSheet extends StatelessWidget {
  const AddBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final items = [
      _AddItem('Task', Icons.check_circle_outline_rounded, scheme.primary,
          (ctx) => const TaskEditScreen()),
      _AddItem('Reminder', Icons.notifications_active_outlined,
          scheme.secondary, (ctx) => const ReminderEditScreen()),
      _AddItem('Alarm', Icons.alarm_add_rounded, scheme.tertiary,
          (ctx) => const AlarmEditScreen()),
      _AddItem('Note', Icons.sticky_note_2_outlined, scheme.primary,
          (ctx) => const NoteEditScreen()),
      _AddItem('Habit', Icons.local_fire_department_outlined,
          scheme.secondary, (ctx) => const HabitEditScreen()),
      _AddItem('Event', Icons.event_outlined, scheme.tertiary,
          (ctx) => const EventEditScreen()),
    ];

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: scheme.outlineVariant,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            Text('Add something new',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.95,
              children: items
                  .map((item) => _AddTile(item: item))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddItem {
  final String label;
  final IconData icon;
  final Color color;
  final WidgetBuilder builder;
  _AddItem(this.label, this.icon, this.color, this.builder);
}

class _AddTile extends StatelessWidget {
  final _AddItem item;
  const _AddTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: item.builder),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: item.color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, color: item.color, size: 28),
            const SizedBox(height: 8),
            Text(item.label,
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: item.color)),
          ],
        ),
      ),
    );
  }
}
