import 'tile.dart';

const int boardSize = 4;

/// Immutable 4x4 board of tiles. Empty cells are `null`.
class Board {
  final List<List<Tile?>> cells;

  Board(this.cells);

  factory Board.empty() {
    return Board(
      List.generate(boardSize, (_) => List<Tile?>.filled(boardSize, null)),
    );
  }

  Tile? at(int row, int col) => cells[row][col];

  bool get isFull => cells.every((r) => r.every((t) => t != null));

  List<({int row, int col})> get emptyCells {
    final result = <({int row, int col})>[];
    for (var r = 0; r < boardSize; r++) {
      for (var c = 0; c < boardSize; c++) {
        if (cells[r][c] == null) result.add((row: r, col: c));
      }
    }
    return result;
  }

  List<Tile> get tiles => cells.expand((row) => row).whereType<Tile>().toList();

  Board copyWith(List<List<Tile?>> newCells) => Board(newCells);

  /// Deep clone with each tile's transient animation flags cleared.
  Board cleared() {
    final newCells = List.generate(
      boardSize,
      (r) => List<Tile?>.generate(boardSize, (c) {
        final t = cells[r][c];
        if (t == null) return null;
        return t.copyWith(justMerged: false, isNew: false);
      }),
    );
    return Board(newCells);
  }

  int get highestTile {
    var best = 0;
    for (final t in tiles) {
      if (t.value > best) best = t.value;
    }
    return best;
  }
}
