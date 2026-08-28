import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/event.dart';
import '../../providers/event_provider.dart';

class EventEditScreen extends StatefulWidget {
  final Event? existing;
  final DateTime? initialDate;
  const EventEditScreen({super.key, this.existing, this.initialDate});

  @override
  State<EventEditScreen> createState() => _EventEditScreenState();
}

class _EventEditScreenState extends State<EventEditScreen> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _locationCtrl;
  late DateTime _start;
  DateTime? _end;
  bool _allDay = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleCtrl = TextEditingController(text: e?.title ?? '');
    _locationCtrl = TextEditingController(text: e?.location ?? '');
    _start = e?.start ?? (widget.initialDate ?? DateTime.now());
    _end = e?.end;
    _allDay = e?.allDay ?? false;
  }

  Future<void> _pickStart() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _start,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (date == null) return;
    if (_allDay) {
      setState(() => _start = DateTime(date.year, date.month, date.day));
      return;
    }
    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_start),
    );
    setState(() {
      _start = DateTime(date.year, date.month, date.day, time?.hour ?? 9, time?.minute ?? 0);
    });
  }

  void _save() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;
    final provider = context.read<EventProvider>();
    if (widget.existing == null) {
      provider.addEvent(
        title: title,
        location: _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim(),
        start: _start,
        end: _end,
        allDay: _allDay,
      );
    } else {
      provider.updateEvent(widget.existing!.copyWith(
        title: title,
        location: _locationCtrl.text.trim(),
        start: _start,
        end: _end,
        allDay: _allDay,
      ));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Event' : 'New Event'),
        actions: [TextButton(onPressed: _save, child: const Text('Save'))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _titleCtrl,
            autofocus: !isEditing,
            decoration: const InputDecoration(hintText: 'Event title'),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _locationCtrl,
            decoration: const InputDecoration(hintText: 'Location (optional)'),
          ),
          const SizedBox(height: 20),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('All day'),
            value: _allDay,
            onChanged: (v) => setState(() => _allDay = v),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event_rounded),
            title: Text(_allDay
                ? '${_start.toLocal()}'.substring(0, 10)
                : '${_start.toLocal()}'.substring(0, 16)),
            onTap: _pickStart,
          ),
          if (isEditing) ...[
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                context.read<EventProvider>().deleteEvent(widget.existing!.id);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete Event'),
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
