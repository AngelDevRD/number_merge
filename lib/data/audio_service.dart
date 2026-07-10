import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Thin wrapper around `audioplayers`.
///
/// No real audio asset files ship with this project (to avoid bundling
/// copyrighted or synthetic placeholder binaries). [assetsAvailable] is
/// therefore hard-coded to `false`, which makes every play* call a safe
/// no-op. The playback plumbing below is fully wired: dropping real files
/// into `assets/sounds/` (move.mp3, merge.mp3, game_over.mp3), declaring them
/// under `flutter.assets` in pubspec.yaml, and flipping [assetsAvailable] to
/// `true` is all that's needed to enable real sound.
class AudioService {
  AudioService({this.soundEnabled = true});

  static const bool assetsAvailable = false;

  bool soundEnabled;
  final AudioPlayer _player = AudioPlayer();

  void setSoundEnabled(bool value) => soundEnabled = value;

  Future<void> playMove() => _play('sounds/move.mp3');
  Future<void> playMerge() => _play('sounds/merge.mp3');
  Future<void> playGameOver() => _play('sounds/game_over.mp3');

  Future<void> _play(String assetPath) async {
    if (!soundEnabled || !assetsAvailable) return;
    try {
      await _player.play(AssetSource(assetPath));
    } catch (error, stack) {
      // Never let a missing/broken audio asset crash the game.
      debugPrint('AudioService: failed to play $assetPath: $error\n$stack');
    }
  }

  void dispose() {
    _player.dispose();
  }
}
