import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/tile.dart';
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
  final _boardFocus = FocusNode(debugLabel: 'board');

  static final _keyDirections = <LogicalKeyboardKey, SwipeDirection>{
    LogicalKeyboardKey.arrowUp: SwipeDirection.up,
    LogicalKeyboardKey.arrowDown: SwipeDirection.down,
    LogicalKeyboardKey.arrowLeft: SwipeDirection.left,
    LogicalKeyboardKey.arrowRight: SwipeDirection.right,
    LogicalKeyboardKey.keyW: SwipeDirection.up,
    LogicalKeyboardKey.keyS: SwipeDirection.down,
    LogicalKeyboardKey.keyA: SwipeDirection.left,
    LogicalKeyboardKey.keyD: SwipeDirection.right,
  };

  void _handleKey(KeyEvent event, GameNotifier notifier) {
    if (event is! KeyDownEvent) return;
    final direction = _keyDirections[event.logicalKey];
    if (direction != null) notifier.move(direction);
  }

  @override
  void dispose() {
    _boardFocus.dispose();
    super.dispose();
  }

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
                    // El tablero solo entendia gestos de deslizar, asi que en
                    // web y escritorio -- donde este proyecto tambien compila
                    // -- el juego no se podia jugar. Las flechas y WASD hacen
                    // exactamente lo mismo que el swipe.
                    child: KeyboardListener(
                      focusNode: _boardFocus,
                      autofocus: true,
                      onKeyEvent: (event) => _handleKey(event, gameNotifier),
                      child: BoardWidget(
                        board: gameState.board,
                        onSwipe: gameNotifier.move,
                      ),
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
    final scheme = Theme.of(context).colorScheme;
    // El fondo es `primaryContainer`, así que la tinta tiene que ser
    // `onPrimaryContainer`. Sin el `color:` explícito los textos heredaban
    // `onSurface`, que es la tinta de otra superficie: el par de colores no
    // está garantizado por el ColorScheme y el contraste queda al azar.
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Semantics(
        label: '$label: $value',
        excludeSemantics: true,
        child: Column(
          children: [
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: scheme.onPrimaryContainer),
            ),
            Text(
              '$value',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: scheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
