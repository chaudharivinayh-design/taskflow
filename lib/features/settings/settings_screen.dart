import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/styles.dart';
import '../../providers/settings_provider.dart';
import '../../services/notification_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SectionTitle('Visual style'),
          const SizedBox(height: 12),
          ...AppStyle.values.map((style) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _StyleOption(
                  style: style,
                  selected: settings.style == style,
                  onTap: () => settings.setStyle(style),
                ),
              )),
          const SizedBox(height: 24),
          _SectionTitle('Appearance'),
          const SizedBox(height: 8),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.light, label: Text('Light'), icon: Icon(Icons.light_mode_outlined)),
              ButtonSegment(value: ThemeMode.dark, label: Text('Dark'), icon: Icon(Icons.dark_mode_outlined)),
              ButtonSegment(value: ThemeMode.system, label: Text('System'), icon: Icon(Icons.brightness_auto_outlined)),
            ],
            selected: {settings.themeMode},
            onSelectionChanged: (s) => settings.setThemeMode(s.first),
          ),
          const SizedBox(height: 24),
          _SectionTitle('Notifications'),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.notifications_active_outlined),
              title: const Text('Enable notifications & exact alarms'),
              subtitle: const Text('Required for reminders and alarms to fire reliably'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () async {
                final granted = await NotificationService.instance.requestPermissions();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(granted
                          ? 'Permissions granted'
                          : 'Some permissions were not granted — alarms may be delayed'),
                    ),
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 24),
          _SectionTitle('About'),
          const SizedBox(height: 8),
          const Card(
            child: ListTile(
              leading: Icon(Icons.info_outline_rounded),
              title: Text('TaskFlow'),
              subtitle: Text('Tasks. Reminders. Alarms. Simplified.\nVersion 1.0.0'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700));
  }
}

class _StyleOption extends StatelessWidget {
  final AppStyle style;
  final bool selected;
  final VoidCallback onTap;
  const _StyleOption({required this.style, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final palette = StylePalette.forStyle(style);
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? scheme.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [palette.accent, palette.secondaryAccent],
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(style.label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  Text(style.description, style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13)),
                ],
              ),
            ),
            if (selected) Icon(Icons.check_circle_rounded, color: scheme.primary),
          ],
        ),
      ),
    );
  }
}
