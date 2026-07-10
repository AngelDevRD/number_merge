import 'package:flutter/material.dart';

import '../../domain/board.dart';
import '../../domain/tile.dart' as domain;
import 'tile_widget.dart';

/// Renders the 4x4 board responsively: it always occupies a square that fits
/// the smaller of the available width/height, so it scales cleanly on phones
/// and tablets alike without any hardcoded pixel sizes.
class BoardWidget extends StatelessWidget {
  final Board board;
  final void Function(domain.SwipeDirection direction) onSwipe;

  const BoardWidget({super.key, required this.board, required this.onSwipe});

  static const _gap = 8.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;
        final cellSize = (side - _gap * (boardSize + 1)) / boardSize;

        return GestureDetector(
          onPanEnd: (details) => _handleSwipe(details.velocity.pixelsPerSecond),
          child: Container(
            width: side,
            height: side,
            padding: const EdgeInsets.all(_gap),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                _buildGridBackground(context, cellSize),
                ...board.tiles.map((tile) {
                  return AnimatedPositioned(
                    key: ValueKey(tile.id),
                    duration: const Duration(milliseconds: 140),
                    curve: Curves.easeInOut,
                    left: tile.col * (cellSize + _gap),
                    top: tile.row * (cellSize + _gap),
                    child: TileWidget(tile: tile, cellSize: cellSize),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGridBackground(BuildContext context, double cellSize) {
    final cellColor = Theme.of(context).colorScheme.surfaceContainerHigh;
    return Column(
      children: List.generate(boardSize, (row) {
        return Padding(
          padding: EdgeInsets.only(bottom: row == boardSize - 1 ? 0 : _gap),
          child: Row(
            children: List.generate(boardSize, (col) {
              return Padding(
                padding: EdgeInsets.only(
                  right: col == boardSize - 1 ? 0 : _gap,
                ),
                child: Container(
                  width: cellSize,
                  height: cellSize,
                  decoration: BoxDecoration(
                    color: cellColor,
                    borderRadius: BorderRadius.circular(cellSize * 0.12),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  void _handleSwipe(Offset velocity) {
    const threshold = 150.0;
    if (velocity.dx.abs() < threshold && velocity.dy.abs() < threshold) return;

    if (velocity.dx.abs() > velocity.dy.abs()) {
      onSwipe(
        velocity.dx > 0
            ? domain.SwipeDirection.right
            : domain.SwipeDirection.left,
      );
    } else {
      onSwipe(
        velocity.dy > 0 ? domain.SwipeDirection.down : domain.SwipeDirection.up,
      );
    }
  }
}
