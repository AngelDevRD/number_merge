# assets/sounds

No real audio files ship with this project (avoids bundling copyrighted or
synthetic placeholder binaries into the repo).

Expected filenames when real audio is added later:

- `move.mp3` - played on a move that shifts tiles without merging.
- `merge.mp3` - played when two tiles merge.
- `game_over.mp3` - played when no more moves are possible.

The playback code path is fully implemented in `lib/data/audio_service.dart`.
To enable real sound:

1. Drop the three files above into this folder.
2. Declare `assets/sounds/` under `flutter: assets:` in `pubspec.yaml`.
3. Flip `AudioService.assetsAvailable` to `true`.

Until then, `AudioService.assetsAvailable` is `false` and every `play*` call
is a safe no-op (also wrapped in try/catch, so it can never crash the app
even if a future asset is missing or malformed).
