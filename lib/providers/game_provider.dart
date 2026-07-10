import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/audio_service.dart';
import '../data/score_repository.dart';
import '../domain/board.dart';
import '../domain/game_state.dart';
import '../domain/merge_engine.dart';
import '../domain/tile.dart';
import 'achievements_provider.dart';
import 'settings_provider.dart';
import 'stats_provider.dart';

final scoreRepositoryProvider = Provider((ref) => ScoreRepository());
final audioServiceProvider = Provider((ref) => AudioService());

class GameNotifier extends StateNotifier<GameState> {
  final Ref _ref;
  final ScoreRepository _scoreRepo;

  /// Single-step undo history (previous board + score before the last move).
  ({Board board, int score})? _history;
  bool _gameFinishedRecorded = false;

  GameNotifier(this._ref, this._scoreRepo) : super(GameState.initial()) {
    _init();
  }

  Future<void> _init() async {
    final best = await _scoreRepo.getBestScore();
    state = state.copyWith(bestScore: best);
    _startNewBoard();
  }

  void _startNewBoard() {
    var board = Board.empty();
    board = MergeEngine.spawnRandomTile(board);
    board = MergeEngine.spawnRandomTile(board);
    state = state.copyWith(
      board: board,
      score: 0,
      isGameOver: false,
      hasWon: false,
      moveCount: 0,
    );
    _history = null;
    _gameFinishedRecorded = false;
  }

  bool get canUndo => _history != null;

  void restart() {
    _startNewBoard();
  }

  void undo() {
    final history = _history;
    if (history == null) return;
    state = state.copyWith(
      board: history.board,
      score: history.score,
      isGameOver: false,
    );
    _history = null;
  }

  Future<void> move(SwipeDirection direction) async {
    if (state.isGameOver) return;

    final result = MergeEngine.move(state.board, direction);
    if (!result.moved) return;

    _history = (board: state.board, score: state.score);

    var newBoard = MergeEngine.spawnRandomTile(result.board);
    final newScore = state.score + result.scoreGained;
    final hasWon = state.hasWon || MergeEngine.hasWon(newBoard);
    final isGameOver = !MergeEngine.canMove(newBoard);
    final moveCount = state.moveCount + 1;

    state = state.copyWith(
      board: newBoard,
      score: newScore,
      hasWon: hasWon,
      isGameOver: isGameOver,
      moveCount: moveCount,
    );

    final settings = _ref.read(settingsProvider);
    final audio = _ref.read(audioServiceProvider);
    if (result.scoreGained > 0) {
      if (settings.vibrationOn) {
        HapticFeedback.mediumImpact();
      }
      audio.playMerge();
    } else if (settings.vibrationOn) {
      HapticFeedback.lightImpact();
    }

    final bestTile = newBoard.highestTile;
    await _ref
        .read(statsProvider.notifier)
        .recordMove(bestTileOnBoard: bestTile);
    final isNewBest = await _scoreRepo.maybeUpdateBestScore(newScore);
    if (isNewBest) {
      state = state.copyWith(bestScore: newScore);
    }

    if (isGameOver && !_gameFinishedRecorded) {
      _gameFinishedRecorded = true;
      audio.playGameOver();
      final stats = await _ref
          .read(statsProvider.notifier)
          .recordGameFinished(finalScore: newScore);
      await _ref
          .read(achievementsProvider.notifier)
          .evaluate(
            bestTileOnBoard: bestTile,
            gamesPlayed: stats.gamesPlayed,
            totalScoreEver: stats.totalScoreEver,
          );
    } else {
      final stats = _ref.read(statsProvider);
      await _ref
          .read(achievementsProvider.notifier)
          .evaluate(
            bestTileOnBoard: bestTile,
            gamesPlayed: stats.gamesPlayed,
            totalScoreEver: stats.totalScoreEver,
          );
    }
  }
}

final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  return GameNotifier(ref, ref.watch(scoreRepositoryProvider));
});
