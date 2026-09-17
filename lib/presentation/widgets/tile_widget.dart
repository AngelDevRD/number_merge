import 'package:flutter/material.dart';

import '../../domain/tile.dart';
import '../../theme/app_theme.dart';

/// Renders a single tile, positioned absolutely inside the board's
/// [Stack] via the parent (see BoardWidget), and pop-animates on merge.
class TileWidget extends StatefulWidget {
  final Tile tile;
  final double cellSize;

  const TileWidget({super.key, required this.tile, required this.cellSize});

  @override
  State<TileWidget> createState() => _TileWidgetState();
}

class _TileWidgetState extends State<TileWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.15,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.15,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_controller);

    if (widget.tile.justMerged || widget.tile.isNew) {
      _controller.forward(from: widget.tile.isNew ? 0.5 : 0.0);
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final color = AppTheme.tileColor(widget.tile.value, brightness);
    final textColor = AppTheme.tileTextColor(widget.tile.value, brightness);
    final fontSize = widget.tile.value >= 1024
        ? widget.cellSize * 0.3
        : widget.cellSize * 0.38;

    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: widget.cellSize,
        height: widget.cellSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(widget.cellSize * 0.12),
        ),
        child: Text(
          '${widget.tile.value}',
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
