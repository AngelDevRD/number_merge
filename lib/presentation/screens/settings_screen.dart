import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/settings_repository.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Configuracion')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Tema', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SegmentedButton<AppThemeMode>(
            segments: const [
              ButtonSegment(
                value: AppThemeMode.system,
                label: Text('Sistema'),
                icon: Icon(Icons.brightness_auto),
              ),
              ButtonSegment(
                value: AppThemeMode.light,
                label: Text('Claro'),
                icon: Icon(Icons.light_mode),
              ),
              ButtonSegment(
                value: AppThemeMode.dark,
                label: Text('Oscuro'),
                icon: Icon(Icons.dark_mode),
              ),
            ],
            selected: {settings.themeMode},
            onSelectionChanged: (selection) {
              notifier.setThemeMode(selection.first);
            },
          ),
          const SizedBox(height: 24),
          SwitchListTile(
            title: const Text('Sonido'),
            subtitle: const Text(
              'Efectos de sonido al mover y combinar fichas',
            ),
            value: settings.soundOn,
            onChanged: notifier.setSoundOn,
          ),
          SwitchListTile(
            title: const Text('Vibracion'),
            subtitle: const Text('Vibrar al combinar fichas'),
            value: settings.vibrationOn,
            onChanged: notifier.setVibrationOn,
          ),
        ],
      ),
    );
  }
}
