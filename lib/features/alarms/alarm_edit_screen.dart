import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/alarm.dart';
import '../../providers/alarm_provider.dart';

const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
const _sounds = ['default', 'gentle', 'classic', 'chimes'];

class AlarmEditScreen extends StatefulWidget {
  final Alarm? existing;
  const AlarmEditScreen({super.key, this.existing});

  @override
  State<AlarmEditScreen> createState() => _AlarmEditScreenState();
}

class _AlarmEditScreenState extends State<AlarmEditScreen> {
  late TimeOfDay _time;
  late final TextEditingController _labelCtrl;
  Set<int> _repeatDays = {};
  bool _vibrate = true;
  String _sound = 'default';
  int _snooze = 10;

  @override
  void initState() {
    super.initState();
    final a = widget.existing;
    _time = a != null
        ? TimeOfDay(hour: a.hour, minute: a.minute)
        : TimeOfDay.now();
    _labelCtrl = TextEditingController(text: a?.label ?? '');
    _repeatDays = Set.from(a?.repeatDays ?? {});
    _vibrate = a?.vibrate ?? true;
    _sound = a?.soundAsset ?? 'default';
    _snooze = a?.snoozeMinutes ?? 10;
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  void _save() {
    final provider = context.read<AlarmProvider>();
    if (widget.existing == null) {
      provider.addAlarm(
        hour: _time.hour,
        minute: _time.minute,
        label: _labelCtrl.text.trim(),
        repeatDays: _repeatDays,
        vibrate: _vibrate,
        soundAsset: _sound,
        snoozeMinutes: _snooze,
      );
    } else {
      provider.updateAlarm(widget.existing!.copyWith(
        hour: _time.hour,
        minute: _time.minute,
        label: _labelCtrl.text.trim(),
        repeatDays: _repeatDays,
        vibrate: _vibrate,
        soundAsset: _sound,
        snoozeMinutes: _snooze,
      ));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Alarm' : 'New Alarm'),
        actions: [TextButton(onPressed: _save, child: const Text('Save'))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: GestureDetector(
              onTap: _pickTime,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  _time.format(context),
                  style: TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w700,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _labelCtrl,
            decoration: const InputDecoration(hintText: 'Label (optional)'),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 24),
          const Text('Repeat', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Text('Leave empty for a one-time alarm',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: List.generate(7, (i) {
              final weekday = i + 1;
              final selected = _repeatDays.contains(weekday);
              return ChoiceChip(
                label: Text(_dayLabels[i]),
                selected: selected,
                onSelected: (_) => setState(() {
                  if (selected) {
                    _repeatDays.remove(weekday);
                  } else {
                    _repeatDays.add(weekday);
                  }
                }),
              );
            }),
          ),
          const SizedBox(height: 24),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Vibrate'),
            value: _vibrate,
            onChanged: (v) => setState(() => _vibrate = v),
          ),
          const Divider(),
          const Text('Sound', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _sounds.map((s) {
              return ChoiceChip(
                label: Text(s[0].toUpperCase() + s.substring(1)),
                selected: _sound == s,
                onSelected: (_) => setState(() => _sound = s),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
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
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () {
                context.read<AlarmProvider>().deleteAlarm(widget.existing!.id);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete Alarm'),
              style: OutlinedButton.styleFrom(foregroundColor: scheme.error),
            ),
          ],
        ],
      ),
    );
  }
}
