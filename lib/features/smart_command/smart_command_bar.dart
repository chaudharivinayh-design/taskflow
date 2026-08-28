import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/utils/smart_parser.dart';
import '../../providers/task_provider.dart';
import '../../providers/reminder_provider.dart';
import '../../providers/alarm_provider.dart';
import '../../providers/event_provider.dart';

class SmartCommandBar extends StatefulWidget {
  const SmartCommandBar({super.key});

  @override
  State<SmartCommandBar> createState() => _SmartCommandBarState();
}

class _SmartCommandBarState extends State<SmartCommandBar> {
  final _ctrl = TextEditingController();

  Future<void> _submit() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    final result = SmartParser.parse(text);
    final confirmed = await _showConfirmation(result);
    if (confirmed != true) return;

    if (!mounted) return;
    switch (result.type) {
      case SmartIntentType.task:
        context.read<TaskProvider>().addTask(
              title: result.title,
              dueDate: result.dateTime,
            );
        break;
      case SmartIntentType.reminder:
        context.read<ReminderProvider>().addReminder(
              title: result.title,
              dateTime: result.dateTime ?? DateTime.now().add(const Duration(hours: 1)),
            );
        break;
      case SmartIntentType.alarm:
        final dt = result.dateTime ?? DateTime.now();
        context.read<AlarmProvider>().addAlarm(
              hour: dt.hour,
              minute: dt.minute,
              label: result.title,
            );
        break;
      case SmartIntentType.event:
        context.read<EventProvider>().addEvent(
              title: result.title,
              start: result.dateTime ?? DateTime.now().add(const Duration(hours: 1)),
            );
        break;
    }

    _ctrl.clear();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added: ${result.title}')),
      );
    }
  }

  Future<bool?> _showConfirmation(SmartParseResult result) {
    final typeLabel = switch (result.type) {
      SmartIntentType.task => 'Task',
      SmartIntentType.reminder => 'Reminder',
      SmartIntentType.alarm => 'Alarm',
      SmartIntentType.event => 'Event',
    };
    final dtLabel = result.dateTime != null
        ? DateFormat('EEEE, MMM d • h:mm a').format(result.dateTime!)
        : 'No date/time detected';

    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Create $typeLabel?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(result.title, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time_rounded, size: 16),
                const SizedBox(width: 6),
                Text(dtLabel),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _ctrl,
      onSubmitted: (_) => _submit(),
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        hintText: 'Try "Pay bill tomorrow 7 PM"',
        prefixIcon: const Icon(Icons.auto_awesome_rounded),
        suffixIcon: IconButton(
          icon: const Icon(Icons.arrow_forward_rounded),
          onPressed: _submit,
        ),
      ),
    );
  }
}
