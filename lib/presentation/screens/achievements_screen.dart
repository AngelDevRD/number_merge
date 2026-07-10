import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/achievements_repository.dart';
import '../../providers/achievements_provider.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unlockedIds = ref.watch(achievementsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Logros')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: allAchievements.length,
        itemBuilder: (context, index) {
          final achievement = allAchievements[index];
          final unlocked = unlockedIds.contains(achievement.id);
          return Card(
            color: unlocked
                ? Theme.of(context).colorScheme.primaryContainer
                : null,
            child: ListTile(
              leading: Icon(
                unlocked ? Icons.emoji_events : Icons.lock_outline,
                color: unlocked
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
              ),
              title: Text(
                achievement.title,
                style: TextStyle(
                  fontWeight: unlocked ? FontWeight.bold : FontWeight.normal,
                  color: unlocked
                      ? null
                      : Theme.of(context).colorScheme.outline,
                ),
              ),
              subtitle: Text(achievement.description),
              trailing: unlocked
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : null,
            ),
          );
        },
      ),
    );
  }
}
