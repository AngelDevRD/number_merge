import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/stats_provider.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Estadisticas')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _StatTile(
            icon: Icons.videogame_asset,
            label: 'Partidas jugadas',
            value: '${stats.gamesPlayed}',
          ),
          _StatTile(
            icon: Icons.timer,
            label: 'Tiempo total jugado',
            value: _formatDuration(stats.totalSecondsPlayed),
          ),
          _StatTile(
            icon: Icons.star,
            label: 'Mejor ficha alcanzada',
            value: '${stats.bestTileEver}',
          ),
          _StatTile(
            icon: Icons.touch_app,
            label: 'Movimientos totales',
            value: '${stats.totalMoves}',
          ),
          _StatTile(
            icon: Icons.emoji_events,
            label: 'Puntos acumulados en total',
            value: '${stats.totalScoreEver}',
          ),
        ],
      ),
    );
  }

  String _formatDuration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    if (hours > 0) return '${hours}h ${minutes}m';
    if (minutes > 0) return '${minutes}m ${seconds}s';
    return '${seconds}s';
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(label),
        trailing: Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
