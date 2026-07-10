import 'package:shared_preferences/shared_preferences.dart';

class ScoreRepository {
  static const _keyBestScore = 'score.best';

  Future<int> getBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyBestScore) ?? 0;
  }

  /// Persists [score] as the new best only if it beats the stored value.
  /// Returns true if a new best score was set.
  Future<bool> maybeUpdateBestScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_keyBestScore) ?? 0;
    if (score > current) {
      await prefs.setInt(_keyBestScore, score);
      return true;
    }
    return false;
  }
}
