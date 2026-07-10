import 'package:flutter/material.dart';

class OnboardingOverlay extends StatelessWidget {
  final VoidCallback onDismiss;

  const OnboardingOverlay({super.key, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.75),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.swipe, color: Colors.white, size: 64),
              const SizedBox(height: 16),
              const Text(
                'Como jugar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Desliza el dedo hacia arriba, abajo, izquierda o derecha '
                'para mover todas las fichas del tablero.\n\n'
                'Cuando dos fichas con el mismo numero chocan, se combinan '
                'en una sola con el doble de valor.\n\n'
                'Llega a la ficha 2048 para ganar. El juego termina cuando '
                'ya no quedan movimientos posibles.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: onDismiss,
                child: const Text('Entendido'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
