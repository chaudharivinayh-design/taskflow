import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/habit_provider.dart';

const _emojiOptions = ['🔥', '💧', '📖', '🏃', '🧘', '🥗', '😴', '💪'];
const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

class HabitEditScreen extends StatefulWidget {
  const HabitEditScreen({super.key});

  @override
  State<HabitEditScreen> createState() => _HabitEditScreenState();
}

class _HabitEditScreenState extends State<HabitEditScreen> {
  final _titleCtrl = TextEditingController();
  String _emoji = '🔥';
  final Set<int> _selectedDays = {}; // empty = every day

  void _save() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;
    context.read<HabitProvider>().addHabit(
          title,
          emoji: _emoji,
          targetWeekdays: _selectedDays,
        );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Habit'),
        actions: [TextButton(onPressed: _save, child: const Text('Save'))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _titleCtrl,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'e.g. Drink water'),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 20),
          const Text('Icon', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _emojiOptions.map((e) {
              return ChoiceChip(
                label: Text(e, style: const TextStyle(fontSize: 18)),
                selected: _emoji == e,
                onSelected: (_) => setState(() => _emoji = e),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          const Text('Repeat on', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Text('Leave empty for every day',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: List.generate(7, (i) {
              final weekday = i + 1;
              final selected = _selectedDays.contains(weekday);
              return ChoiceChip(
                label: Text(_dayLabels[i]),
                selected: selected,
                onSelected: (_) => setState(() {
                  if (selected) {
                    _selectedDays.remove(weekday);
                  } else {
                    _selectedDays.add(weekday);
                  }
                }),
              );
            }),
          ),
        ],
      ),
    );
  }
}
