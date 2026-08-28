import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/reminder_provider.dart';
import '../../providers/alarm_provider.dart';
import '../../providers/habit_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/progress_ring.dart';
import '../../widgets/empty_state.dart';
import '../smart_command/smart_command_bar.dart';
import '../tasks/task_edit_screen.dart';
import 'widgets/task_tile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final taskP = context.watch<TaskProvider>();
    final reminderP = context.watch<ReminderProvider>();
    final alarmP = context.watch<AlarmProvider>();
    final habitP = context.watch<HabitProvider>();
    final settings = context.watch<SettingsProvider>();

    final today = DateTime.now();
    final dateStr = DateFormat('EEEE, MMMM d').format(today);
    final focusTasks = taskP.todayFocus;
    final completedToday = focusTasks.where((t) => t.isCompleted).length;
    final progress = focusTasks.isEmpty
        ? 0.0
        : completedToday / focusTasks.length;
    final upcoming = taskP.pending
        .where((t) => t.dueDate != null && t.dueDate!.isAfter(today))
        .take(4)
        .toList();
    final nextReminder = reminderP.next;
    final nextAlarm = alarmP.nextAlarm;
    final dueHabits = habitP.dueToday;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          await taskP.load();
          await reminderP.load();
          await alarmP.load();
          await habitP.load();
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        settings.userName.isEmpty
                            ? _greeting()
                            : '${_greeting()}, ${settings.userName}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      Text(dateStr,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              )),
                    ],
                  ),
                ),
                if (focusTasks.isNotEmpty)
                  ProgressRing(
                    progress: progress,
                    centerLabel: '$completedToday/${focusTasks.length}',
                  ),
              ],
            ),
            const SizedBox(height: 20),
            const SmartCommandBar(),
            const SizedBox(height: 24),

            if (nextReminder != null || nextAlarm != null)
              Row(
                children: [
                  if (nextReminder != null)
                    Expanded(
                      child: _InfoPill(
                        icon: Icons.notifications_active_rounded,
                        label: 'Next reminder',
                        value: DateFormat('MMM d, h:mm a').format(nextReminder.dateTime),
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        onColor: Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                    ),
                  if (nextReminder != null && nextAlarm != null)
                    const SizedBox(width: 12),
                  if (nextAlarm != null)
                    Expanded(
                      child: _InfoPill(
                        icon: Icons.alarm_rounded,
                        label: 'Next alarm',
                        value: nextAlarm.timeLabel,
                        color: Theme.of(context).colorScheme.tertiaryContainer,
                        onColor: Theme.of(context).colorScheme.onTertiaryContainer,
                      ),
                    ),
                ],
              ),
            if (nextReminder != null || nextAlarm != null) const SizedBox(height: 24),

            Text("Today's focus",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            if (focusTasks.isEmpty)
              const EmptyState(
                emoji: '🌱',
                title: 'Nothing due today',
                subtitle: 'Enjoy the calm, or add something with the + button.',
              )
            else
              ...focusTasks.map((t) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: TaskTile(
                      task: t,
                      onToggle: () => taskP.toggleComplete(t),
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => TaskEditScreen(existing: t))),
                    ),
                  )),

            if (dueHabits.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text('Habits today',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: dueHabits.map((h) {
                  final done = h.isCompletedOn(DateTime.now());
                  return GestureDetector(
                    onTap: () => habitP.toggleToday(h),
                    child: Chip(
                      avatar: Text(h.emoji),
                      label: Text('${h.title} • ${h.currentStreak}🔥'),
                      backgroundColor: done
                          ? Theme.of(context).colorScheme.primaryContainer
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],

            if (upcoming.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text('Upcoming',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              ...upcoming.map((t) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: TaskTile(
                      task: t,
                      onToggle: () => taskP.toggleComplete(t),
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => TaskEditScreen(existing: t))),
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color onColor;
  const _InfoPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: onColor, size: 20),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(fontSize: 12, color: onColor.withOpacity(0.8))),
          Text(value, style: TextStyle(fontWeight: FontWeight.w700, color: onColor)),
        ],
      ),
    );
  }
}
