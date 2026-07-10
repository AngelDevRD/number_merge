import 'package:shared_preferences/shared_preferences.dart';

class Achievement {
  final String id;
  final String title;
  final String description;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
  });
}

/// Static catalog of every achievement in the game.
const List<Achievement> allAchievements = [
  Achievement(
    id: 'reach_128',
    title: 'Aprendiz',
    description: 'Alcanza una ficha de 128.',
  ),
  Achievement(
    id: 'reach_512',
    title: 'Estratega',
    description: 'Alcanza una ficha de 512.',
  ),
  Achievement(
    id: 'reach_2048',
    title: 'Maestro del 2048',
    description: 'Alcanza una ficha de 2048.',
  ),
  Achievement(
    id: 'play_10_games',
    title: 'Jugador constante',
    description: 'Juega 10 partidas.',
  ),
  Achievement(
    id: 'score_10000_total',
    title: 'Coleccionista de puntos',
    description: 'Acumula 10000 puntos en total.',
  ),
];

class AchievementsRepository {
  static const _keyUnlocked = 'achievements.unlockedIds';

  Future<Set<String>> getUnlockedIds() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_keyUnlocked) ?? const []).toSet();
  }

  /// Marks [id] as unlocked. Returns true if it was newly unlocked (false if
  /// it was already unlocked before this call).
  Future<bool> unlock(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final current = (prefs.getStringList(_keyUnlocked) ?? const []).toSet();
    if (current.contains(id)) return false;
    current.add(id);
    await prefs.setStringList(_keyUnlocked, current.toList());
    return true;
  }
}
