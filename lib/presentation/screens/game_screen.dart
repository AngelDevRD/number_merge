import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/game_provider.dart';
import '../../providers/settings_provider.dart';
import '../widgets/board_widget.dart';
import '../widgets/onboarding_overlay.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  bool _showOnboarding = false;
  bool _checkedOnboarding = false;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    if (settings.loaded && !_checkedOnboarding) {
      _checkedOnboarding = true;
      _showOnboarding = !settings.onboardingShown;
    }

    final gameState = ref.watch(gameProvider);
    final gameNotifier = ref.read(gameProvider.notifier);

    ref.listen(gameProvider, (previous, next) {
      if (next.isGameOver && previous?.isGameOver == false) {
        _showGameOverDialog(context, next.hasWon);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Number Merge'),
        actions: [
          IconButton(
            tooltip: 'Deshacer',
            icon: const Icon(Icons.undo),
            onPressed: gameNotifier.canUndo ? gameNotifier.undo : null,
          ),
          IconButton(
            tooltip: 'Reiniciar',
            icon: const Icon(Icons.refresh),
            onPressed: () => _confirmRestart(context, gameNotifier),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ScoreBadge(label: 'Puntaje', value: gameState.score),
                      _ScoreBadge(label: 'Mejor', value: gameState.bestScore),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: BoardWidget(
                      board: gameState.board,
                      onSwipe: gameNotifier.move,
                    ),
                  ),
                ),
              ],
            ),
            if (_showOnboarding)
              OnboardingOverlay(
                onDismiss: () {
                  setState(() => _showOnboarding = false);
                  ref.read(settingsProvider.notifier).setOnboardingShown(true);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmRestart(
    BuildContext context,
    GameNotifier notifier,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reiniciar partida'),
        content: const Text('Se perdera el progreso actual. Deseas continuar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reiniciar'),
          ),
        ],
      ),
    );
    if (confirmed == true) notifier.restart();
  }

  void _showGameOverDialog(BuildContext context, bool hasWon) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(hasWon ? 'Has ganado!' : 'Juego terminado'),
        content: Text(
          hasWon
              ? 'Alcanzaste la ficha 2048. Puedes seguir intentando superar tu puntaje.'
              : 'Ya no quedan movimientos posibles.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(gameProvider.notifier).restart();
            },
            child: const Text('Nueva partida'),
          ),
        ],
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final String label;
  final int value;

  const _ScoreBadge({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          Text(
            '$value',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
