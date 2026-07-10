import 'dart:math';

import 'board.dart';
import 'tile.dart';

/// Result of attempting a move: whether anything changed, the resulting
/// board, and the score gained from merges in this move.
class MoveResult {
  final Board board;
  final int scoreGained;
  final bool moved;

  const MoveResult({
    required this.board,
    required this.scoreGained,
    required this.moved,
  });
}

class MergeEngine {
  static int _nextId = 1;

  /// Resets the internal id counter. Only needed for deterministic tests.
  static void resetIdCounter([int start = 1]) => _nextId = start;

  static int _newId() => _nextId++;

  /// Applies [direction] to [board]. Slides every tile as far as possible,
  /// merging equal adjacent tiles exactly once per move: a tile produced by a
  /// merge is flagged and skipped as a *source* for further merging within
  /// the same move, so `[2,2,2,2]` sliding right becomes `[_,_,4,4]`, never
  /// `[_,_,_,8]`.
  static MoveResult move(Board board, SwipeDirection direction) {
    final cleared = board.cleared();
    var scoreGained = 0;
    var moved = false;

    // Work on lines (rows or columns) oriented so "toward index 0" is always
    // the merge target direction; this lets one algorithm serve all 4 swipes.
    final newCells = List.generate(
      boardSize,
      (_) => List<Tile?>.filled(boardSize, null),
    );

    for (var lineIndex = 0; lineIndex < boardSize; lineIndex++) {
      final originalLine = _extractLine(cleared, direction, lineIndex);
      final mergedLine = _mergeLine(originalLine);
      scoreGained += mergedLine.scoreGained;
      _writeLine(newCells, direction, lineIndex, mergedLine.tiles);
      if (!_lineEquals(originalLine, mergedLine.tiles)) moved = true;
    }

    return MoveResult(
      board: Board(newCells),
      scoreGained: scoreGained,
      moved: moved,
    );
  }

  /// Extracts the 4 cells along [direction] for [lineIndex], ordered so index
  /// 0 is the edge tiles slide toward.
  static List<Tile?> _extractLine(
    Board board,
    SwipeDirection direction,
    int lineIndex,
  ) {
    switch (direction) {
      case SwipeDirection.left:
        return List.generate(boardSize, (i) => board.at(lineIndex, i));
      case SwipeDirection.right:
        return List.generate(
          boardSize,
          (i) => board.at(lineIndex, boardSize - 1 - i),
        );
      case SwipeDirection.up:
        return List.generate(boardSize, (i) => board.at(i, lineIndex));
      case SwipeDirection.down:
        return List.generate(
          boardSize,
          (i) => board.at(boardSize - 1 - i, lineIndex),
        );
    }
  }

  static void _writeLine(
    List<List<Tile?>> cells,
    SwipeDirection direction,
    int lineIndex,
    List<Tile?> line,
  ) {
    for (var i = 0; i < boardSize; i++) {
      switch (direction) {
        case SwipeDirection.left:
          cells[lineIndex][i] = _placeAt(line[i], lineIndex, i);
        case SwipeDirection.right:
          cells[lineIndex][boardSize - 1 - i] = _placeAt(
            line[i],
            lineIndex,
            boardSize - 1 - i,
          );
        case SwipeDirection.up:
          cells[i][lineIndex] = _placeAt(line[i], i, lineIndex);
        case SwipeDirection.down:
          cells[boardSize - 1 - i][lineIndex] = _placeAt(
            line[i],
            boardSize - 1 - i,
            lineIndex,
          );
      }
    }
  }

  static Tile? _placeAt(Tile? tile, int row, int col) {
    if (tile == null) return null;
    return tile.copyWith(row: row, col: col);
  }

  static bool _lineEquals(List<Tile?> a, List<Tile?> b) {
    for (var i = 0; i < a.length; i++) {
      final av = a[i]?.value;
      final bv = b[i]?.value;
      final aid = a[i]?.id;
      final bid = b[i]?.id;
      if (av != bv || aid != bid) return false;
    }
    return true;
  }

  /// Slides a single line toward index 0 and merges equal adjacent tiles once.
  static ({List<Tile?> tiles, int scoreGained}) _mergeLine(List<Tile?> line) {
    final nonNull = line.whereType<Tile>().toList();
    final result = <Tile?>[];
    var scoreGained = 0;

    var i = 0;
    while (i < nonNull.length) {
      final current = nonNull[i];
      if (i + 1 < nonNull.length && nonNull[i + 1].value == current.value) {
        final mergedValue = current.value * 2;
        result.add(
          Tile(
            id: _newId(),
            value: mergedValue,
            row: current.row,
            col: current.col,
            justMerged: true,
          ),
        );
        scoreGained += mergedValue;
        i += 2; // Both source tiles consumed; merged tile cannot merge again.
      } else {
        result.add(current);
        i += 1;
      }
    }

    while (result.length < boardSize) {
      result.add(null);
    }

    return (tiles: result, scoreGained: scoreGained);
  }

  /// Spawns a tile (90% value 2, 10% value 4) into a random empty cell.
  /// Returns the same board unchanged if it is already full.
  static Board spawnRandomTile(Board board, [Random? random]) {
    final rng = random ?? Random();
    final empty = board.emptyCells;
    if (empty.isEmpty) return board;

    final cell = empty[rng.nextInt(empty.length)];
    final value = rng.nextDouble() < 0.9 ? 2 : 4;

    final newCells = List.generate(
      boardSize,
      (r) => List<Tile?>.from(board.cells[r]),
    );
    newCells[cell.row][cell.col] = Tile(
      id: _newId(),
      value: value,
      row: cell.row,
      col: cell.col,
      isNew: true,
    );
    return Board(newCells);
  }

  /// True if any empty cell exists or any adjacent equal pair exists in any
  /// direction (i.e. the player still has a legal move).
  static bool canMove(Board board) {
    if (board.emptyCells.isNotEmpty) return true;

    for (var r = 0; r < boardSize; r++) {
      for (var c = 0; c < boardSize; c++) {
        final value = board.at(r, c)!.value;
        if (c + 1 < boardSize && board.at(r, c + 1)!.value == value) {
          return true;
        }
        if (r + 1 < boardSize && board.at(r + 1, c)!.value == value) {
          return true;
        }
      }
    }
    return false;
  }

  static bool hasWon(Board board) => board.tiles.any((t) => t.value >= 2048);
}
