import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/task.dart';
import '../../providers/task_provider.dart';

class TaskEditScreen extends StatefulWidget {
  final Task? existing;
  const TaskEditScreen({super.key, this.existing});

  @override
  State<TaskEditScreen> createState() => _TaskEditScreenState();
}

class _TaskEditScreenState extends State<TaskEditScreen> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _notesCtrl;
  DateTime? _dueDate;
  TaskPriority _priority = TaskPriority.medium;
  RepeatRule _repeat = RepeatRule.none;

  @override
  void initState() {
    super.initState();
    final t = widget.existing;
    _titleCtrl = TextEditingController(text: t?.title ?? '');
    _notesCtrl = TextEditingController(text: t?.notes ?? '');
    _dueDate = t?.dueDate;
    _priority = t?.priority ?? TaskPriority.medium;
    _repeat = t?.repeat ?? RepeatRule.none;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (date == null) return;
    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dueDate ?? DateTime.now()),
    );
    setState(() {
      _dueDate = DateTime(
        date.year,
        date.month,
        date.day,
        time?.hour ?? 9,
        time?.minute ?? 0,
      );
    });
  }

  void _save() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;
    final provider = context.read<TaskProvider>();
    if (widget.existing == null) {
      provider.addTask(
        title: title,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        dueDate: _dueDate,
        priority: _priority,
        repeat: _repeat,
      );
    } else {
      provider.updateTask(widget.existing!.copyWith(
        title: title,
        notes: _notesCtrl.text.trim(),
        dueDate: _dueDate,
        clearDueDate: _dueDate == null,
        priority: _priority,
        repeat: _repeat,
      ));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Task' : 'New Task'),
        actions: [
          TextButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _titleCtrl,
            autofocus: !isEditing,
            decoration: const InputDecoration(hintText: 'What needs to be done?'),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesCtrl,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'Notes (optional)'),
          ),
          const SizedBox(height: 20),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today_rounded),
            title: Text(_dueDate == null
                ? 'Add due date & time'
                : '${_dueDate!.toLocal()}'.substring(0, 16)),
            trailing: _dueDate != null
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() => _dueDate = null),
                  )
                : null,
            onTap: _pickDateTime,
          ),
          const Divider(),
          const SizedBox(height: 8),
          const Text('Priority', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: TaskPriority.values.map((p) {
              return ChoiceChip(
                label: Text(p.name[0].toUpperCase() + p.name.substring(1)),
                selected: _priority == p,
                onSelected: (_) => setState(() => _priority = p),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          const Text('Repeat', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: RepeatRule.values.map((r) {
              return ChoiceChip(
                label: Text(_repeatLabel(r)),
                selected: _repeat == r,
                onSelected: (_) => setState(() => _repeat = r),
              );
            }).toList(),
          ),
          if (isEditing) ...[
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () {
                context.read<TaskProvider>().deleteTask(widget.existing!.id);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete Task'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _repeatLabel(RepeatRule r) {
    switch (r) {
      case RepeatRule.none:
        return 'Never';
      case RepeatRule.daily:
        return 'Daily';
      case RepeatRule.weekly:
        return 'Weekly';
      case RepeatRule.monthly:
        return 'Monthly';
      case RepeatRule.weekdays:
        return 'Weekdays';
    }
  }
}
