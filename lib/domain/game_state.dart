import 'board.dart';

/// Full snapshot of a game in progress.
class GameState {
  final Board board;
  final int score;
  final int bestScore;
  final bool isGameOver;
  final bool hasWon;
  final int moveCount;

  const GameState({
    required this.board,
    required this.score,
    required this.bestScore,
    required this.isGameOver,
    required this.hasWon,
    required this.moveCount,
  });

  factory GameState.initial({int bestScore = 0}) => GameState(
    board: Board.empty(),
    score: 0,
    bestScore: bestScore,
    isGameOver: false,
    hasWon: false,
    moveCount: 0,
  );

  GameState copyWith({
    Board? board,
    int? score,
    int? bestScore,
    bool? isGameOver,
    bool? hasWon,
    int? moveCount,
  }) {
    return GameState(
      board: board ?? this.board,
      score: score ?? this.score,
      bestScore: bestScore ?? this.bestScore,
      isGameOver: isGameOver ?? this.isGameOver,
      hasWon: hasWon ?? this.hasWon,
      moveCount: moveCount ?? this.moveCount,
    );
  }
}
