import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/task.dart';
import '../../data/models/reminder.dart';
import '../../providers/reminder_provider.dart';

class ReminderEditScreen extends StatefulWidget {
  final Reminder? existing;
  const ReminderEditScreen({super.key, this.existing});

  @override
  State<ReminderEditScreen> createState() => _ReminderEditScreenState();
}

class _ReminderEditScreenState extends State<ReminderEditScreen> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _notesCtrl;
  late DateTime _dateTime;
  RepeatRule _repeat = RepeatRule.none;
  int _snooze = 10;

  @override
  void initState() {
    super.initState();
    final r = widget.existing;
    _titleCtrl = TextEditingController(text: r?.title ?? '');
    _notesCtrl = TextEditingController(text: r?.notes ?? '');
    _dateTime = r?.dateTime ?? DateTime.now().add(const Duration(hours: 1));
    _repeat = r?.repeat ?? RepeatRule.none;
    _snooze = r?.snoozeMinutes ?? 10;
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (date == null) return;
    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dateTime),
    );
    if (time == null) return;
    setState(() {
      _dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  void _save() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;
    final provider = context.read<ReminderProvider>();
    if (widget.existing == null) {
      provider.addReminder(
        title: title,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        dateTime: _dateTime,
        repeat: _repeat,
        snoozeMinutes: _snooze,
      );
    } else {
      provider.updateReminder(widget.existing!.copyWith(
        title: title,
        notes: _notesCtrl.text.trim(),
        dateTime: _dateTime,
        repeat: _repeat,
        snoozeMinutes: _snooze,
      ));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Reminder' : 'New Reminder'),
        actions: [TextButton(onPressed: _save, child: const Text('Save'))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _titleCtrl,
            autofocus: !isEditing,
            decoration: const InputDecoration(hintText: 'Remind me to...'),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesCtrl,
            maxLines: 2,
            decoration: const InputDecoration(hintText: 'Notes (optional)'),
          ),
          const SizedBox(height: 20),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.access_time_rounded),
            title: Text('${_dateTime.toLocal()}'.substring(0, 16)),
            onTap: _pickDateTime,
          ),
          const Divider(),
          const Text('Repeat', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: RepeatRule.values.map((r) {
              return ChoiceChip(
                label: Text(r.name[0].toUpperCase() + r.name.substring(1)),
                selected: _repeat == r,
                onSelected: (_) => setState(() => _repeat = r),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          const Text('Snooze duration', style: TextStyle(fontWeight: FontWeight.w600)),
          Slider(
            value: _snooze.toDouble(),
            min: 5,
            max: 30,
            divisions: 5,
            label: '$_snooze min',
            onChanged: (v) => setState(() => _snooze = v.round()),
          ),
          if (isEditing) ...[
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                context.read<ReminderProvider>().deleteReminder(widget.existing!.id);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete Reminder'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
