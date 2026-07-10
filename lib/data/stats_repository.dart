import 'package:shared_preferences/shared_preferences.dart';

class GameStats {
  final int gamesPlayed;
  final int totalSecondsPlayed;
  final int bestTileEver;
  final int totalMoves;
  final int totalScoreEver;

  const GameStats({
    required this.gamesPlayed,
    required this.totalSecondsPlayed,
    required this.bestTileEver,
    required this.totalMoves,
    required this.totalScoreEver,
  });

  static const empty = GameStats(
    gamesPlayed: 0,
    totalSecondsPlayed: 0,
    bestTileEver: 0,
    totalMoves: 0,
    totalScoreEver: 0,
  );
}

class StatsRepository {
  static const _keyGamesPlayed = 'stats.gamesPlayed';
  static const _keyTotalSeconds = 'stats.totalSecondsPlayed';
  static const _keyBestTile = 'stats.bestTileEver';
  static const _keyTotalMoves = 'stats.totalMoves';
  static const _keyTotalScore = 'stats.totalScoreEver';

  Future<GameStats> getStats() async {
    final prefs = await SharedPreferences.getInstance();
    return GameStats(
      gamesPlayed: prefs.getInt(_keyGamesPlayed) ?? 0,
      totalSecondsPlayed: prefs.getInt(_keyTotalSeconds) ?? 0,
      bestTileEver: prefs.getInt(_keyBestTile) ?? 0,
      totalMoves: prefs.getInt(_keyTotalMoves) ?? 0,
      totalScoreEver: prefs.getInt(_keyTotalScore) ?? 0,
    );
  }

  /// Records the outcome of a finished/ongoing game and returns the updated
  /// stats. Called once per game-over (games/score) and continuously for
  /// moves/time/bestTile as the game progresses.
  Future<GameStats> recordMove({required int bestTileOnBoard}) async {
    final prefs = await SharedPreferences.getInstance();
    final moves = (prefs.getInt(_keyTotalMoves) ?? 0) + 1;
    await prefs.setInt(_keyTotalMoves, moves);

    final currentBest = prefs.getInt(_keyBestTile) ?? 0;
    if (bestTileOnBoard > currentBest) {
      await prefs.setInt(_keyBestTile, bestTileOnBoard);
    }
    return getStats();
  }

  Future<GameStats> addPlaySeconds(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    final total = (prefs.getInt(_keyTotalSeconds) ?? 0) + seconds;
    await prefs.setInt(_keyTotalSeconds, total);
    return getStats();
  }

  Future<GameStats> recordGameFinished({required int finalScore}) async {
    final prefs = await SharedPreferences.getInstance();
    final games = (prefs.getInt(_keyGamesPlayed) ?? 0) + 1;
    await prefs.setInt(_keyGamesPlayed, games);
    final totalScore = (prefs.getInt(_keyTotalScore) ?? 0) + finalScore;
    await prefs.setInt(_keyTotalScore, totalScore);
    return getStats();
  }
}
