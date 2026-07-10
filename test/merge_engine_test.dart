import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:number_merge/domain/board.dart';
import 'package:number_merge/domain/merge_engine.dart';
import 'package:number_merge/domain/tile.dart';

/// Builds a board from a 4x4 grid of values (0 = empty), assigning each
/// non-zero cell a stable, distinct id based on position.
Board boardFrom(List<List<int>> values) {
  final cells = List.generate(
    boardSize,
    (r) => List<Tile?>.generate(boardSize, (c) {
      final value = values[r][c];
      if (value == 0) return null;
      return Tile(id: r * boardSize + c + 1, value: value, row: r, col: c);
    }),
  );
  return Board(cells);
}

/// Extracts just the values from a board, for easy comparison in assertions.
List<List<int>> valuesOf(Board board) {
  return List.generate(
    boardSize,
    (r) => List.generate(boardSize, (c) => board.at(r, c)?.value ?? 0),
  );
}

void main() {
  setUp(() => MergeEngine.resetIdCounter());

  group('move - left', () {
    test('slides tiles to the left edge without merging', () {
      final board = boardFrom([
        [0, 2, 0, 4],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]);
      final result = MergeEngine.move(board, SwipeDirection.left);
      expect(valuesOf(result.board)[0], [2, 4, 0, 0]);
      expect(result.moved, isTrue);
      expect(result.scoreGained, 0);
    });

    test('merges one equal adjacent pair', () {
      final board = boardFrom([
        [2, 2, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]);
      final result = MergeEngine.move(board, SwipeDirection.left);
      expect(valuesOf(result.board)[0], [4, 0, 0, 0]);
      expect(result.scoreGained, 4);
      expect(result.moved, isTrue);
    });

    test('does not double-merge a run of four equal tiles', () {
      // [2,2,2,2] -> merge first pair and second pair separately: [4,4,0,0].
      // The merged 4s must NOT merge again into 8 in the same move.
      final board = boardFrom([
        [2, 2, 2, 2],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]);
      final result = MergeEngine.move(board, SwipeDirection.left);
      expect(valuesOf(result.board)[0], [4, 4, 0, 0]);
      expect(result.scoreGained, 8);
    });

    test('three equal tiles merge only the leading pair', () {
      final board = boardFrom([
        [2, 2, 2, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]);
      final result = MergeEngine.move(board, SwipeDirection.left);
      expect(valuesOf(result.board)[0], [4, 2, 0, 0]);
      expect(result.scoreGained, 4);
    });

    test('reports no move when nothing changes', () {
      final board = boardFrom([
        [2, 4, 8, 16],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]);
      final result = MergeEngine.move(board, SwipeDirection.left);
      expect(result.moved, isFalse);
      expect(result.scoreGained, 0);
    });
  });

  group('move - right', () {
    test('slides and merges toward the right edge', () {
      final board = boardFrom([
        [2, 2, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]);
      final result = MergeEngine.move(board, SwipeDirection.right);
      expect(valuesOf(result.board)[0], [0, 0, 0, 4]);
      expect(result.scoreGained, 4);
    });

    test('does not double-merge a run of four equal tiles', () {
      final board = boardFrom([
        [2, 2, 2, 2],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]);
      final result = MergeEngine.move(board, SwipeDirection.right);
      expect(valuesOf(result.board)[0], [0, 0, 4, 4]);
      expect(result.scoreGained, 8);
    });
  });

  group('move - up', () {
    test('slides and merges toward the top edge', () {
      final board = boardFrom([
        [2, 0, 0, 0],
        [2, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]);
      final result = MergeEngine.move(board, SwipeDirection.up);
      final values = valuesOf(result.board);
      expect(values[0][0], 4);
      expect(values[1][0], 0);
      expect(result.scoreGained, 4);
    });

    test('does not double-merge a column of four equal tiles', () {
      final board = boardFrom([
        [2, 0, 0, 0],
        [2, 0, 0, 0],
        [2, 0, 0, 0],
        [2, 0, 0, 0],
      ]);
      final result = MergeEngine.move(board, SwipeDirection.up);
      final column = List.generate(
        boardSize,
        (r) => result.board.at(r, 0)?.value ?? 0,
      );
      expect(column, [4, 4, 0, 0]);
      expect(result.scoreGained, 8);
    });
  });

  group('move - down', () {
    test('slides and merges toward the bottom edge', () {
      final board = boardFrom([
        [2, 0, 0, 0],
        [2, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]);
      final result = MergeEngine.move(board, SwipeDirection.down);
      final column = List.generate(
        boardSize,
        (r) => result.board.at(r, 0)?.value ?? 0,
      );
      expect(column, [0, 0, 0, 4]);
      expect(result.scoreGained, 4);
    });

    test('does not double-merge a column of four equal tiles', () {
      final board = boardFrom([
        [2, 0, 0, 0],
        [2, 0, 0, 0],
        [2, 0, 0, 0],
        [2, 0, 0, 0],
      ]);
      final result = MergeEngine.move(board, SwipeDirection.down);
      final column = List.generate(
        boardSize,
        (r) => result.board.at(r, 0)?.value ?? 0,
      );
      expect(column, [0, 0, 4, 4]);
      expect(result.scoreGained, 8);
    });

    test('different values never merge', () {
      final board = boardFrom([
        [2, 0, 0, 0],
        [4, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]);
      final result = MergeEngine.move(board, SwipeDirection.down);
      final column = List.generate(
        boardSize,
        (r) => result.board.at(r, 0)?.value ?? 0,
      );
      expect(column, [0, 0, 2, 4]);
      expect(result.scoreGained, 0);
      expect(result.moved, isTrue);
    });
  });

  group('canMove / game over detection', () {
    test('true when board has an empty cell', () {
      final board = boardFrom([
        [2, 4, 8, 16],
        [4, 2, 4, 2],
        [2, 4, 2, 4],
        [4, 2, 4, 0],
      ]);
      expect(MergeEngine.canMove(board), isTrue);
    });

    test('true when a full board still has an adjacent equal pair', () {
      final board = boardFrom([
        [2, 4, 8, 16],
        [4, 2, 4, 2],
        [2, 4, 2, 4],
        [4, 2, 4, 4],
      ]);
      expect(MergeEngine.canMove(board), isTrue);
    });

    test('false when board is full with no adjacent equal pairs', () {
      final board = boardFrom([
        [2, 4, 2, 4],
        [4, 2, 4, 2],
        [2, 4, 2, 4],
        [4, 2, 4, 2],
      ]);
      expect(MergeEngine.canMove(board), isFalse);
    });
  });

  group('hasWon', () {
    test('false when no tile reaches 2048', () {
      final board = boardFrom([
        [1024, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]);
      expect(MergeEngine.hasWon(board), isFalse);
    });

    test('true when a tile reaches exactly 2048', () {
      final board = boardFrom([
        [2048, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]);
      expect(MergeEngine.hasWon(board), isTrue);
    });

    test('true when a tile exceeds 2048 (e.g. after merging two 2048s)', () {
      final board = boardFrom([
        [4096, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]);
      expect(MergeEngine.hasWon(board), isTrue);
    });
  });

  group('spawnRandomTile', () {
    test('always spawns value 2 or 4', () {
      for (var seed = 0; seed < 50; seed++) {
        final board = MergeEngine.spawnRandomTile(Board.empty(), Random(seed));
        final spawned = board.tiles.single;
        expect([2, 4], contains(spawned.value));
      }
    });

    test('spawns into a previously-empty cell', () {
      final board = boardFrom([
        [2, 2, 2, 2],
        [2, 2, 2, 2],
        [2, 2, 2, 0],
        [2, 2, 2, 2],
      ]);
      final result = MergeEngine.spawnRandomTile(board, Random(1));
      expect(result.at(2, 3), isNotNull);
      expect(result.tiles.length, 16);
    });

    test('is a no-op when the board is already full', () {
      final board = boardFrom([
        [2, 4, 2, 4],
        [4, 2, 4, 2],
        [2, 4, 2, 4],
        [4, 2, 4, 2],
      ]);
      final result = MergeEngine.spawnRandomTile(board, Random(1));
      expect(valuesOf(result), valuesOf(board));
    });
  });
}
