import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/stats_repository.dart';

final statsRepositoryProvider = Provider((ref) => StatsRepository());

class StatsNotifier extends StateNotifier<GameStats> {
  final StatsRepository _repo;

  StatsNotifier(this._repo) : super(GameStats.empty) {
    refresh();
  }

  Future<void> refresh() async {
    state = await _repo.getStats();
  }

  Future<void> recordMove({required int bestTileOnBoard}) async {
    state = await _repo.recordMove(bestTileOnBoard: bestTileOnBoard);
  }

  Future<void> addPlaySeconds(int seconds) async {
    if (seconds <= 0) return;
    state = await _repo.addPlaySeconds(seconds);
  }

  Future<GameStats> recordGameFinished({required int finalScore}) async {
    state = await _repo.recordGameFinished(finalScore: finalScore);
    return state;
  }
}

final statsProvider = StateNotifierProvider<StatsNotifier, GameStats>((ref) {
  return StatsNotifier(ref.watch(statsRepositoryProvider));
});
