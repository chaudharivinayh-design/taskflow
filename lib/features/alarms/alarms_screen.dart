import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/alarm.dart';
import '../../providers/alarm_provider.dart';
import '../../widgets/empty_state.dart';
import 'alarm_edit_screen.dart';

const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

class AlarmsScreen extends StatelessWidget {
  const AlarmsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AlarmProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Alarms')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const AlarmEditScreen())),
        child: const Icon(Icons.add),
      ),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : provider.alarms.isEmpty
              ? const Center(
                  child: EmptyState(
                    emoji: '⏰',
                    title: 'No alarms set',
                    subtitle: 'Tap + to create your first alarm.',
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  itemCount: provider.alarms.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final alarm = provider.alarms[i];
                    return _AlarmCard(alarm: alarm);
                  },
                ),
    );
  }
}

class _AlarmCard extends StatelessWidget {
  final Alarm alarm;
  const _AlarmCard({required this.alarm});

  String _repeatSummary() {
    if (alarm.repeatDays.isEmpty) return 'Once';
    if (alarm.repeatDays.length == 7) return 'Every day';
    final sorted = alarm.repeatDays.toList()..sort();
    return sorted.map((d) => _dayLabels[d - 1]).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => AlarmEditScreen(existing: alarm))),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alarm.timeLabel,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: alarm.isEnabled ? scheme.onSurface : scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [
                        if (alarm.label.isNotEmpty) alarm.label,
                        _repeatSummary(),
                      ].join(' • '),
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Switch(
                value: alarm.isEnabled,
                onChanged: (_) => context.read<AlarmProvider>().toggleEnabled(alarm),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
