import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/achievements_repository.dart';

final achievementsRepositoryProvider = Provider(
  (ref) => AchievementsRepository(),
);

class AchievementsNotifier extends StateNotifier<Set<String>> {
  final AchievementsRepository _repo;

  AchievementsNotifier(this._repo) : super(const {}) {
    refresh();
  }

  Future<void> refresh() async {
    state = await _repo.getUnlockedIds();
  }

  /// Evaluates achievement conditions against current progress and unlocks
  /// any newly-earned ones. Returns the list of achievements unlocked by this
  /// call (empty if none), for the UI to optionally celebrate.
  Future<List<Achievement>> evaluate({
    required int bestTileOnBoard,
    required int gamesPlayed,
    required int totalScoreEver,
  }) async {
    final newlyUnlocked = <Achievement>[];

    Future<void> check(String id, bool condition) async {
      if (!condition) return;
      final unlocked = await _repo.unlock(id);
      if (unlocked) {
        newlyUnlocked.add(allAchievements.firstWhere((a) => a.id == id));
      }
    }

    await check('reach_128', bestTileOnBoard >= 128);
    await check('reach_512', bestTileOnBoard >= 512);
    await check('reach_2048', bestTileOnBoard >= 2048);
    await check('play_10_games', gamesPlayed >= 10);
    await check('score_10000_total', totalScoreEver >= 10000);

    if (newlyUnlocked.isNotEmpty) {
      state = await _repo.getUnlockedIds();
    }
    return newlyUnlocked;
  }
}

final achievementsProvider =
    StateNotifierProvider<AchievementsNotifier, Set<String>>((ref) {
      return AchievementsNotifier(ref.watch(achievementsRepositoryProvider));
    });
